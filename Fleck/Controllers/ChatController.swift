//
//  ChatViewController.swift
//  Fleck
//
//  Created by macuser1 on 23/10/2017.
//  Copyright © 2017 Neptune. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation
import Toaster

@objc protocol ChatControllerDelegate: class {
    func performZoom(forStartingImage imageView: UIImageView)
    func presentViewControler(_ viewController: UIViewController, completion: @escaping () -> Void )
    @objc func handleSend()
    @objc func handleTapZoom(withTap tap : UITapGestureRecognizer)
    func handleUploadImage()
}

class ChatController: UICollectionViewController {
    
    private func identifier() -> String {
        return "cellID"
    }
    
    var user : LocalUser? {
        didSet {
            navigationItem.title = user?.name
            observerMessages()
        }
    }

    var messages = [Message]()
    
    private var startingFrame: CGRect?
    private var backgroundView: UIView?
    private var startingImageView: UIImageView?
    var containerViewBottomAnchor: NSLayoutConstraint?
    

    lazy var inputContainerView : InputContainerView = {
        let containerView = InputContainerView()
        let viewHeight : CGFloat = 50
        let width = UIScreen.main.bounds.width
        containerView.frame = CGRect(x: 0, y: 0, width: width, height: viewHeight)
        containerView.chatController = self
        containerView.chatDelegate = self
        return containerView
    }()
    
    func inputContainerViewSetup() {

        
    }

    //MARK: Viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8 , right: 0)
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: identifier())
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        setupKeyboardObservers()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.becomeFirstResponder()
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    ///Observes The messages node and appends thoe messages to the 'messages' Array
    func observerMessages() {
        var messagesArray = [Message]()
        guard let uid = Auth.auth().currentUser?.uid, let toID = user?.id else { return }
        
        let userMessageRef = FirebaseNode.shared.userMessagesNode(toChild: uid, anotherChild: toID)
        userMessageRef.observe(.childAdded) { (snapshot) in
            let messageID = snapshot.key
            let messageRef = FirebaseNode.shared.messagesNode(toChild: messageID)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let message = Message(dictionary: dictionary)
                messagesArray.append(message)
                
                DispatchQueue.main.async { [unowned self] in
                    self.messages = messagesArray
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    if self.messages.count >= 1 {
                        self.collectionView?.reloadData()
                        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    }
                }
            })
        }
    }
    //MARK: SEND FUNCTION
    ///Handles Sending to the Firebase database. Messages are stored inside the "messages" node
    ///Messages recieve a unique ID via 'childByAutoId()'
    @objc func handleSend() {
        guard let inputText = inputContainerView.inputTextField.text, !inputText.isEmpty else {
            print("no text")
            return
        }
        let properties: [String : Any] = ["text": inputText]
        sendMessage(withProperties: properties)
    }

}


// DataSource
extension ChatController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier() , for: indexPath) as! ChatMessageCell

        let message = messages[indexPath.item]
        cell.messageLabel.text = message.text
        cell.message = message
        cell.collectionViewController = self
        setupCell(withCell: cell, andMessage: message)
        
        if let text = message.text {
            let padding: CGFloat = 32
            cell.bubbleWidthAnchor?.constant = estimatedFrame(forText: text).width + padding
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
        }

        return cell
    }
    
    func setupCell(withCell cell: ChatMessageCell, andMessage message: Message) {
        cell.chatDelegate = self
        
        if let profileImageURL = self.user?.profileImageURL {
            cell.profileImageView.loadImageUsingCache(withURLString: profileImageURL)
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        if let messageURL = message.imageUrl {
            cell.bubbleView.backgroundColor = .clear
            cell.messageImageView.loadImageUsingCache(withURLString: messageURL)
            cell.messageImageView.isHidden = false
            cell.messageLabel.isHidden = true
        } else {
            cell.messageImageView.isHidden = true
            cell.messageLabel.isHidden = false
        }
        
        //Outgoing 
        if message.fromID == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = Theme.chatBubbleOutgoingGreen
            cell.messageLabel.textColor = .white
            cell.bubbleViewXAnchor?.isActive = false
            cell.bubbleViewXAnchor = cell.bubbleView.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -8)
            cell.bubbleViewXAnchor?.isActive = true
            cell.profileImageView.isHidden = true
            //Incoming
        } else {
            cell.bubbleViewXAnchor?.isActive = false
            cell.bubbleViewXAnchor = cell.bubbleView.leftAnchor.constraint(equalTo: cell.profileImageView.rightAnchor, constant: 8)
            cell.bubbleViewXAnchor?.isActive = true
            cell.bubbleView.backgroundColor = Theme.chatBubbleIncomingGray
            cell.messageLabel.textColor = .darkText
            cell.profileImageView.isHidden = false
        }
    }
}
// Delegate Methods
extension ChatController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height : CGFloat = 80
        let padding: CGFloat = 20
        let message =  messages[indexPath.item]
        if let text = message.text {
            height = estimatedFrame(forText: text).height + padding
        } else if let imageHeight = message.imageHeight, let imageWidth = message.imageWidth {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
       return CGSize(width: view.frame.width, height: height)
    }
    
    func estimatedFrame(forText text: String) -> CGRect {
        // width is same as cell.texView width
        //height is an arbitrary larg value
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
        return  NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout() // good fix when using constraints
    }
}
// Keyboard Logic
extension ChatController {
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(withNotification:)), name: .UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(withNotification:)), name: .UIKeyboardDidHide, object: nil)
    }
    @objc func handleKeyboardDidShow() {
        let indexPath = IndexPath(item: messages.count - 1, section: 0)
        if messages.count >= 1 {
                collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
     
    }
    @objc func handleKeyboardWillShow(withNotification notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containerViewBottomAnchor?.constant = -(keyboardFrame?.height)!
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    @objc func handleKeyboardWillHide(withNotification notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    //Invalidate Notification Observers
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}

// Accesory View
extension ChatController {
    override var inputAccessoryView: UIView? {
        get {
           return inputContainerView
        }
    }
    // if we dont set this, accesorry view is not visibile
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
//ImagePicker
extension ChatController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func handleUploadImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.mediaTypes = [String(describing: kUTTypeImage) ,String(describing:kUTTypeMovie)]
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            //we selected a video
            handleSelectedVideo(withUrl: videoUrl)
        } else {
            //we selected an image
            let image = handleSelectImage(withInfo: info)
            handleUploadToFirebase(withImage: image, completion: { (imageUrl) in
                self.handleSendImage(withUrlString: imageUrl, andImage: image)
            })
        }
    }
    
    func handleSelectImage(withInfo info : [String: Any]) ->  UIImage {
        var selectedImage : UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        }
        return selectedImage!
    }
    
    func handleSelectedVideo(withUrl url: URL) {
        self.dismiss(animated: true, completion: nil)
            let fileName = "\(UUID().uuidString).mov"
            let ref = Storage.storage().reference().child("Chat_Message_Videos").child(fileName)
            let uploadTask = ref.putFile(from: url, metadata: nil, completion: { [unowned self] (metadata, error) in
                
                if let error = error {
                    let errorToast = Toast(text: error.localizedDescription)
                    errorToast.show()
                    return
                }
                if let videoUrl = metadata?.downloadURL()?.absoluteString {
                    if let thumbnailImage = self.thumbnail(forImageUrl: url) {
                        self.handleUploadToFirebase(withImage: thumbnailImage, completion: { (imageUrlString) in
                            let properties : [String: Any] =  ["videoUrl": videoUrl, "imageWidth": thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height, "imageUrl": imageUrlString]
                            self.sendMessage(withProperties: properties)
                        })
                    }
                }
            })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount,
                let totalUnitCount = snapshot.progress?.totalUnitCount {
                let uploadPercentage : Float64 = Float64(completedUnitCount) * 100 / Float64(totalUnitCount)
                self.navigationItem.title = String(format: "%.0f", uploadPercentage) + " %"
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
        
    }
    
    private func thumbnail(forImageUrl url : URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let image = AVAssetImageGenerator(asset: asset)
        
        do {
            let imageCGI = try image.copyCGImage(at: CMTime.init(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: imageCGI)
        } catch let err {
            print(err)
        }
        return nil
    }

    func handleUploadToFirebase(withImage image: UIImage, completion: ((_ imageUrl: String) -> Void)?) {
        guard let imageData = UIImageJPEGRepresentation(image, 0.2) else {
            fatalError("Unable To convert image to data")
        }
        let ref = FirebaseNode.shared.uploadMesaageImageNode(toStorage: true)
        ref.putData(imageData, metadata: nil) { [unowned self] (metadata, error) in
            if let error = error {
                let errorToast = Toast(text: error.localizedDescription)
                errorToast.show()
                return
            }
            
            if let imageUrlString = metadata?.downloadURL()?.absoluteString {
                completion?(imageUrlString)
            }
            
            self.dismiss(animated: true, completion: nil)
       
        }
        
    }
    
    private func handleSendImage(withUrlString urlString: String, andImage image: UIImage) {
        let properties: [String: Any] = ["imageUrl": urlString, "imageWidth": image.size.width, "imageHeight":image.size.height]
        sendMessage(withProperties: properties)
    }
    
    func sendMessage(withProperties properties : [String: Any]) {
        let messageRef = FirebaseNode.shared.messagesNode()
        let childRef = messageRef.childByAutoId()
        let toID = user!.id!
        let fromID = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        var values: [String : Any] = ["toID": toID, "fromID": fromID, "timestamp": timestamp,]
        properties.forEach({values[$0.key] = $0.value})
                                      
        childRef.updateChildValues(values) {[unowned self] (error, ref) in
            if let error = error {
                let errorToast = Toast(text: error.localizedDescription)
                errorToast.show()
                return
            }
            self.inputContainerView.inputTextField.text = nil
            let userMessageRef = FirebaseNode.shared.userMessagesNode(toChild: fromID, anotherChild: toID)
            let messageID = childRef.key
            userMessageRef.updateChildValues([messageID: 1])
            
            let recipientUserMessageRef = FirebaseNode.shared.userMessagesNode(toChild: toID, anotherChild: fromID)
            recipientUserMessageRef.updateChildValues([messageID: 1])
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//handle zoom on tap image
extension ChatController: ChatControllerDelegate {
    
    
    func presentViewControler(_ viewController: UIViewController, completion:  @escaping () -> Void) {
        present(viewController, animated: true, completion: nil)
        completion()
    }
    
    //MARK: PRESENTVIEWCONTROLLER
    func performZoom(forStartingImage imageView: UIImageView) {
        startingImageView = imageView
        startingImageView?.isHidden = true
        startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = .blue
        zoomingImageView.image = imageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapZoom(withTap:))))

        if let keyWindow = UIApplication.shared.keyWindow {
            backgroundView = UIView(frame: keyWindow.frame)
            backgroundView?.backgroundColor = .black
            backgroundView?.alpha = 0
            keyWindow.addSubview(backgroundView!)
            keyWindow.addSubview(zoomingImageView)

            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.backgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: nil  )
        }
    }
    
    @objc func handleTapZoom(withTap tap : UITapGestureRecognizer) {
        if let zoomOutImageView = tap.view {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.backgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed: Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
}


