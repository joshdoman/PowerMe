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
            
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-requests").child(fromId!)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            FIRDatabase.database().reference().child("outstanding-requests-by-user").child(fromId!).updateChildValues([messageId: 1])
            FIRDatabase.database().reference().child("outstanding-requests").child(messageId).updateChildValues(["request": 1])
            
            self.showPending()
            
        }
        
        UserDefaults.standard.setHasPendingRequest(value: true)
    }
    
    func showPending() {
        helpButtonCenterYAnchor?.constant = -500
        messageViewCenterYAnchor?.constant = -500
        pendingViewCenterYAnchor?.constant = 0
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
        textBox.resignFirstResponder()
        
    }
    
}
