//
//  HelpController.swift
//  WillYou
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class HelpController: UIViewController, UITextViewDelegate {
    
    var pressed: Bool = false
    
    var user: User?
    
    var currentRequest: Request?

    lazy var getHelpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("HELP", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        button.addTarget(self, action: #selector(handleHideShadow), for: .touchDown)
        button.addTarget(self, action: #selector(handleShowShadow), for: .touchUpInside)
        button.addTarget(self, action: #selector(handleShowShadow), for: .touchDragExit)
        button.addTarget(self, action: #selector(handleGetHelp), for: .touchUpInside)
        
        button.backgroundColor = UIColor(r: 110, g: 151, b: 261)
        
        button.layer.cornerRadius = 20;
        
        button.layer.borderWidth = 2.0;
        button.layer.borderColor = UIColor.clear.cgColor
        
        button.layer.shadowColor = UIColor(r: 60, g: 101, b: 211).cgColor
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 1.0
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        return button
    }()
    
    let messageView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textBox: UITextView = {
        let text = UITextView()
        text.backgroundColor = .white
        text.text = "Write your message here..."
        text.textColor = .lightGray
        text.font = UIFont(name: "Helvetica", size: 20)
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(showHelpButton), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton2: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let pendingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var pendingLabel: UILabel = {
        let label = UILabel()
        label.text = "Great! Your request has been sent."
        label.numberOfLines = 3
        label.textAlignment = NSTextAlignment.center
        label.font = label.font.withSize(45)
        label.textColor = UIColor(r: 110, g: 151, b: 261)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pressed = false
        textBox.delegate = self
        
        view.backgroundColor = .white
        
        setupViews()
        
        observeKeyboardNotifications()
        
        checkIfHasPendingRequest()
    }
    
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: .UIKeyboardWillShow, object: nil) //keyboard pops up when click in text field
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil) //keyboard pops up when click in text field
    }
    
    func keyboardShow() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            let y: CGFloat = UIDevice.current.orientation.isLandscape ? -100 : -90
            self.view.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height) //moves frame up 50, change y value depending on app
            
        }, completion: nil)
    }
    
    func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height) //moves frame up 50, change y value depending on app
            
        }, completion: nil)
    }
    
    var helpButtonCenterYAnchor: NSLayoutConstraint?
    var messageViewCenterYAnchor: NSLayoutConstraint?
    var pendingViewCenterYAnchor: NSLayoutConstraint?
    
    func setupViews() {
        view.addSubview(getHelpButton)
        view.addSubview(messageView)
        view.addSubview(pendingView)
        
        messageView.addSubview(textBox)
        messageView.addSubview(sendButton)
        messageView.addSubview(cancelButton)
        
        pendingView.addSubview(pendingLabel)
        pendingView.addSubview(cancelButton2)
        
        getHelpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        helpButtonCenterYAnchor = getHelpButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        getHelpButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        getHelpButton.heightAnchor.constraint(equalToConstant: 90).isActive = true
        helpButtonCenterYAnchor?.isActive = true
        
        messageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        messageView.widthAnchor.constraint(equalToConstant: 280).isActive = true
        messageView.heightAnchor.constraint(equalToConstant: 215).isActive = true
        messageViewCenterYAnchor = messageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        messageViewCenterYAnchor?.constant = 500
        messageViewCenterYAnchor?.isActive = true
        
        textBox.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 15).isActive = true
        textBox.heightAnchor.constraint(equalToConstant: 100).isActive = true
        textBox.widthAnchor.constraint(equalTo: messageView.widthAnchor, constant: -50).isActive = true
        textBox.centerXAnchor.constraint(equalTo: messageView.centerXAnchor).isActive = true
        
        pendingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pendingView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        pendingView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -40).isActive = true
        pendingViewCenterYAnchor = pendingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        pendingViewCenterYAnchor?.constant = 500
        pendingViewCenterYAnchor?.isActive = true
        
        sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 50).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -16).isActive = true
        
        cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -50).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -16).isActive = true
        
        pendingLabel.centerXAnchor.constraint(equalTo: pendingView.centerXAnchor).isActive = true
        pendingLabel.centerYAnchor.constraint(equalTo: pendingView.centerYAnchor, constant: -40).isActive = true
        pendingLabel.widthAnchor.constraint(equalTo: pendingView.widthAnchor).isActive = true
        
        cancelButton2.centerXAnchor.constraint(equalTo: pendingView.centerXAnchor).isActive = true
        cancelButton2.bottomAnchor.constraint(equalTo: pendingView.bottomAnchor).isActive = true
    }
    
    func sizeOfString (string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: DBL_MAX), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).size
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        var textWidth = UIEdgeInsetsInsetRect(textView.frame, textView.textContainerInset).width
        textWidth -= 2.0 * textView.textContainer.lineFragmentPadding;
        let boundingRect = sizeOfString(string: newText, constrainedToWidth: Double(textWidth), font: textView.font!)
        let numberOfLines = boundingRect.height / textView.font!.lineHeight
        return numberOfLines <= 4;
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textBox.textColor == .lightGray {
            textBox.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write your message here..."
            textView.textColor = .lightGray
        }
    }
    
    
    func handleShowShadow() {
        getHelpButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        helpButtonCenterYAnchor?.constant = 0
    }
    
    func handleHideShadow() {
        getHelpButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        helpButtonCenterYAnchor?.constant = 3
    }
    
    func handleGetHelp() {
        helpButtonCenterYAnchor?.constant = -500
        messageViewCenterYAnchor?.constant = 0
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    func handleCancel() {
        guard let uid = user?.uid else {
            return
        }
        
        FIRDatabase.database().reference().child("outstanding-requests-by-user").child(uid).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            
            FIRDatabase.database().reference().child("requests").child(snapshot.key).removeValue()
            FIRDatabase.database().reference().child("user-requests").child(uid).child(snapshot.key).removeValue()
            
            FIRDatabase.database().reference().child("outstanding-requests-by-user").child(uid).removeValue()
            FIRDatabase.database().reference().child("outstanding-requests").child(snapshot.key).removeValue()

        })
        
        UserDefaults.standard.setHasPendingRequest(value: false)
        
        showHelpButton()
    }
    
    func showHelpButton() {
        helpButtonCenterYAnchor?.constant = 0
        messageViewCenterYAnchor?.constant = 500
        pendingViewCenterYAnchor?.constant = 500
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    
    func handleEndEditing() {
        resignFirstResponder()
    }
    
    func checkIfHasPendingRequest() {
        if UserDefaults.standard.hasPendingRequest() {
            showPending()
        }
    }
}
