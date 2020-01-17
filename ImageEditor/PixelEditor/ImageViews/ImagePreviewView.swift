//
//  Created by John O'Sullivan on 1/16/20.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit

final class ImagePreviewView : UIView {

  let originalImageView: UIImageView = .init()
  let imageView: UIImageView = .init()
  
  var originalImage: CIImage? {
    didSet {
      guard oldValue != originalImage else { return }
      originalImageView.image = originalImage
        .flatMap { $0.transformed(by: .init(translationX: -$0.extent.origin.x, y: -$0.extent.origin.y)) }
        .flatMap { UIImage(ciImage: $0, scale: UIScreen.main.scale, orientation: .up) }
      EditorLog.debug("ImagePreviewView.image set", originalImage?.extent as Any)
    }
  }

  var image: CIImage? {
    didSet {
      guard oldValue != image else { return }
      imageView.image = image
        .flatMap { $0.transformed(by: .init(translationX: -$0.extent.origin.x, y: -$0.extent.origin.y)) }
        .flatMap { UIImage(ciImage: $0, scale: UIScreen.main.scale, orientation: .up) }
      EditorLog.debug("ImagePreviewView.image set", image?.extent as Any)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: .zero)

    [
      originalImageView,
      imageView
      ].forEach { imageView in
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    originalImageView.isHidden = true
    
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    originalImageView.isHidden = false
    imageView.isHidden = true
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    originalImageView.isHidden = true
    imageView.isHidden = false
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    originalImageView.isHidden = true
    imageView.isHidden = false
  }
}
