//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

public struct FilterHighlightShadowTint : Filtering, Equatable {
  
  public var highlightColor: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 0)
  public var shadowColor: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 0)
  
  public init() {
    
  }
  
  public func apply(to image: CIImage, sourceImage: CIImage) -> CIImage {
    
    let highlight = CIFilter(
      name: "CIConstantColorGenerator",
      parameters: [kCIInputColorKey : highlightColor]
      )!
      .outputImage!
      .cropped(to: image.extent)
    
    let shadow = CIFilter(
      name: "CIConstantColorGenerator",
      parameters: [kCIInputColorKey : shadowColor]
      )!
      .outputImage!
      .cropped(to: image.extent)
    
    let darken = CIFilter(
      name: "CISourceOverCompositing",
      parameters: [
        kCIInputImageKey : shadow,
        kCIInputBackgroundImageKey : image
      ])!
    
    let lighten = CIFilter(
      name: "CISourceOverCompositing",
      parameters: [
        kCIInputImageKey : highlight,
        kCIInputBackgroundImageKey : darken.outputImage!
      ])!
    
    return lighten.outputImage!
  }
}
