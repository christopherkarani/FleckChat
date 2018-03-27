//
//  UIColor_Ext.swift
//  Fleck
//
//  Created by Chris Karani on 3/20/18.
//  Copyright © 2018 Neptune. All rights reserved.
//

import UIKit

//convenience Extension for Initializing rgb colors
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

//Convenience Extension for Message Bubble Colors
extension UIColor {
    static let incomingGray = UIColor(red: 230/255, green: 230/255, blue: 235/255, alpha: 1.0)
    static let outgoingGreen = UIColor(red: 69/255, green: 214/255, blue: 93/255, alpha: 1.0)
}
