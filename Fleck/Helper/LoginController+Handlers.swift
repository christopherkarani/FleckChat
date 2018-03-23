//
//  LoginController+Handlers.swift
//  Fleck
//
//  Created by macuser1 on 26/10/2017.
//  Copyright © 2017 Neptune. All rights reserved.
//

import UIKit
import Firebase
import Toaster

//ImagePicker Extension
extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Handle ImagePicker
    @objc public func handleProfileImagePicker() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage : UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        }
        if let image = selectedImage {
            profileImageSelector.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: handle Login/Register
extension LoginViewController {
    
    @objc public func handleLoginRegister() {
        loginRegisterButton.setTitle(nil, for: .normal)
        activityIndicatorView.startAnimating()
        if loginRegisterSegementedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    // MARK: Handle Login
    func handleLogin() {
        guard let email = emailTextField.text else {
            let toast = Toast(text: "Enter Email")
            toast.show()
            return
        }
        guard let password = passwordTextField.text else {
            let toast = Toast(text: "Enter Password")
            toast.show()
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [unowned self] (user, error) in
            if let error = error {
                self.activityIndicatorView.stopAnimating()
                let errorToast = Toast(text: error.localizedDescription)
                errorToast.show()
                return
            }
            
            self.delegate?.fetchUserSetupNavigationBar()
            self.dismiss(animated: true, completion: { [unowned self] in
                self.activityIndicatorView.stopAnimating()
                self.loginRegisterButton.setTitle(self.loginRegisterButtonTittle, for: .normal)
            })
        }
    }
    
    fileprivate func stopAnimatingActivityIndicator() {
        activityIndicatorView.stopAnimating()
    }
    
    //MARK: HandleRegister
    internal func handleRegister() {
        guard let email = emailTextField.text else {
            let toast = Toast(text: "Enter Email")
            toast.show()
            return
        }
        guard let password = passwordTextField.text else {
            let toast = Toast(text: "Enter Password")
            toast.show()
            return
        }
        guard let name = nameTextField.text else {
            let toast = Toast(text: "Enter Nmail")
            toast.show()
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [unowned self] (user: User?, error) in
            if let error = error {
                let toast = Toast(text: error.localizedDescription)
                toast.show()
                self.activityIndicatorView.stopAnimating()
                self.loginRegisterButton.setTitle("Register", for: .normal)
                return
            }
            
            guard let uid = user?.uid else {
                Toast(text: "shomething went wrong, try again").show()
                return
            }
            
            guard  let profileImage = self.profileImageSelector.image,
                let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) else {
                let toast = Toast(text: "Something went wrong")
                    toast.show()
                return
                    
            }
            let storageRef = FirebaseNode.shared.profileImagesStorageRef(toStoragePath: true)
            storageRef.putData(uploadData, metadata: nil, completion: { [unowned self] (metadata, error) in
                if let error = error {
                    let toast = Toast(text: error.localizedDescription)
                    toast.show()
                    return
                }

                guard let profileImageURL = metadata?.downloadURL()?.absoluteString else {
                    let toast = Toast(text: "Not a valid profile Image Url")
                    toast.show()
                    return
                }
                let values = ["name": name, "email": email, "profileImageUrl": profileImageURL]
                self.registerUserIntoDatabase(withUID: uid, andValues: values)
                let successToast = Toast(text: "Welcome \(name) you have successfully registered withe the email \(email)", delay: 2, duration: 4)
                successToast.show()
            })
        }
    }
    
     /// Register Users to database
    internal func registerUserIntoDatabase(withUID id: String, andValues values: [String:String]) {
        let usersRef = FirebaseNode.shared.userNode().child(id)
        usersRef.updateChildValues(values, withCompletionBlock: { [unowned self] (error, ref) in
            if let error = error {
                let toast = Toast(text: error.localizedDescription)
                toast.show()
                return
            }

            var user = LocalUser()
            user.name = values["name"]
            user.email = values["email"]
            user.profileImageURL = values["profileImageURL"]
            self.delegate?.setupNavigationBar(withUser: user)
            //self.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: {
                self.activityIndicatorView.stopAnimating()
                self.loginRegisterButton.setTitle(self.loginRegisterButtonTittle, for: .normal)
            })
        })
    }
    
    fileprivate func handleLoginRegisterTitle(withIndex selectedIndex: Int) {
        let title = loginRegisterSegementedControl.titleForSegment(at: selectedIndex)
        if !(activityIndicatorView.isAnimating) {
            loginRegisterButton.setTitle(title, for: .normal)
        } else {
            loginRegisterButton.titleLabel?.text = nil
        }
    }
    
    /// handles the functionality of the segmented controller
    @objc internal func handleLoginRegisterSegmentChange() {
        let selectedIndex = loginRegisterSegementedControl.selectedSegmentIndex
        
        
        profileImageSelector.isHidden = selectedIndex == 0 ? true : false

        handleLoginRegisterTitle(withIndex: selectedIndex)
        
        //change height of containerView
        inputContainerViewHeightAnchor?.constant = selectedIndex == 0 ? 100 : 150
        
        //change other contraints
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: selectedIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: selectedIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: selectedIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }

    //MARK: add subviews
    internal func handleAdditionOfSubviews() {
        view.addSubview(inputContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageSelector)
        view.addSubview(loginRegisterSegementedControl)
        loginRegisterButton.addSubview(activityIndicatorView)
        
        func inputContainer() {
            inputContainerView.addSubview(nameTextField)
            inputContainerView.addSubview(nameSeperatorLineUI)
            inputContainerView.addSubview(emailTextField)
            inputContainerView.addSubview(emailSeperatorLineUI)
            inputContainerView.addSubview(passwordTextField)
        }
        
        inputContainer()
    }
}

extension LoginViewController {
    //MARK: CONSTRAINTS
    internal func handleConstraints() {
        NSLayoutConstraint.activate([
            inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50),
            ])
        inputContainerViewHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputContainerViewHeightAnchor?.isActive = true
        
        
        NSLayoutConstraint.activate([
            loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginRegisterButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 8),
            loginRegisterButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
            loginRegisterButton.heightAnchor.constraint(equalToConstant: 38),
            ])
        
        let squareDimension: CGFloat = 150
        NSLayoutConstraint.activate([
            profileImageSelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageSelector.bottomAnchor.constraint(equalTo: loginRegisterSegementedControl.topAnchor, constant: -8),
            profileImageSelector.widthAnchor.constraint(equalToConstant: squareDimension),
            profileImageSelector.heightAnchor.constraint(equalToConstant: squareDimension)
            ])
        
        NSLayoutConstraint.activate([
            loginRegisterSegementedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginRegisterSegementedControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12),
            loginRegisterSegementedControl.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
            loginRegisterSegementedControl.heightAnchor.constraint(equalToConstant: 35)
            ])
        
        
        
        NSLayoutConstraint.activate([
            nameTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12),
            nameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor),
            nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor, constant: -6),
            ])
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        
        NSLayoutConstraint.activate([
            emailTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12),
            emailTextField.topAnchor.constraint(equalTo: nameSeperatorLineUI.topAnchor),
            emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor, constant: -8)
            ])
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        
        
        NSLayoutConstraint.activate([
            passwordTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12),
            passwordTextField.topAnchor.constraint(equalTo: emailSeperatorLineUI.topAnchor),
            passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor, constant: -8)
            ])
        
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        
        NSLayoutConstraint.activate([
            nameSeperatorLineUI.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor),
            nameSeperatorLineUI.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            nameSeperatorLineUI.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
            nameSeperatorLineUI.heightAnchor.constraint(equalToConstant: 1)
            ])
        
        NSLayoutConstraint.activate([
            emailSeperatorLineUI.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor),
            emailSeperatorLineUI.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            emailSeperatorLineUI.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
            emailSeperatorLineUI.heightAnchor.constraint(equalToConstant: 1)
            ])
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: loginRegisterButton.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: loginRegisterButton.centerYAnchor),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 30),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 30)
            ])
    }
}
