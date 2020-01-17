//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

#if !RELEASE

public typealias TODOL10n = String

extension TODOL10n {

  public init(raw: String, _ key: String) {
    self = raw
  }

  public init(raw: String) {
    self = raw
  }
}
#endif

public typealias NonL10n = String

let bundle = Bundle.init(for: Dummy.self)

final class Dummy {}
