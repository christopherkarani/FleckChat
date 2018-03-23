//
//  Message.swift
//  Fleck
//
//  Created by Christopher Karani on 12/03/2018.
//  Copyright © 2017 Christopher Karani. All rights reserved.
//

import UIKit
import Firebase

public struct Message {
    public var fromID: String?
    public var text: String?
    public var timeStamp: Int?
    public var toID: String?
    public var imageUrl: String?
    public var imageWidth: CGFloat?
    public var imageHeight: CGFloat?
    public var videoUrl: String?

    
    func chatPartnerID() -> String? {
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
    }
    
    init(dictionary: [String: AnyObject]) {
        self.fromID = dictionary["fromID"] as? String
        self.toID = dictionary["toID"] as? String
        self.text = dictionary["text"] as? String
        self.timeStamp = dictionary["timestamp"] as? Int
        self.imageUrl = dictionary["imageUrl"] as? String
        self.imageWidth = dictionary["imageWidth"] as? CGFloat
        self.imageHeight = dictionary["imageHeight"] as? CGFloat
        self.videoUrl = dictionary["videoUrl"] as? String
    }
}
