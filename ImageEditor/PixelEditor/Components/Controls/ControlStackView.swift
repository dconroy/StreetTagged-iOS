//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import UIKit




protocol ControlChildViewType {

  func didReceiveCurrentEdit(_ edit: EditingStack.Edit)
}

extension ControlChildViewType where Self : UIView {

  private func find() -> ControlStackView {

    var _super: UIView?
    _super = superview
    while _super != nil {
      if let target = _super as? ControlStackView {
        return target
      }
      _super = _super?.superview
    }

    fatalError()

  }

  func push(_ view: UIView & ControlChildViewType, animated: Bool) {
    let controlStackView = find()
    controlStackView.push(view, animated: animated)
  }

  func pop(animated: Bool) {
    find().pop(animated: animated)
  }

  func subscribeChangedEdit(to view: UIView & ControlChildViewType) {
    find().subscribeChangedEdit(to: view)
  }
}


final class ControlStackView : UIView {

  private var subscribers: [UIView & ControlChildViewType] = []

  private var latestNotifiedEdit: EditingStack.Edit?
  
  func push(_ view: UIView & ControlChildViewType, animated: Bool) {
    
    addSubview(view)
    view.frame = bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    let currentTop = subscribers.last
    subscribeChangedEdit(to: view)
    
    if animated {
      foreground: do {
        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 0, y: 8)
        UIView.animate(
          withDuration: 0.3,
          delay: 0,
          usingSpringWithDamping: 1,
          initialSpringVelocity: 0,
          options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
          animations: {
            view.alpha = 1
            view.transform = .identity
        }, completion: nil)
      }
      
      background: do {
        
        if let view = currentTop {
          UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
            animations: {
              view.transform = CGAffineTransform(translationX: 0, y: 8)
          }, completion: { _ in
            view.transform = .identity
          })
        }
        
      }
    }
  }
  
  func pop(animated: Bool) {
    
    guard let currentTop = subscribers.last else {
      return
    }
    
    let background = subscribers.dropLast().last
    
    let remove = {
      currentTop.removeFromSuperview()
      self.subscribers.removeAll { $0 == currentTop }
    }
    
    if animated {
      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        usingSpringWithDamping: 1,
        initialSpringVelocity: 0,
        options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
        animations: {
          currentTop.alpha = 0
          currentTop.transform = CGAffineTransform(translationX: 0, y: 8)
      }, completion: { _ in
        remove()
      })
      
      if let view = background {
        view.transform = CGAffineTransform(translationX: 0, y: 8)
        UIView.animate(
          withDuration: 0.3,
          delay: 0,
          usingSpringWithDamping: 1,
          initialSpringVelocity: 0,
          options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
          animations: {
            view.transform = .identity
        }, completion: { _ in
        })
      }
    }
    else {
      remove()
    }
  }
  

  func subscribeChangedEdit(to view: UIView & ControlChildViewType) {
    guard !subscribers.contains(where: { $0 == view }) else { return }
    subscribers.append(view)
    if let edit = latestNotifiedEdit {
      view.didReceiveCurrentEdit(edit)
    }
  }

  func notify(changedEdit: EditingStack.Edit) {

    latestNotifiedEdit = changedEdit

    subscribers
      .forEach {
        $0.didReceiveCurrentEdit(changedEdit)
    }
  }
}

