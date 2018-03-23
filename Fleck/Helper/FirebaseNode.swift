//
//  FDNodeRef.swift
//  Fleck
//
//  Created by macuser1 on 04/11/2017.
//  Copyright © 2017 Neptune. All rights reserved.
//

import Foundation
import Firebase

final class FirebaseNode {
    
    static let shared = FirebaseNode()
    
    private init() {}
    
    var loggedIn: Bool {
        return Auth.auth().currentUser != nil ? true : false 
    }
    
    static var currentUserUID : String = Auth.auth().currentUser!.uid
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    func returnRootNode() -> DatabaseReference {
        return Database.database().reference()
    }
    
    /// returns the 'DatabaseReference' of "users" Node Reference inside of your Firebase Database
    func userNode(toChild: String? = nil) -> DatabaseReference {
        let ref = Database.database().reference().child("users")
        if let child = toChild { return ref.child(child) }
        return  ref
    }
    
    /// returns the 'StorageReference' of "message_images" Node Reference inside of your Firebase Storage
    func uploadMesaageImageNode(toStorage: Bool) -> StorageReference {
        switch toStorage {
        case true:
            let randomString = UUID().uuidString
            return Storage.storage().reference().child("message_images").child(randomString)
        default:
            return Storage.storage().reference().child("message_images")
        }
    }
    
    func messagesNode(toChild: String? = nil) -> DatabaseReference {
        let ref = Database.database().reference().child("messages")
        if let child = toChild { return ref.child(child)  }
        return  ref
    }
    
    func userMessagesNode(toChild: String? = nil, anotherChild: String? = nil) -> DatabaseReference {
        let ref = Database.database().reference().child("user-messages")
        if let child = toChild {
            let childRef = ref.child(child)
            if let secondChild = anotherChild {
                return childRef.child(secondChild)
            }
            return childRef
        }
        return ref
    }
    
    func profileImagesStorageRef(toStoragePath: Bool) -> StorageReference {
        let ref = Storage.storage().reference().child("Profile_Images")
        switch toStoragePath {
        case true:
            let imageName = UUID().uuidString
            return ref.child("\(imageName).jpg")
        case false:
           return ref
        }
    }
    
}
