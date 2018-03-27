//
//  UserCell.swift
//
//  Created by Christopher Karani on 21/03/2018
//  Copyright © 2018 Christopher Karani. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    //Message Object used for setting Certain Class Properties
    open var message : Message? {
        didSet {
            setupMessage(withMessageObject: message)
        }
    }
    


    
    open let timeLabel: UILabel = {
       let timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 11)
        timeLabel.textColor = UIColor.lightGray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        return timeLabel
    }()
    
    open let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 24
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    private func checkType(forMessage message: Message) {
        if message.videoUrl != nil {
            detailTextLabel?.text = "🎥"
        } else if message.imageUrl != nil {
            detailTextLabel?.text = "📷"
        } else {
            detailTextLabel?.text = message.text
        }
    }
    
    private func setupNameAndProfileImage(withMessage message: Message) {
        if let id = message.chatPartnerID() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                guard let strongSelf = self else { return }
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    strongSelf.textLabel?.text = dictionary["name"] as? String
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        strongSelf.profileImageView.loadImageUsingCache(withURLString: profileImageUrl)
                    }
                }
                }, withCancel: nil)
        }
    }
    
    private func setupMessage(withMessageObject message: Message?) {
        guard let message = message else { return }
        setupNameAndProfileImage(withMessage: message)
        checkType(forMessage: message)
        if let seconds = message.timeStamp {
            let timeStampDate = Date(timeIntervalSince1970: TimeInterval(seconds))
            let timeString = Date().timeAgoSinceDate(date: timeStampDate as NSDate, numericDates: false)
            timeLabel.text = timeString
        }
    }
    
    
    private func setupConstrainsts() {
        NSLayoutConstraint.activate([
            profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
            profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalToConstant: 48)
            ])

        let myTextLabel = textLabel ?? UILabel()
        NSLayoutConstraint.activate([
            timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            timeLabel.widthAnchor.constraint(equalToConstant: 80),
            timeLabel.heightAnchor.constraint(equalTo: myTextLabel.heightAnchor)
            ])
    }
    private func addViewsToCell() {
        addSubview(profileImageView)
        addSubview(timeLabel)
    }
    
    //MARK: LAYOUT SUBVIEWS
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let label = textLabel else { return }
        guard let detailLabel = detailTextLabel else { return }
        
        label.frame = CGRect(x: 60,
                                  y: textLabel!.frame.origin.y,
                                  width: textLabel!.frame.width,
                                  height: textLabel!.frame.height - 2)
        detailLabel.frame =  CGRect(x: 60,
                                         y: detailTextLabel!.frame.origin.y,
                                         width: detailTextLabel!.frame.width,
                                         height: detailTextLabel!.frame.height + 2)
    }
    
    
    // MARK: INIT
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addViewsToCell()
        setupConstrainsts()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
