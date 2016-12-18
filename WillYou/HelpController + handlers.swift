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
        let values: [String: AnyObject] = ["fromId": fromId as AnyObject, "timestamp": timestamp, "charger": user?.charger as AnyObject, "message": textBox.text as AnyObject]
        
        let request = Request()
        request.setValuesForKeys(values)
        
        //need to pull out auto generated id
        let childString: String = String(describing: childRef)
        let start = childString.index(childString.endIndex, offsetBy: -20)
        let requestId = childString.substring(from: start)
        request.requestId = requestId
        currentRequest = request
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
                        
            let requestId = childRef.key
            FIRDatabase.database().reference().child("outstanding-requests-by-user").child(fromId!).updateChildValues([requestId: 1])
            
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
                //print(currIndex)
                if currIndex != 1 {
                    self.masterController?.goLeftToHelpController(goLeft: currIndex == 2)
                }

                self.showSuccessLabel()
                
            }, withCancel: nil)
        
        }
        
    }
    
    func showSuccessLabel() {
        helpButtonCenterYAnchor?.constant = -500
        messageViewCenterYAnchor?.constant = -500
        pendingViewCenterYAnchor?.constant = -700
        successLabelCenterYAnchor?.constant = 0
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            
            let when = DispatchTime.now() + 1.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.showConfirmController()
            }
            
        }, completion: nil)
    }
    
    func showConfirmController() {
        let cc = ConfirmController()
        cc.user = user
        cc.helpController = self
        let nc = UINavigationController(rootViewController: cc)
        nc.modalTransitionStyle = .crossDissolve
        self.helpController?.present(nc, animated: true, completion: nil)
    }
    
}
