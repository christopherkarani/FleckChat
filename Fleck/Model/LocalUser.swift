//
//  User.swift
//  Fleck
//
//  Created by Christopher Karani on 12/03/2018.
//  Copyright © 2017 Christopher Karani. All rights reserved.
//

import Foundation

// The User Object used inside The App. 
public struct LocalUser {
    public var id: String?
    private(set) var name: String?
    private(set) var email: String?
    private(set) var profileImageURL: String?
    
    init(_ values: [String:Any] ) {
        name = values["name"] as? String
        email = values["email"] as? String
        profileImageURL = values["profileImageUrl"] as? String
    }
}
