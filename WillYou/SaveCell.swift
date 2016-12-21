//
//  SaveCell.swift
//  WillYou
//
//  Created by Josh Doman on 12/20/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class SaveCell: UITableViewCell {
    
    var user: User?
    
    var request: Request? {
        didSet {
            setupNameAndProfileImage()
            helperImageView.image = nil
            requesterImageView.image = nil
        }
    }
    
    fileprivate func setupNameAndProfileImage() {
        if let fromId = request?.fromId, let helpId = request?.helperId {
            if user?.uid == fromId {
                let ref = FIRDatabase.database().reference().child("users").child(helpId)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        self.myLabel.text = "\((dictionary["name"] as? String)!) saved you"
                        
                        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                            self.helperImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                        }
                    }
                    
                }, withCancel: nil)
            } else {
                let ref = FIRDatabase.database().reference().child("users").child(fromId)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        self.myLabel.text = "You saved \((dictionary["name"] as? String)!)"
                        
                        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                            self.requesterImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                        }
                    }
                    
                }, withCancel: nil)
            }
        }
    }
    
    let myLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.right
        label.font = label.font.withSize(17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let myDetailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.right
        label.text = "Houston Hall"
        label.font = label.font.withSize(12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let helperImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 36
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let requesterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 36
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var myLabelRightAnchor: NSLayoutConstraint?
    var myLabelLeftAnchor: NSLayoutConstraint?
    var myDetailLabelRightAnchor: NSLayoutConstraint?
    var myDetailLabelLeftAnchor: NSLayoutConstraint?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(helperImageView)
        addSubview(requesterImageView)
        addSubview(myLabel)
        addSubview(myDetailLabel)
        
        requesterImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        requesterImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        requesterImageView.widthAnchor.constraint(equalToConstant: 72).isActive = true
        requesterImageView.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        helperImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        helperImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        helperImageView.widthAnchor.constraint(equalToConstant: 72).isActive = true
        helperImageView.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        myLabelRightAnchor = myLabel.rightAnchor.constraint(equalTo: helperImageView.leftAnchor, constant: -16)
        myLabelLeftAnchor = myLabel.leftAnchor.constraint(equalTo: requesterImageView.rightAnchor, constant: 16)
        myLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8).isActive = true
        
        myDetailLabelRightAnchor = myDetailLabel.rightAnchor.constraint(equalTo: helperImageView.leftAnchor, constant: -16)
        myDetailLabelLeftAnchor = myDetailLabel.leftAnchor.constraint(equalTo: requesterImageView.rightAnchor, constant: 16)
        myDetailLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 8).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if helperImageView.image == nil {
            myLabelLeftAnchor?.isActive = true
            myDetailLabelLeftAnchor?.isActive = true
            myLabelRightAnchor?.isActive = false
            myDetailLabelRightAnchor?.isActive = false
            //textLabel?.frame = CGRect(x: -96, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
        } else {
            myLabelRightAnchor?.isActive = true
            myDetailLabelRightAnchor?.isActive = true
            myLabelLeftAnchor?.isActive = false
            myDetailLabelLeftAnchor?.isActive = false
            //textLabel?.frame = CGRect(x: 96, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
        }
    }
    
}
