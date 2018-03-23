//
//  MessageTextLabelDelegate.swift
//  Fleck
//
//  Created by Chris Karani on 3/20/18.
//  Copyright © 2018 Neptune. All rights reserved.
//

import Foundation

public protocol MessageLabelDelegate: AnyObject {
    
    func didSelectAddress(_ addressComponents: [String: String])
    
    func didSelectDate(_ date: Date)
    
    func didSelectPhoneNumber(_ phoneNumber: String)
    
    func didSelectURL(_ url: URL)
    
}

public extension MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {}
    
    func didSelectDate(_ date: Date) {}
    
    func didSelectPhoneNumber(_ phoneNumber: String) {}
    
    func didSelectURL(_ url: URL) {}
    
}
