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
        let alertController = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Oops!", style: UIAlertActionStyle.default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action -> Void in
            self.handleConfirmedCancel()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func handleConfirmedCancel() {
        helpController?.masterController?.removeMyOutstandingRequest(helper: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleDone() {
        let alertController = UIAlertController(title: "Were you able to return the charger?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action -> Void in
            self.handlePickHelper()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func handlePickHelper() {
        navigationItem.title = "Select who helped you"
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
        isSelectingHelper = true
    }
    
    func showConfirmHelper(helper: User) {
        let alertController = UIAlertController(title: "Please confirm that \((helper.name)!) helped you.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { action -> Void in
            self.isSelectingHelper = false
            self.setupNavigationBar()
            self.clearSelectedRows()
        }))
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action -> Void in
            self.handleCompletedRequest(helper: helper)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func handleCompletedRequest(helper: User) {
        helpController?.masterController?.removeMyOutstandingRequest(helper: helper)
        dismiss(animated: true, completion: nil)
    }
    
    func createCompletedRequest(helper: User) {
        
    }
    
}
