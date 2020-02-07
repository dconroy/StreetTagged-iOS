//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation

open class FilterControlBase : ControlBase {
  
  open var title: String {
    fatalError("Must be overrided")
  }

  public required override init(context: PixelEditContext) {
    super.init(context: context)
  }

  open override func didMoveToSuperview() {
    super.didMoveToSuperview()

    if superview != nil {
      context.action(.setMode(.editing))
      context.action(.setTitle(title))
    } else {
      context.action(.setTitle(""))
      context.action(.setMode(.preview))
    }

  }
}
