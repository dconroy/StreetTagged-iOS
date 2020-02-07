//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

public struct Options {
  
  public static let `default`: Options = .init()
  
  public static var current: Options = .init()
  
  public var classes: Classes = .init()
}

extension Options {
  public struct Classes {
    
    public struct Control {
      
      public var colorCubeControl: ColorCubeControlBase.Type = ColorCubeControl.self
      public var editMenuControl: EditMenuControlBase.Type = EditMenu.EditMenuControl.self
      public var rootControl: RootControlBase.Type = RootControl.self
      public var exposureControl: ExposureControlBase.Type = ExposureControl.self
      public var gaussianBlurControl: GaussianBlurControlBase.Type = GaussianBlurControl.self
      public var saturationControl: SaturationControlBase.Type = SaturationControl.self
      public var contrastControl: ContrastControlBase.Type = ContrastControl.self
      public var temperatureControl: TemperatureControlBase.Type = TemperatureControl.self
      public var vignetteControl: VignetteControlBase.Type = VignetteControl.self
      public var highlightsControl: HighlightsControlBase.Type = HighlightsControl.self
      public var shadowsControl: ShadowsControlBase.Type = ShadowsControl.self
      public var fadeControl: FadeControlBase.Type = FadeControl.self
      public var clarityControl: ClarityControlBase.Type = ClarityControl.self
      public var sharpenControl: SharpenControlBase.Type = SharpenControl.self
      
      public var ignoredEditMenu: [EditMenu] = []
      
      public init() {
        
      }
    }
    
    public var control: Control = .init()
    
    public init() {
      
    }
  }
}
