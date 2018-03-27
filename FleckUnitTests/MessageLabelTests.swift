//
//  MessageLabelTests.swift
//  FleckUnitTests
//
//  Created by Chris Karani on 3/27/18.
//  Copyright © 2018 Neptune. All rights reserved.
//

import XCTest
@testable import Fleck

class MessageLabelTests: XCTestCase {
    
    var messageLabel: MessageLabel!

    override func setUp() {
        super.setUp()
        messageLabel = MessageLabel()
       
    }
    
    override func tearDown() {
        messageLabel = nil
        super.tearDown()
    }
    
    //MARK: Check Synchornisation between attributedText and text
    func test_SynchronizationBetweenTextAndAttributedText() {
        let expectedText = "Some Text"
        messageLabel.attributedText = NSAttributedString(string: expectedText)
        XCTAssertEqual(messageLabel.text, expectedText)
    }
    
    func test_WhenAttributedTextIsNilUpdateTextToNil() {
        messageLabel.text = "Not Nil"
        messageLabel.attributedText = nil
        XCTAssertNil(messageLabel.text)
    }
    
    func test_WhenTextIsSetUpdateAttributedText() {
       let expectedText = "Some Text"
        messageLabel.text = expectedText
        XCTAssertEqual(messageLabel.attributedText?.string, expectedText)
    }
    
    func test_WhenTextIsNilUpdateAttributedText() {
        messageLabel.attributedText = NSAttributedString(string: "Not Nil")
        messageLabel.text = nil
        XCTAssertNil(messageLabel.attributedText)
    }
    
    //check for address detection
    func test_AddressDetectionEnabled() {
        let expectedColor = UIColor.blue
        messageLabel.addressAttributes = [.foregroundColor: expectedColor]
        messageLabel.text = "One Infinite Loop Cupertino, CA 95014"
        messageLabel.enabledDetectors = [.address]
        let attributes = messageLabel.addressAttributes
        let textColor = attributes[.foregroundColor] as? UIColor
        XCTAssertEqual(textColor, expectedColor)
    }
    
    //check phone number detection
    func test_PhoneNumberDetectionEnabled() {
        let expectedColor = UIColor.red
        messageLabel.phoneNumberAttributes = [.foregroundColor: expectedColor]
        messageLabel.text = "0706984106"
        let  attributes = messageLabel.phoneNumberAttributes
        let textColor = attributes[.foregroundColor] as? UIColor
        XCTAssertEqual(textColor, expectedColor)
    }
    
    //check Url detection
    func test_UrlDetectedEnabled() {
        let expectedColor = UIColor.magenta
        messageLabel.urlAttributes = [.foregroundColor:expectedColor]
        messageLabel.text = "https://sendyit.com"
        let attributes = messageLabel.urlAttributes
        let textColor = attributes[.foregroundColor] as? UIColor
        XCTAssertEqual(textColor, expectedColor)
    }
    
    func test_DateTextDetectionEnabled() {
        let expectedColor = UIColor.yellow
        messageLabel.dateAttributes = [.foregroundColor: expectedColor]
        messageLabel.text = "Today"
        let attributes = messageLabel.dateAttributes
        let textColor = attributes[.foregroundColor] as? UIColor
        XCTAssertEqual(textColor, expectedColor)
    }
  
}
