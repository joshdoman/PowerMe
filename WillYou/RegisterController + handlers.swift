//
//  RegisterController + handlers.swift
//  WillYou
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

extension RegisterController {
    
    func handleNext() {
        resignAllFirstResponders()
        currentPage += 1
        let indexPath = IndexPath(item: currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        if (currentPage == 3) {
            
            bottomViewTopAnchor?.constant = 200
            bottomViewBottomAnchor?.constant = 200
            
            //accelerating animation (looks native)
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.view.layoutIfNeeded() //need to call if want to animate constraint change
                
            }, completion: nil)
            
            if let email = registerInfoCell?.emailTextField.text, let password = registerInfoCell?.passwordTextField.text,
                let name = registerInfoCell?.nameTextField.text, let charger = registerChargerCell?.selectedCharger,
                let profileImage = registerPhotoCell?.profileImageView.image {
                
                handleRegister(email: email, password: password, name: name, charger: charger, profileImage: profileImage)
                
            }
            
            UserDefaults.standard.setIsLoggedIn(value: true)
            
        }
    }
    
    func handleRegister(email: String, password: String, name: String, charger: String, profileImage: UIImage) {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //successfully authenticated user
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        let values = ["name": name, "email": email, "charger": charger, "profileImageUrl": profileImageUrl]
                        self.registerUserInfoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                    }
                })
            }
        })
    }
    
    private func registerUserInfoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference()
        
        let usersReference = ref.child("users").child(uid) //make users reference
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref)
            in
            
            if err != nil {
                print(err!)
                return
            }
            
//            let user = User()
//            user.setValuesForKeys(values)
            
            UserDefaults.standard.setIsLoggedIn(value: true)
            UserDefaults.standard.setHasPendingRequest(value: false)
            
            self.perform(#selector(self.handleSegueToMaster), with: nil, afterDelay: 1)
            
        })
    }
    
    func handleSegueToMaster() {
        
        let mc = MasterController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        mc.modalTransitionStyle = .crossDissolve
        present(mc, animated: true, completion: nil)
    }
    
    func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: .UIKeyboardWillShow, object: nil) //keyboard pops up when click in text field
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil) //keyboard pops up when click in text field
    }
    
    func keyboardShow(notification: NSNotification) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.registerInfoCell?.adjustWhenKeyboardShown()
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.bottomViewTopAnchor?.constant = 75 - 110
                self.bottomViewBottomAnchor?.constant = -keyboardSize.height
            }
            
        }, completion: nil)
    }
    
    func keyboardHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.registerInfoCell?.adjustWhenKeyboardHidden()
            self.bottomViewTopAnchor?.constant = 75
            self.bottomViewBottomAnchor?.constant = 0

        }, completion: nil)
    }
    
}
