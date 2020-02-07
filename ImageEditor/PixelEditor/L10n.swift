//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation

public var L10n: L10nStorage = .init()

public struct L10nStorage {
  
  public var done = "Done"
  public var normal = "Normal"
  public var cancel = "Cancel"
  public var filter = "Filter"
  public var edit = "Edit"
  
  public var editAdjustment = "Adjust"
  public var editMask = "Mask"
  public var editHighlights = "Highlights"
  public var editShadows = "Shadows"
  public var editSaturation = "Saturation"
  public var editContrast = "Contrast"
  public var editBlur = "Blur"
  public var editTemperature = "Temperature"
  public var editBrightness = "Brightness"
  public var editVignette = "Vignette"
  public var editFade = "Fade"
  public var editClarity = "Clarity"
  public var editSharpen = "Sharpen"
  
  public var clear = "Clear"
  
  public init() {
    
  }
}
