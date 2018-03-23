//
//  UIImageView_Ext.swift
//  Fleck
//
//  Created by Chris Karani on 3/22/18.
//  Copyright © 2018 Neptune. All rights reserved.
//

import UIKit

//Easily Download Images and Cache them for later Use
let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    public func loadImageUsingCache(withURLString urlString: String) {
        let url = URL(string: urlString)
        
        //check the cache first
        if let cachedImage = imageCache.object(forKey: urlString as NSString)  {
            self.image = cachedImage
            return
        }
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
            }
            DispatchQueue.main.async {
                if let downloadedImage =  UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
            }
        }).resume()
    }
}
