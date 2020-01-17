//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation

public struct ParameterRange<T : Comparable, Target> {

  public let min: T
  public let max: T

  public init(min: T, max: T) {
    self.min = min
    self.max = max
  }

}
