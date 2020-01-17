//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation



open class SharpenControlBase : FilterControlBase {
  
  public required init(context: PixelEditContext) {
    super.init(context: context)
  }
}

open class SharpenControl : SharpenControlBase {
  
  open override var title: String {
    return L10n.editSharpen
  }
  
  private let navigationView = NavigationView()
  
  public let slider = StepSlider(frame: .zero)
  
  open override func setup() {
    super.setup()
    
    backgroundColor = Style.default.control.backgroundColor
    
    TempCode.layout(navigationView: navigationView, slider: slider, in: self)
    
    slider.mode = .plus
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
    
    slider.set(value: edit.filters.sharpen?.sharpness ?? 0, in: FilterSharpen.Params.sharpness)
    
  }
  
  @objc
  private func valueChanged() {
    
    let value = slider.transition(in: FilterSharpen.Params.sharpness)
    
    guard value != 0 else {
      context.action(.setFilter({ $0.sharpen = nil }))
      return
    }
    
    var f = FilterSharpen()
    f.sharpness = value
    f.radius = 1.2
    context.action(.setFilter({ $0.sharpen = f }))
  }
  
}
