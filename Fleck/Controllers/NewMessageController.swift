//
//  NewMessageController.swift
//  Fleck
//
//  Created by chris karani on 26/10/2017.
//  Copyright © 2017 Neptune. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    var users = [LocalUser]()
    var cellID = "CellID"
    var conversationsDelegate: ConversationsControllerDelegate?
    var chatController: ChatController?
    var heightForRows: CGFloat = 70
    
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchUsers()
        setupNavigationItem()
    }
    
    
    func fetchUsers() {
        let ref = FirebaseNode.shared.userNode()
        ref.observe(.childAdded) { (snapshot) in
            self.setupDictionary(withSnapshot: snapshot)
        }
        
    }
    private func setupDictionary(withSnapshot snapshot: (DataSnapshot)) {
        if let dictionary = snapshot.value as? [String: AnyObject] {
            var user = LocalUser()
            user.id = snapshot.key
            user.name = dictionary["name"] as? String
            user.email = dictionary["email"] as? String
            user.profileImageURL = dictionary["profileImageUrl"] as? String
            self.users.append(user)
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }
    
    func setupNavigationItem() {
        let cancleButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem = cancleButton
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: DELEGATE
extension NewMessageController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myUser = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! UserCell
        let customCell = cellSetup(forUser: myUser, withUserCell: cell)
        return customCell
    }
    
    private func cellSetup(forUser user: LocalUser, withUserCell cell : UserCell) -> UITableViewCell {
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        if let profileImageURL = user.profileImageURL {
            cell.profileImageView.loadImageUsingCache(withURLString: profileImageURL)
        }
        return cell
    }
    
    //MARK: Present ChatController, From Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.conversationsDelegate?.showChatController(forUser: user)
        }
    }
}
//MARK: DATASOURCE
extension NewMessageController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRows
    }
}
