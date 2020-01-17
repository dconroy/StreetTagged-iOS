//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation

import CoreImage

enum RadiusCalculator {

  static func radius(value: Double, max: Double, imageExtent: CGRect) -> Double {

    let base = Double(sqrt(pow(imageExtent.width,2) + pow(imageExtent.height,2)))
    let c = base / 20
    return c * value / max
  }
}


public protocol Filtering {

  func apply(to image: CIImage, sourceImage: CIImage) -> CIImage
}
