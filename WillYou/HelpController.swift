//
//  HelpController.swift
//  WillYou
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class HelpController: UIViewController, UITextViewDelegate, UserDelegate {
    
    var pressed: Bool = false
    
    var user: User?
    
    var helpController: HelpController?
    var masterController: MasterController?

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
    
    let locationView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let locationTextBox: UITextView = {
        let text = UITextView()
        text.backgroundColor = .white
        text.text = "Ex: Huntsman Hall"
        text.textColor = .lightGray
        text.font = UIFont(name: "Helvetica", size: 18)
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Location"
        label.textColor = UIColor(r: 90, g: 131, b: 261)
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let locationImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Location")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = UIColor(r: 90, g: 131, b: 261)
        return image
    }()
    
    func createTitleName(titleName: String) -> UILabel {
        let label = UILabel()
        label.text = titleName
        label.textColor = UIColor(r: 90, g: 131, b: 261)
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func createTitleImageIcon(imageName: String) -> UIImageView {
        let image = UIImageView()
        image.image = UIImage(named: imageName)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = UIColor(r: 90, g: 131, b: 261)
        return image
    }
    
    func createTitleWithIcon(title: String, imageName: String, imageSize: CGFloat, imageLeftSpacing: CGFloat, imageTopSpacing: CGFloat, titleLeftSpacing: CGFloat) -> UIView {
        let panel = UIView()
        panel.translatesAutoresizingMaskIntoConstraints = false
        
        let title = createTitleName(titleName: title)
        let image = createTitleImageIcon(imageName: imageName)
        panel.addSubview(title)
        panel.addSubview(image)
        
        image.topAnchor.constraint(equalTo: panel.topAnchor, constant: imageTopSpacing).isActive = true
        image.leftAnchor.constraint(equalTo: panel.leftAnchor, constant: imageLeftSpacing).isActive = true
        image.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        image.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        
        title.topAnchor.constraint(equalTo: panel.topAnchor, constant: 16).isActive = true
        title.leftAnchor.constraint(equalTo: image.rightAnchor, constant: titleLeftSpacing).isActive = true
        
        return panel
    }
    
    let messageView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 240, g: 240, b: 240)
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
        button.tintColor = UIColor(r: 90, g: 131, b: 261)
        button.addTarget(self, action: #selector(handleMessageSend), for: .touchUpInside)
        return button
    }()
    
    func createCancelButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(r: 90, g: 131, b: 261)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(showHelpButton), for: .touchUpInside)
        return button
    }
    
    func nextLocationButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(r: 90, g: 131, b: 261)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleLocationNext), for: .touchUpInside)
        return button
    }
    
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
    
    lazy var successLabel: UILabel = {
        let label = UILabel()
        label.text = "Success!"
        label.numberOfLines = 1
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
        locationTextBox.delegate = self
        
        view.backgroundColor = .white
        self.helpController = self
        
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
    var locationViewCenterYAnchor: NSLayoutConstraint?
    var messageViewCenterYAnchor: NSLayoutConstraint?
    var messageViewHeightAnchor: NSLayoutConstraint?
    var pendingViewCenterYAnchor: NSLayoutConstraint?
    var successLabelCenterYAnchor: NSLayoutConstraint?
    var textBoxHeightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        view.addSubview(getHelpButton)
        view.addSubview(locationView)
        view.addSubview(messageView)
        view.addSubview(pendingView)
        view.addSubview(successLabel)
        
        setupHelpButton()
        setupLocationView()
        setupMessageView()
        setupPendingView()
        setupSuccessLabel()
    }
    
    func setupHelpButton() {
        getHelpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        helpButtonCenterYAnchor = getHelpButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        getHelpButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        getHelpButton.heightAnchor.constraint(equalToConstant: 90).isActive = true
        helpButtonCenterYAnchor?.isActive = true
    }
    
    func setupMessageView() {
        
        messageView.addSubview(textBox)
        
        textBoxHeightAnchor = textBox.heightAnchor.constraint(equalToConstant: textBox.font!.lineHeight * 2 + 20)
        textBoxHeightAnchor?.isActive = true
        
        messageViewHeightAnchor = messageView.heightAnchor.constraint(equalToConstant: 125 + (textBoxHeightAnchor?.constant)!)
        messageViewHeightAnchor?.isActive = true
        messageViewCenterYAnchor = messageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        
        setupInputBox(title: "Message", imageName: "Message", imageSize: 30, imageLeftSpacing: 12, imageTopSpacing: 12, titleLeftSpacing: 8, view: messageView, centerYAnchor: messageViewCenterYAnchor, textBox: textBox, button: sendButton)
    }
    
    func setupLocationView() {
        let nextButton: UIButton = nextLocationButton()
        
        locationViewCenterYAnchor = locationView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        locationView.heightAnchor.constraint(equalToConstant: 165).isActive = true
        
        locationView.addSubview(locationTextBox)
        locationTextBox.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        setupInputBox(title: "Location", imageName: "Location", imageSize: 40, imageLeftSpacing: 8, imageTopSpacing: 8, titleLeftSpacing: 4, view: locationView, centerYAnchor: locationViewCenterYAnchor, textBox: locationTextBox, button: nextButton)
    }
    
    func setupInputBox(title: String, imageName: String, imageSize: CGFloat, imageLeftSpacing: CGFloat, imageTopSpacing: CGFloat, titleLeftSpacing: CGFloat, view: UIView, centerYAnchor: NSLayoutConstraint?, textBox: UITextView, button: UIButton) {
        let cancelButton: UIButton = createCancelButton()
        
        let buttonPanel = UIView()
        buttonPanel.translatesAutoresizingMaskIntoConstraints = false
        
        let titlePanel = createTitleWithIcon(title: title, imageName: imageName, imageSize: imageSize, imageLeftSpacing: imageLeftSpacing, imageTopSpacing: imageTopSpacing, titleLeftSpacing: titleLeftSpacing)
        
        view.addSubview(titlePanel)
        view.addSubview(textBox)
        view.addSubview(buttonPanel)
        buttonPanel.addSubview(cancelButton)
        buttonPanel.addSubview(button)
        
        view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        view.widthAnchor.constraint(equalToConstant: 280).isActive = true
        centerYAnchor?.constant = 500
        centerYAnchor?.isActive = true
        
        titlePanel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        titlePanel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        titlePanel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        textBox.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textBox.topAnchor.constraint(equalTo: titlePanel.bottomAnchor, constant: 20).isActive = true
        textBox.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32).isActive = true
        
        buttonPanel.topAnchor.constraint(equalTo: textBox.bottomAnchor).isActive = true
        buttonPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        buttonPanel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        buttonPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        button.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 20).isActive = true
        button.centerYAnchor.constraint(equalTo: buttonPanel.centerYAnchor).isActive = true
        
        cancelButton.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -20).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: buttonPanel.centerYAnchor).isActive = true
    }
    
    func setupSuccessLabel() {
        successLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        successLabelCenterYAnchor = successLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        successLabelCenterYAnchor?.constant = 500
        successLabelCenterYAnchor?.isActive = true
    }
    
    func setupPendingView() {
        pendingView.addSubview(pendingLabel)
        pendingView.addSubview(cancelButton2)
        
        pendingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pendingView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        pendingView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -40).isActive = true
        pendingViewCenterYAnchor = pendingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        pendingViewCenterYAnchor?.constant = 500
        pendingViewCenterYAnchor?.isActive = true
        
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
        if numberOfLines > 1 && numberOfLines < 5 {
            self.textBoxHeightAnchor?.constant = textView.font!.lineHeight * numberOfLines + 20
            self.messageViewHeightAnchor?.constant = 125 + (textBoxHeightAnchor?.constant)!
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.view.layoutIfNeeded()
                
            }, completion: nil)
        }
        if textView == locationTextBox {
            return numberOfLines <= 1;
        } else {
            return numberOfLines <= 4;
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textView == textBox ? "Write your message here..." : "Ex: Huntsman Hall"
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
        locationViewCenterYAnchor?.constant = 0
        messageViewCenterYAnchor?.constant = 500
        pendingViewCenterYAnchor?.constant = 500
        successLabelCenterYAnchor?.constant = 500
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    func showMessageView() {
        helpButtonCenterYAnchor?.constant = -500
        locationViewCenterYAnchor?.constant = -500
        messageViewCenterYAnchor?.constant = 0
        pendingViewCenterYAnchor?.constant = 500
        successLabelCenterYAnchor?.constant = 500
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    func handleCancel() {
        masterController?.removeMyOutstandingRequest(helper: nil)
    }
    
    func handleLocationNext() {
        if locationTextBox.text == "Ex: Huntsman Hall" || locationTextBox.text == nil || locationTextBox.text == "" {
            showAlert(message: "You need to provide a generic location!")
        } else {
            showMessageView()
        }
    }
    
    func handleMessageSend() {
        if textBox.text == "Write your message here..." || textBox.text == nil || textBox.text == "" {
            showAlert(message: "You forgot to include a message!")
        } else {
            handleSend()
        }
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func showHelpButton() {
        textBox.resignFirstResponder()
        locationTextBox.resignFirstResponder()
        textBox.text = nil
        locationTextBox.text = nil
        textBoxHeightAnchor?.constant = textBox.font!.lineHeight * 2 + 20
        self.messageViewHeightAnchor?.constant = 125 + (textBoxHeightAnchor?.constant)!
        textViewDidEndEditing(textBox)
        textViewDidEndEditing(locationTextBox)

        helpButtonCenterYAnchor?.constant = 0
        locationViewCenterYAnchor?.constant = 500
        messageViewCenterYAnchor?.constant = 500
        pendingViewCenterYAnchor?.constant = 500
        successLabelCenterYAnchor?.constant = 500
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    func showLocationView() {
        helpButtonCenterYAnchor?.constant = -500
        locationViewCenterYAnchor?.constant = 0
        messageViewCenterYAnchor?.constant = 500
        pendingViewCenterYAnchor?.constant = 500
        successLabelCenterYAnchor?.constant = 500
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    func checkIfHasPendingRequest() {
        if UserDefaults.standard.hasPendingRequest() {
            showPending()
        }
    }
}
