//
//  DetectorType.swift
//  Fleck
//
//  Created by Chris Karani on 3/20/18.
//  Copyright © 2018 Neptune. All rights reserved.
//

import Foundation

public enum DetectorType {
    
    case address
    case date
    case phoneNumber
    case url

    var textCheckingType: NSTextCheckingResult.CheckingType {
        switch self {
        case .address: return .address
        case .date: return .date
        case .phoneNumber: return .phoneNumber
        case .url: return .link
        }
    }
}
