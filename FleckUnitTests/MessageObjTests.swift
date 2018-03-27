//
//  FleckUnitTests.swift
//  FleckUnitTests
//
//  Created by Chris Karani on 3/27/18.
//  Copyright © 2018 Neptune. All rights reserved.
//

import XCTest
@testable import Fleck

class MessageObjTests: XCTestCase {
    
    func test_MessageWithTextProperties() {
        let dictionary: [String: Any] = ["fromID": "HDIhsHdwRvSnFR6mm1GiRD5WaiZ2",
                          "toID": "5C12ogxenQbEhZTbbSlZPQ3S0rK2",
                          "text": "Hey buddy",
                          "timestamp": 1521904320]
        let message = Message(dictionary: dictionary)
        XCTAssertEqual(message.fromID, "HDIhsHdwRvSnFR6mm1GiRD5WaiZ2")
        XCTAssertEqual(message.toID, "5C12ogxenQbEhZTbbSlZPQ3S0rK2")
        XCTAssertEqual(message.text, "Hey buddy")
    }
    
    func test_MessageWithText() {
        let dictionary: [String: Any] = ["fromID": "HDIhsHdwRvSnFR6mm1GiRD5WaiZ2",
                                         "toID": "5C12ogxenQbEhZTbbSlZPQ3S0rK2",
                                         "text": "Hey buddy",
                                         "timestamp": 1521904320]
        let message = Message(dictionary: dictionary)
        
        XCTAssertNil(message.videoUrl)
        XCTAssertNil(message.imageUrl)
        XCTAssertNil(message.imageWidth)
        XCTAssertNil(message.imageHeight)
    }
    
    func test_MessageWithImageProperties() {
        let dictionary: [String: Any] = ["fromID": "5C12ogxenQbEhZTbbSlZPQ3S0rK2",
                                         "imageHeight": CGFloat(1125),
                                         "imageWidth": CGFloat(1125),
                                         "imageUrl": "https://firebasestorage.googleapis.com/v0/b/fleckchat.appspot.com/o/message_images%2FECB7B3F5-2AF3-47A8-A9A5-73C23316A3E6?alt=media&token=ef00432e-8e62-4b94-9a52-fa49c519928a",
                                         "timestamp": 1522144647,
                                         "toID": "HDIhsHdwRvSnFR6mm1GiRD5WaiZ2"]
        let message = Message(dictionary: dictionary)
        
        XCTAssertEqual(message.fromID, "5C12ogxenQbEhZTbbSlZPQ3S0rK2")
        XCTAssertEqual(message.imageHeight, 1125)
        XCTAssertEqual(message.imageWidth, 1125)
        XCTAssertEqual(message.imageUrl, "https://firebasestorage.googleapis.com/v0/b/fleckchat.appspot.com/o/message_images%2FECB7B3F5-2AF3-47A8-A9A5-73C23316A3E6?alt=media&token=ef00432e-8e62-4b94-9a52-fa49c519928a")
        XCTAssertEqual(message.timeStamp, 1522144647)
        XCTAssertEqual(message.toID, "HDIhsHdwRvSnFR6mm1GiRD5WaiZ2")
    }
    
    func test_MessageWithImage() {
        let dictionary: [String: Any] = ["fromID": "5C12ogxenQbEhZTbbSlZPQ3S0rK2",
                                         "imageHeight": 1125,
                                         "imageWidth":1125,
                                         "imageUrl": "https://firebasestorage.googleapis.com/v0/b/fleckchat.appspot.com/o/message_images%2FECB7B3F5-2AF3-47A8-A9A5-73C23316A3E6?alt=media&token=ef00432e-8e62-4b94-9a52-fa49c519928a",
                                         "timestamp": 1522144647,
                                         "toID": "HDIhsHdwRvSnFR6mm1GiRD5WaiZ2"]
        let message = Message(dictionary: dictionary)
        
        XCTAssertNil(message.videoUrl)
        XCTAssertNil(message.text)
    }
    
}
