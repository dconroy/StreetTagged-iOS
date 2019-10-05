//
//  ImageManagement.swift
//  StreetTagged
//
//  Created by John O'Sullivan on 9/24/19.
//  Copyright © 2019 John O'Sullivan. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AWSCore
import AWSMobileClient
import AWSS3

typealias AWSS3UploadProgress = (_ progress:Progress) -> Void
typealias AWSS3UploadStatus = (_ task:AnyObject,_ key: Optional<String>) -> Void

func uploadUIImageToAWSS3(image: UIImage, progressHandler: @escaping AWSS3UploadProgress, statusHandler: @escaping AWSS3UploadStatus) {
    getUserAWSUserSub (completionHandler: { (sub) in
        let rotated_image = fixOrientation(img: image)
        let data:Data = rotated_image.jpegData(compressionQuality: 0.9)!
        let imageType = "image/jpeg"
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                progressHandler(progress)
            })
        }
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                statusHandler(task, Optional(task.key))
            })
        }
        let transferUtility = AWSS3TransferUtility.default()
        let uuid = UUID().uuidString
        let imageKey =  sub! + "-" + uuid + ".jpg"
        transferUtility.uploadData(data, bucket: GLOBAL_AWS_S3_UPLOAD_BUCKET, key: imageKey, contentType: imageType, expression: expression, completionHandler: completionHandler).continueWith { (task) -> AnyObject? in
            if let error = task.error {
                print("Error: \(error.localizedDescription)")
                statusHandler(task, Optional.none)
            }
            if let _ = task.result {
                statusHandler(task, Optional(task.result!.key))
            }
            return nil;
        }
    })
}

func fixOrientation(img:UIImage) -> UIImage {

  if (img.imageOrientation == UIImage.Orientation.up) {
      return img;
  }

  UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
  let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
    img.draw(in: rect)

  let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
  UIGraphicsEndImageContext();
  return normalizedImage;

}
