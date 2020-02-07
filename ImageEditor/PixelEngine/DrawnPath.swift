//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

public struct DrawnPath : GraphicsDrawing, Equatable {

  // MARK: - Properties

  public let brush: OvalBrush
  public let bezierPath: UIBezierPath

  // MARK: - Initializers

  public init(
    brush: OvalBrush,
    path: UIBezierPath
    ) {
    self.brush = brush
    self.bezierPath = path
  }

  // MARK: - Functions

  func brushedPath() -> UIBezierPath {

    let _bezierPath = bezierPath.copy() as! UIBezierPath
    _bezierPath.lineJoinStyle = .round
    _bezierPath.lineCapStyle = .round
    _bezierPath.lineWidth = brush.width

    return _bezierPath
  }

  public func draw(in context: CGContext, canvasSize: CGSize) {
    UIGraphicsPushContext(context)
    context.saveGState()
    defer {
      context.restoreGState()
      UIGraphicsPopContext()
    }

    draw()
  }

  private func draw() {

    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }

    context.saveGState()
    defer {
      context.restoreGState()
    }

    brush.color.setStroke()
    let bezierPath = brushedPath()
    bezierPath.stroke(with: brush.blendMode, alpha: brush.alpha)
  }

}
