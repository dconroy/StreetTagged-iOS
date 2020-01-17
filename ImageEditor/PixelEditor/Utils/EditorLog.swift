//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation

import os.log

enum EditorLog {

  private static let osLog = OSLog.init(subsystem: "PixelEditor", category: "Editor")
  private static let queue = DispatchQueue.init(label: "me.muukii.PixelEditor.Log")

  static func debug(_ object: Any...) {

    queue.async {
      if #available(iOS 12.0, *) {
        os_log(.debug, log: osLog, "%@", object.map { "\($0)" }.joined(separator: " "))
      } else {
        os_log("%@", log: osLog, type: .debug, object.map { "\($0)" }.joined(separator: " "))
      }
    }
  }
}
