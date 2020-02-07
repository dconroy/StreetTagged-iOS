//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

public protocol HardwareImageViewType : class {
  var image: CIImage? { get set }
}
