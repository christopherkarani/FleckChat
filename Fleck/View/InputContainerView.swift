//
//  InputContainerView.swift
//  Fleck
//
//  Created by Christopher Karani on 12/03/2018.
//  Copyright © 2017 Christopher Karani. All rights reserved.
//

import UIKit


public class InputContainerView: UIView {
    
    //MARK: Properties
    weak var chatDelegate : ChatControllerDelegate?
    
    weak var chatController : ChatController? {
        didSet {
            guard let chatController = chatController else { return }
            name = chatController.user?.name!
            sendButton.addTarget(chatController, action: #selector(chatController.handleSend), for: .touchUpInside)
            imageViewTouchArea.addGestureRecognizer(UITapGestureRecognizer(target: chatController, action: #selector(chatController.handleUploadImage)))
        }
    }
    
    private var name: String? {
        didSet {
            if let name = name {
                inputTextField.placeholder = "Send a message to \(String(describing: name))..."
            }
        }
    }
    
    //MARK: User Interface properties
    private let seperatorLine = SeparatorLine()
    
    open lazy var inputTextField : UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let uploadImageView: UIImageView = {
        let uploadImageView = UIImageView()
        uploadImageView.image = Theme.UploadImage
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        return uploadImageView
    }()
    
    private let imageViewTouchArea : UIView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    //MARK: private methods
    
    fileprivate func setupBackgroundView() {
        //RGB: 0, 172, 237
        backgroundColor = .white
    }
    
    fileprivate func addSubViews() {
        addSubview(sendButton)
        addSubview(inputTextField)
        addSubview(imageViewTouchArea)
        imageViewTouchArea.addSubview(uploadImageView)
        addSubview(seperatorLine)
    }
    
    fileprivate func setupConstraints() {
        NSLayoutConstraint.activate([
            imageViewTouchArea.leftAnchor.constraint(equalTo: leftAnchor),
            imageViewTouchArea.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageViewTouchArea.widthAnchor.constraint(equalToConstant: 44),
            imageViewTouchArea.heightAnchor.constraint(equalToConstant: 44)
            ])
        
        NSLayoutConstraint.activate([
            uploadImageView.leftAnchor.constraint(equalTo: imageViewTouchArea.leftAnchor, constant: 14),
            uploadImageView.centerYAnchor.constraint(equalTo: imageViewTouchArea.centerYAnchor),
            uploadImageView.widthAnchor.constraint(equalToConstant: 28),
            uploadImageView.heightAnchor.constraint(equalToConstant: 28)
            ])
        
        NSLayoutConstraint.activate([
            sendButton.rightAnchor.constraint(equalTo: rightAnchor),
            sendButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 70),
            sendButton.heightAnchor.constraint(equalTo: heightAnchor)
            ])
        
        NSLayoutConstraint.activate([
            inputTextField.leftAnchor.constraint(equalTo: imageViewTouchArea.rightAnchor, constant: 8),
            inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor),
            inputTextField.heightAnchor.constraint(equalTo: heightAnchor)
            ])
        
        NSLayoutConstraint.activate([
            seperatorLine.rightAnchor.constraint(equalTo: rightAnchor),
            seperatorLine.bottomAnchor.constraint(equalTo: topAnchor),
            seperatorLine.widthAnchor.constraint(equalTo: widthAnchor),
            seperatorLine.heightAnchor.constraint(equalToConstant: 0.5)
            ])
    }
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackgroundView()
        addSubViews()
        setupConstraints()
    }
    
    deinit {
        print("Input View Deallocated")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: Textfield Delegate Methods
extension InputContainerView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatController?.handleSend()
        return true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}


