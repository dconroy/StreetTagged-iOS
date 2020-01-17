//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

public struct DrawnPathInRect : GraphicsDrawing, Equatable {

  public let inRect: CGRect
  public let path: DrawnPath

  public init(path: DrawnPath, in rect: CGRect) {
    self.path = path
    self.inRect = rect
  }

  public func draw(in context: CGContext, canvasSize: CGSize) {
    path.draw(in: context, canvasSize: canvasSize)
  }
}
