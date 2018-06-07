//
//  UIView+Screenshot.swift
//  PhotoStream
//
//  Created by Mubarak Sadoon on 2017-05-13.
//  Copyright © 2017 500px. All rights reserved.
//

import UIKit

extension UIView {
    var screenshot: UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let imageReturnable:UIImage = image {
            return imageReturnable
        } else {
            return UIImage()
        }
    }
    
}
