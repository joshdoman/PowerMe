//
//  HelpController + handlers.swift
//  WillYou
//
//  Created by Josh Doman on 12/14/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import Firebase

extension HelpController {
    
    func handleSend() {
        
        DispatchQueue.main.async {
            self.masterController?.removeAllMessages()
        }
        
        let ref = FIRDatabase.database().reference().child("requests")
        let childRef = ref.childByAutoId()
        let fromId = FIRAuth.auth()?.currentUser!.uid
        
        let timestamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let values: [String: AnyObject] = ["fromId": fromId as AnyObject, "timestamp": timestamp, "charger": user?.charger as AnyObject, "location": locationTextBox.text as AnyObject, "message": textBox.text as AnyObject]
        
        //pulls out auto generated id
//        let childString: String = String(describing: childRef)
//        let start = childString.index(childString.endIndex, offsetBy: -20)
//        let _ = childString.substring(from: start)
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
                        
            let requestId = childRef.key
            FIRDatabase.database().reference().child("outstanding-requests-by-user").child((self.user?.charger)!).child(fromId!).updateChildValues([requestId: 1])
            
            self.showPending()
        }
        
        UserDefaults.standard.setHasPendingRequest(value: true)
    }
    
    func showPending() {
        helpButtonCenterYAnchor?.constant = -500
        messageViewCenterYAnchor?.constant = -500
        pendingViewCenterYAnchor?.constant = 0
        successLabelCenterYAnchor?.constant = 500
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            self.setupAcceptanceObserver()
            
        }, completion: nil)
        
        textBox.resignFirstResponder()
        
    }
    
    func setupAcceptanceObserver() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
        
            FIRDatabase.database().reference().child("user-messages").child(uid).observeSingleEvent(of: .childAdded, with: {
                (snapshot) in
                
                let currIndex = self.masterController?.currentIndex
                if currIndex != 1 {
                    self.masterController?.goLeftToHelpController(goLeft: currIndex == 2)
                }

                //self.showSuccessLabel()

                self.showSuccessLabelForUser(uid: snapshot.key)
                
            }, withCancel: nil)
        
        }
        
    }
    
    func showSuccessLabelForUser(uid: String) {
        helpButtonCenterYAnchor?.constant = -500
        messageViewCenterYAnchor?.constant = -500
        pendingViewCenterYAnchor?.constant = -700
        successLabelCenterYAnchor?.constant = 0
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            
            let when = DispatchTime.now() + 1.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                let user = User()
                user.loadUserUsingCacheWithUserId(uid: uid, controller: self)
            }
        }, completion: nil)
    }
    
    func showChatController(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        chatLogController.helpController = self
        chatLogController.isRequester = true
        let nc = UINavigationController(rootViewController: chatLogController)
        nc.modalTransitionStyle = .crossDissolve
        self.present(nc, animated: true, completion: nil)
    }
    
    func fetchUserAndDoSomething(user: User) {
        showChatController(user: user)
    }
    
}
