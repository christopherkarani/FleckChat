//
//  ChatMessageCell.swift
//  Fleck
//
//  Created by Christopher Karani on 12/03/2018.
//  Copyright © 2017 Christopher Karani. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SafariServices
import CoreLocation
import EventKit
import EventKitUI
import Toaster
import SCLAlertView

public class ChatMessageCell: UICollectionViewCell {
    
    //MARK: Class Properties
    internal let eventStore = EKEventStore()
    internal weak var alertView : SCLAlertView?
    internal var playerLayer : AVPlayerLayer?
    internal var bubbleWidthAnchor: NSLayoutConstraint?
    internal var bubbleViewXAnchor: NSLayoutConstraint?
    internal var message: Message?
    internal weak var chatDelegate : ChatControllerDelegate?
    internal var eventTitleTextfield : UITextField?
    internal var eventNoteTextField: UITextField?
    
    lazy var appearance = SCLAlertView.SCLAppearance(
        kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
        kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
        showCloseButton: false,
        hideWhenBackgroundViewIsTapped: false
    )
    
    // referance to collectionView controller for later User
    weak var collectionViewController : UICollectionViewController?
    
    lazy var datePicker : UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.timeZone = NSTimeZone.local
        //datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    //Observer that updates datePickerDate property for use in Event Handler
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        // Create date formatter
        datePickerDate = sender.date
    }
    
    var datePickerDate: Date? {
        didSet {
            print(datePickerDate!.description)
        }
    }

    public var messageLabel: MessageLabel = {
       let messageLabel = MessageLabel()
        messageLabel.enabledDetectors = [DetectorType.address, DetectorType.date, DetectorType.url, DetectorType.phoneNumber]
        messageLabel.textInsets = UIEdgeInsets(top: 8, left: 2, bottom: -1, right: 3)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.preferredFont(forTextStyle: .body)
        messageLabel.isUserInteractionEnabled = true
        return messageLabel
    }()

    public let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public lazy var messageImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoom(withTap:))))
        return imageView
    }()
    
    var bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var playButton: UIButton = {
       let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "play")
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    

    
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadSubviews()
        setupConstraints()
        messageLabel.delegate = self
        setupGestureRecognizers()

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
    }
    
    //Target action, handle Play button inside message, in the case of a video
    @objc private func handlePlay() {
        if let videoStringURL = message?.videoUrl {
            guard let url = URL(string: videoStringURL) else { return }
            let player = AVPlayer(url: url)
            let playerController = AVPlayerViewController()
            playerController.player = player
            playButton.isHidden = true
            chatDelegate?.presentViewControler(playerController, completion: {
                playerController.player!.play()
            })
        }
    }
    
    @objc func handleZoom(withTap tap: UITapGestureRecognizer) {
        if let imageView = tap.view as? UIImageView {
            chatDelegate?.performZoom(forStartingImage: imageView)
        }
    }
    
    //MARK: Methods
    private func setupConstraints() {
        messageLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        messageLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        messageLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        messageLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        
        //BubbleView Constraints
        bubbleViewXAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewXAnchor?.isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //ProfileImageview Constraints
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    private func loadSubviews() {
        contentView.addSubview(bubbleView)
        contentView.addSubview(messageLabel)
        contentView.addSubview(profileImageView)
        bubleViewSubviews()
    }
    
    fileprivate func bubleViewSubviews() {
        bubbleView.addSubview(messageImageView)
        bubbleView.addSubview(playButton)
    }

    func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGesture.delaysTouchesBegan = true
        messageLabel.addGestureRecognizer(tapGesture)
    }
    
    
    // add Actionable Gesture to Message Label
    @objc open func handleTapGesture(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .ended else { return }
        let touchPositon = gesture.location(in: messageLabel)
        messageLabel.handleGesture(touchPositon)
    }
}

// delegate method handling taps to actionable messages
extension ChatMessageCell: MessageLabelDelegate {

    public func didSelectURL(_ url: URL) {
        let browser = SFSafariViewController(url: url)
        collectionViewController?.present(browser, animated: true, completion: nil)
        return
    }
    

    // this will not work on the simulator
    public func didSelectPhoneNumber(_ phoneNumber: String) {
        callPhoneNumber(phoneNumber: phoneNumber)
    }
    
    //Handle Message action for Selected Phone Number: present the option to call the selected Phone number
    private func callPhoneNumber(phoneNumber:String) {
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    application.openURL(phoneCallURL) // older than ios 10
                }
            }
        }
    }

    
    //Handle Message action for Selected Date: present the User Interface when setting Events
    private func setupAlertView(withDate date: Date) {
        //Setup UI
        let title = "Event"
        let subtitle = "Add an event to your calender"
        let closeButtonTitle = "Finish"
        let colorStyle : UInt = SCLAlertViewStyle.notice.defaultColorInt
        //let colorText : UInt = SCLAlertViewStyle.success.defaultColorInt
        let image = #imageLiteral(resourceName: "calendar")
        let animation = SCLAnimationStyle.bottomToTop

        let alertView = SCLAlertView(appearance: appearance)
        eventNoteTextField?.translatesAutoresizingMaskIntoConstraints = false
        eventTitleTextfield?.translatesAutoresizingMaskIntoConstraints = false
        
        eventTitleTextfield = alertView.addTextField("Event Title")
        eventNoteTextField = alertView.addTextField("Event Note")
        
        alertView.customSubview = datePicker
        if let customView = alertView.customSubview {
            datePicker.frame = customView.frame
        }
        
        
        _ = alertView.addButton("Finish", action: { [unowned self] in
            guard let eventString = self.eventTitleTextfield?.text, let eventNote = self.eventNoteTextField?.text else {return}
            self.setupEvent(withTitile: eventString, eventNote, date)
            self.alertView?.becomeFirstResponder()
            if self.collectionViewController?.isFirstResponder == false {
                self.collectionViewController?.becomeFirstResponder() // Must return collectionView to first responder
            }
        })
        
        alertView.showInfo(title, subTitle: subtitle, closeButtonTitle: closeButtonTitle, colorStyle: colorStyle, circleIconImage: image, animationStyle: animation)
    }
    
    //Handle Message action for Selected Date: The logic needed to set Events inside IOS Callender
    private func setupEvent(withTitile title: String, _ note: String, _ date: Date) {
        let event:EKEvent = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = date
        event.endDate = datePickerDate ?? Date().tomorrow
        event.notes = note
        event.calendar = eventStore.defaultCalendarForNewEvents
        do {
            try eventStore.save(event, span: .thisEvent)
        } catch let error {
            let errorToast = Toast(text: error.localizedDescription)
            errorToast.show()
            print("failed to save event with error : \(error)")
        }
        
        let successToast = Toast(text: "Succesfully Set Event")
        successToast.show()
    }

    public func didSelectDate(_ date: Date) {
        setupAlertView(withDate: date)
    }
    
    //Handle Message action for Selected Address: The logic needed to Open Apple Maps and retrieve specified address
    public func didSelectAddress(_ addressComponents: [String : String]) {
        print(addressComponents)
        let geocoder = CLGeocoder()
        let str = "Kirichwa Lane, Nairobi" // Sendy location Default
        geocoder.geocodeAddressString(str) { (placemarksOptional, error) -> Void in
            if let placemarks = placemarksOptional {
                print("placemark| \(String(describing: placemarks.first))")
                if let location = placemarks.first?.location {
                    let query = "?ll=\(location.coordinate.latitude),\(location.coordinate.longitude)"
                    let path = "http://maps.apple.com/" + query
                    if let url = URL(string: path) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { (true) in
                                print("SUCCESS")
                            })
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    } else {
                        // Could not construct url. Handle error.
                    }
                } else {
                    // Could not get a location from the geocode request. Handle error.
                }
            } else {
                let toast =  Toast(text: "Failed to find your location, Please try again")
                toast.show()
                return
            }
        }
    }
}
