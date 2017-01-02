//
//  RequestCell.swift
//  WillYou
//
//  Created by Josh Doman on 12/31/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class RequestCell: UITableViewCell, UserDelegate {
    
    var request: Request? {
        didSet {
            setupCell()
        }
    }
    
    var expanded: Bool?
    var feedController: FeedController2?
    
    func setupCell() {
        setupNameAndProfileImage()
        
        detailTextLabel?.text = request?.location!
        
        if let timestamp = request?.timestamp {
            let timestampDate = Date(timeIntervalSince1970: timestamp.doubleValue)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            timeLabel.text = dateFormatter.string(from: timestampDate)
        }
    }
    
    var requester: User?

    fileprivate func setupNameAndProfileImage() {
        message.text = "\"\((request?.message)!)\""
        if let charger = request?.charger {
            chargerLabel.text = charger
        }
        requester = User()
        if let fromId = request?.fromId {
            requester?.loadUserUsingCacheWithUserId(uid: fromId, controller: self)
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 48
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let message: UILabel = {
        let label = UILabel()
        label.numberOfLines = 5
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let chargerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Help", for: .normal)
        button.backgroundColor = UIColor(r: 110, g: 151, b: 261)
        button.layer.cornerRadius = 6;
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        return button
    }()
    
    lazy var ignoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ignore", for: .normal)
        button.backgroundColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleIgnore), for: .touchUpInside)
        return button
    }()
    
    let expandedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    let buttonPanel: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 120, y: 40, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 120, y: 40 + 4 + textLabel!.frame.height, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    var messageHeightAnchor: NSLayoutConstraint?
    var messageExpandedHeightAnchor: NSLayoutConstraint?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        expanded = false
        
        clipsToBounds = true
        
        addSubview(expandedView)
        addSubview(profileImageView)
        addSubview(timeLabel)
        addSubview(message)
        addSubview(buttonPanel)
        
        //buttonPanel.addSubview(ignoreButton)
        buttonPanel.addSubview(acceptButton)
        
        _ = expandedView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        expandedView.heightAnchor.constraint(equalToConstant: 216).isActive = true
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.topAnchor, constant: 60).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 96).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 96).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        message.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12).isActive = true
        message.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -16).isActive = true
        message.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -50).isActive = true
        messageHeightAnchor = message.heightAnchor.constraint(equalToConstant: 14)
        messageExpandedHeightAnchor = message.heightAnchor.constraint(equalToConstant: CGFloat(message.numberOfLines * 13))
        messageExpandedHeightAnchor?.isActive = false
        messageHeightAnchor?.isActive = true
        
        buttonPanel.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 10).isActive = true
        buttonPanel.bottomAnchor.constraint(equalTo: expandedView.bottomAnchor, constant: -10).isActive = true
        buttonPanel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        buttonPanel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
//        ignoreButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        ignoreButton.centerYAnchor.constraint(equalTo: buttonPanel.centerYAnchor).isActive = true
//        ignoreButton.heightAnchor.constraint(equalTo: buttonPanel.heightAnchor).isActive = true
//        ignoreButton.widthAnchor.constraint(equalTo: buttonPanel.widthAnchor, multiplier: 0.5).isActive = true
        
        acceptButton.centerXAnchor.constraint(equalTo: buttonPanel.centerXAnchor).isActive = true
        acceptButton.centerYAnchor.constraint(equalTo: buttonPanel.centerYAnchor).isActive = true
        acceptButton.heightAnchor.constraint(equalTo: buttonPanel.heightAnchor).isActive = true
        acceptButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fetchUserAndDoSomething(user: User) {
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        textLabel?.text = user.name
    }
    
    func handleAccept() {
        feedController?.handleAccepted(request: request!)
    }
    
    func handleIgnore() {
        feedController?.removeRequest(request: request!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
        if selected {
            setHighlighted(true, animated: false)
            setHighlighted(false, animated: true)
            expanded = !expanded!
        } else {
            expanded = false
        }
        updateCell()
    }
    
    func updateCell() {
        if expanded! {
            messageHeightAnchor?.isActive = false
            messageExpandedHeightAnchor?.isActive = true
            buttonPanel.isHidden = false
        } else {
            messageHeightAnchor?.isActive = true
            messageExpandedHeightAnchor?.isActive = false
            buttonPanel.isHidden = true
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.layoutIfNeeded()
            
        }, completion: nil)
    }
}
