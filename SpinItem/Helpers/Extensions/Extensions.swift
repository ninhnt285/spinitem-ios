//
//  HelperExtensions.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/7/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIView {
    /**
     Adds a vertical gradient layer with two **UIColors** to the **UIView**.
     - Parameter topColor: The top **UIColor**.
     - Parameter bottomColor: The bottom **UIColor**.
     */
    
    func addVerticalGradientLayer(topColor:UIColor, bottomColor:UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [
            topColor.cgColor,
            bottomColor.cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func applyShadow(shadowColor: UIColor) {
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 10.0
        self.clipsToBounds = false
        self.layer.masksToBounds = false
    }
}

extension UIImageView {
    static func loadAllImageFromUrl(imageUrls: [String], completionHandler: @escaping (NSError?) -> ()) {
        var total = 0
        for url in imageUrls {
            if let _ = imageCache.object(forKey: url as AnyObject) as? UIImage {
                total += 1
                if (total == imageUrls.count) {
                    completionHandler(nil)
                }
                continue
            }
            
            URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
                if (error != nil) {
                    completionHandler(NSError(domain: "loadAllImageFromUrl", code: 1, userInfo: nil))
                    return
                } else {
                    DispatchQueue.main.async {
                        total += 1
                        if let downloadedImage = UIImage(data: data!) {
                            imageCache.setObject(downloadedImage, forKey: url as AnyObject)
                        }
                        if (total == imageUrls.count) {
                            completionHandler(nil)
                        }
                    }
                }
            }.resume()
        }
    }
    
    func loadImageFromCacheUrl(url: String?) {
        self.image = nil
        if (url == nil) || (url == "") {
            return
        }
        if let cachedImage = imageCache.object(forKey: url as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        URLSession.shared.dataTask(with: URL(string: url!)!) { (data, response, error) in
            if (error != nil) {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: url as AnyObject)
                    self.image = downloadedImage
                }
            }
        }.resume()
    }
}
