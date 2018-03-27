//
//  LocalUserTest.swift
//  FleckUnitTests
//
//  Created by Chris Karani on 3/27/18.
//  Copyright © 2018 Neptune. All rights reserved.
//

import XCTest
@testable import Fleck

class LocalUserTest: XCTestCase {
    
    
    var localUser: LocalUser!
    override func setUp() {
        super.setUp()
        let dictionary : [String: Any] = ["email": "drake@gmail.com",
                                          "name": "Drake",
                                          "profileImageUrl": "https://firebasestorage.googleapis.com/v0/b/fleckchat.appspot.com/o/Profile_Images%2FA67ABA98-E65D-4273-894E-C201221B8E8F.jpg?alt=media&token=138f5199-a3d1-42ad-bc20-fc31dbfc60b8"]
        
        localUser = LocalUser(dictionary)
    }
    
    override func tearDown() {
        localUser = nil
        
        super.tearDown()
    }
    
    func test_SetUserProperties() {
        let expectedEmail = "drake@gmail.com"
        let expectedProfileImageUrl = "https://firebasestorage.googleapis.com/v0/b/fleckchat.appspot.com/o/Profile_Images%2FA67ABA98-E65D-4273-894E-C201221B8E8F.jpg?alt=media&token=138f5199-a3d1-42ad-bc20-fc31dbfc60b8"
        let expectedUserName = "Drake"
        XCTAssertEqual(localUser.email, expectedEmail)
        XCTAssertEqual(localUser.profileImageURL, expectedProfileImageUrl)
        XCTAssertEqual(localUser.name, expectedUserName)
    }
    
    
    func test_SetUserIDProperty() {
        let expectedID = "2343456"
        localUser.id = expectedID
        XCTAssertEqual(localUser.id, expectedID)
    }
}
