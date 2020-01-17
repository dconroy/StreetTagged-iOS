//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//
import Foundation
import UIKit

open class MaskControlBase : ControlBase {

}

open class MaskControl : MaskControlBase {

  private let contentView = UIView()
  private let navigationView = NavigationView()
  
  private let clearButton = UIButton.init(type: .system)

  open override func setup() {
    super.setup()

    backgroundColor = Style.default.control.backgroundColor
    
    base: do {
      
      addSubview(contentView)
      addSubview(navigationView)
      
      contentView.translatesAutoresizingMaskIntoConstraints = false
      navigationView.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        
        contentView.topAnchor.constraint(equalTo: contentView.superview!.topAnchor),
        contentView.rightAnchor.constraint(equalTo: contentView.superview!.rightAnchor),
        contentView.leftAnchor.constraint(equalTo: contentView.superview!.leftAnchor),
        
        navigationView.topAnchor.constraint(equalTo: contentView.bottomAnchor),
        navigationView.rightAnchor.constraint(equalTo: navigationView.superview!.rightAnchor),
        navigationView.leftAnchor.constraint(equalTo: navigationView.superview!.leftAnchor),
        navigationView.bottomAnchor.constraint(equalTo: navigationView.superview!.bottomAnchor),
        ])
      
    }
    
    clearButton: do {
      
      contentView.addSubview(clearButton)
      clearButton.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        clearButton.centerXAnchor.constraint(equalTo: clearButton.superview!.centerXAnchor),
        clearButton.topAnchor.constraint(equalTo: clearButton.superview!.topAnchor, constant: 16),        
        ])
      
      clearButton.addTarget(self, action: #selector(didTapRemoveAllButton), for: .touchUpInside)
      clearButton.setTitle(L10n.clear, for: .normal)
      clearButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
      
    }
    
    navigationView.didTapCancelButton = { [weak self] in

      self?.pop(animated: true)
      self?.context.action(.endMasking(save: false))
    }

    navigationView.didTapDoneButton = { [weak self] in

      self?.pop(animated: true)
      self?.context.action(.endMasking(save: true))
    }

  }

  open override func didMoveToSuperview() {
    super.didMoveToSuperview()

    if superview != nil {
      context.action(.setMode(.masking))
    } else {
      context.action(.setMode(.preview))
    }

  }
  
  @objc
  private func didTapRemoveAllButton() {
    
    context.action(.removeAllMasking)
  }
}
