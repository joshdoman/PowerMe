//
//  MessageCell.swift
//  WillYou
//
//  Created by Josh Doman on 12/14/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class MessageCell: UITableViewCell, UserDelegate {
    
    var request: Request? {
        didSet {
            detailTextLabel?.text = nil
            if request?.helperId == nil {
                setupCell(fromId: request?.fromId, text: request?.message, timestamp: request?.timestamp)
            } else {
                //setupHelpCell()
                setupCell(fromId: request?.helperId, text: request?.message, timestamp: request?.timestamp)
            }
        }
    }
    
    var message: Message? {
        didSet {
            setupCell(fromId: message?.chatPartnerId(), text: message?.text, timestamp: message?.timestamp)
        }
    }
    
    func setupCell(fromId: String?, text: String?, timestamp: NSNumber?) {
        setupNameAndProfileImage(fromId: fromId)
        
        if request?.helperId == nil {
            detailTextLabel?.text = text
        }
        
        if let timestamp = timestamp {
            let timestampDate = Date(timeIntervalSince1970: timestamp.doubleValue)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            timeLabel.text = dateFormatter.string(from: timestampDate)
        }
    }
    
    fileprivate func setupNameAndProfileImage2(fromId: String?) {
        if let fromId = fromId {
            let ref = FIRDatabase.database().reference().child("users").child(fromId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary1 = snapshot.value as? [String: AnyObject] {
                    
                    if let profileImageUrl = dictionary1["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                    
                    if self.request?.helperId != nil {
                        FIRDatabase.database().reference().child("users").child((self.request?.fromId)!).observeSingleEvent(of: .value, with: { (snapshot) in
                            if let dictionary2 = snapshot.value as? [String: AnyObject] {
                                //let att = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15)]
                                
//                                var name1 = NSMutableAttributedString(string: (dictionary1["name"] as? String)!, attributes: att)
//                                var name2 = NSMutableAttributedString(string: (dictionary2["name"] as? String)!, attributes: att)
//                                
//                                var middle = NSMutableAttributedString(string: "just saved")
                                self.textLabel?.font = UIFont.systemFont(ofSize: 15)
                                self.textLabel?.text = "\((dictionary1["name"] as? String)!) saved \((dictionary2["name"] as? String)!)"
                            }
                        }, withCancel: nil)
                    } else {
                        self.textLabel?.text = dictionary1["name"] as? String
                    }
                }
                
            }, withCancel: nil)
        }
    }
    
    var mainUser: User?
    var secondUser: User?
    
    fileprivate func setupNameAndProfileImage(fromId: String?) {
        if let fromId = fromId {
            mainUser = User()
            mainUser?.loadUserUsingCacheWithUserId(uid: fromId, controller: self)
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fetchUserAndDoSomething(user: User) {
        if secondUser == nil {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: user.profileImageUrl!)
            if self.request?.helperId != nil {
                secondUser = User()
                secondUser?.loadUserUsingCacheWithUserId(uid: (self.request?.fromId)!, controller: self)
            } else {
                self.textLabel?.text = user.name
            }
        } else {
            self.textLabel?.font = UIFont.systemFont(ofSize: 15)
            self.textLabel?.text = "\((mainUser?.name)!) saved \((secondUser?.name)!)"
        }

    }
    
}
