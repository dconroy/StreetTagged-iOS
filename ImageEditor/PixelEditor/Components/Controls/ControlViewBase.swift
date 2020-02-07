//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

open class ControlBase : UIView, ControlChildViewType {
  
  open func didReceiveCurrentEdit(_ edit: EditingStack.Edit) {
    
  }

  public let context: PixelEditContext

  public init(context: PixelEditContext) {
    self.context = context
    super.init(frame: .zero)
    setup()
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func setup() {

  }
}
