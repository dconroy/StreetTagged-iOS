//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//
import Foundation




open class ContrastControlBase : FilterControlBase {
  public required init(context: PixelEditContext) {
    super.init(context: context)
  }
}

open class ContrastControl : ContrastControlBase {
  
  open override var title: String {
    return L10n.editContrast
  }
  
  private let navigationView = NavigationView()
  
  public let slider = StepSlider(frame: .zero)
  
  open override func setup() {
    super.setup()
    
    backgroundColor = Style.default.control.backgroundColor
    
    TempCode.layout(navigationView: navigationView, slider: slider, in: self)
    
    slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    
    navigationView.didTapCancelButton = { [weak self] in
      
      self?.context.action(.revert)
        self?.pop(animated: true)
    }
    
    navigationView.didTapDoneButton = { [weak self] in
      
      self?.context.action(.commit)
        self?.pop(animated: true)
    }
  }
  
  open override func didReceiveCurrentEdit(_ edit: EditingStack.Edit) {
    
    slider.set(value: edit.filters.contrast?.value ?? 0, in: FilterContrast.range)
    
  }
  
  @objc
  private func valueChanged() {
    
    let value = slider.transition(in: FilterContrast.range)
    
    guard value != 0 else {
      context.action(.setFilter({ $0.contrast = nil }))
      return
    }
    
    var f = FilterContrast()
    f.value = value
    context.action(.setFilter({ $0.contrast = f }))
  }
  
}
