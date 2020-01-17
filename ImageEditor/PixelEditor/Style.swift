//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

public struct Style {

  public static let `default` = Style()

  public struct Control {

    public var backgroundColor = UIColor(white: 0.98, alpha: 1)

    public init() {

    }
  }

  public var control = Control()
  
  public var black = UIColor(white: 0.05, alpha: 1)

  public init() {

  }

}
