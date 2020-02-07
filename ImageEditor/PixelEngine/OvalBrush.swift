//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//
import Foundation
import UIKit

public struct OvalBrush : Equatable {

  public static func == (lhs: OvalBrush, rhs: OvalBrush) -> Bool {
    guard lhs.color == rhs.color else { return false }
    guard lhs.width == rhs.width else { return false }
    guard lhs.alpha == rhs.alpha else { return false }
    guard lhs.blendMode == rhs.blendMode else { return false }
    return true
  }

  // MARK: - Properties

  public let color: UIColor
  public let width: CGFloat
  public let alpha: CGFloat
  public let blendMode: CGBlendMode

  // MARK: - Initializers

  public init(
    color: UIColor,
    width: CGFloat,
    alpha: CGFloat = 1,
    blendMode: CGBlendMode = .normal
    ) {

    self.color = color
    self.width = width
    self.alpha = alpha
    self.blendMode = blendMode
  }
}
