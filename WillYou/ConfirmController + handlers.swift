//
//  ConfirmController + handlers.swift
//  WillYou
//
//  Created by Josh Doman on 12/15/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import Firebase

extension ConfirmController {
    
    func handleCancel() {    
        helpController?.showHelpButton()
        
        FIRDatabase.database().reference().child("user-messages").child((user?.uid!)!)
        
        let ref = FIRDatabase.database().reference().child("outstanding-requests-by-user").child((user?.uid!)!)
        
        ref.observeSingleEvent(of: .childAdded, with: {
            (snapshot) in
            
            FIRDatabase.database().reference().child("outstanding-requests").child(snapshot.key).removeValue()
            FIRDatabase.database().reference().child("requests").child(snapshot.key).removeValue()
            FIRDatabase.database().reference().child("user-requests").child((self.user?.uid)!).child(snapshot.key).removeValue()
            ref.removeValue()
            
            self.helpController?.masterController?.removeAllMessages()
            
        }, withCancel: nil)
        
        UserDefaults.standard.setHasPendingRequest(value: false)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleDone() {
        print("Done!")
    }
    
}
