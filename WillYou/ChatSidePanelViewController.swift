//
//  SidePanelViewController.swift
//  WillYou
//
//  Created by Josh Doman on 1/4/17.
//  Copyright © 2017 Josh Doman. All rights reserved.
//

import UIKit

class ChatSidePanelViewController: UIViewController {
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = .red
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    var delegate: SidePanelViewControllerDelegate?
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.tintColor = .white
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
        return button
    }()
    
    lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Logout")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(r: 0, g: 122, b: 255)
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupViews()
    }
    
    func setupViews() {
        view.addSubview(cancelButton)
        view.addSubview(doneButton)
        view.addSubview(logoutButton)
        
        cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        doneButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor).isActive = true
        doneButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = logoutButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 24, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        logoutButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    func handleCancel() {
        let alertController = UIAlertController(title: "Are you sure you wish to cancel?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action -> Void in
            self.delegate?.buttonSelected(button: .cancel)

        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func handleDone() {
        guard let name = Model.currentUser?.name else {
            return
        }
        
        let str = (delegate?.getIsRequester())! ? "Please confirm that you have returned \(name)'s charger." : "Please confirm that \(name) has returned your charger."
        let alertController = UIAlertController(title: str, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { action -> Void in
            self.delegate?.buttonSelected(button: .done)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func handleLogout() {
        let alertController = UIAlertController(title: "Are you sure you wish to sign out?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action -> Void in
            self.delegate?.buttonSelected(button: .logout)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

