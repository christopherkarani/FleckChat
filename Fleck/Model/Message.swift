//
//  Message.swift
//  Fleck
//
//  Created by Christopher Karani on 12/03/2018.
//  Copyright © 2017 Christopher Karani. All rights reserved.
//

import UIKit
import Firebase

// Message Object Model Used inside the App
public struct Message {
    private(set) var fromID: String?
    private(set) var text: String?
    private(set) var timeStamp: Int?
    private(set) var toID: String?
    private(set) var imageUrl: String?
    private(set) var imageWidth: CGFloat?
    private(set) var imageHeight: CGFloat?
    private(set) var videoUrl: String?

    
    func chatPartnerID() -> String? {
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
    }
    
    init(dictionary: [String: Any]) {
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
