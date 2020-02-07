//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation

open class ColorCubeStorage {
    
  public static let `default` = ColorCubeStorage(filters: [])

  public var filters: [FilterColorCube] = []
  
  public init(filters: [FilterColorCube]) {
    self.filters = filters
  }
}

fileprivate class _Dummy {}
