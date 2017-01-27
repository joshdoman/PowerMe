//
//  InProgressCell.swift
//  WillYou
//
//  Created by Josh Doman on 1/4/17.
//  Copyright © 2017 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class InProgressCell: UITableViewCell, UserDelegate {
    
    var request: Request? {
        didSet {
            setupCell()
        }
    }
    
    func setupCell() {
        setupNameAndProfileImage()
        
        if let timestamp = request?.timestamp {
            
            let timestampDate = Date(timeIntervalSince1970: timestamp.doubleValue)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            timeLabel.text = dateFormatter.string(from: timestampDate)
        }
    }
    
    var timer: Timer?
    
    fileprivate func setupNameAndProfileImage() {
        
        if let helper = request?.helper, let requester = request?.requester {
            if let profileImageUrl = requester.profileImageUrl {
                profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            }
            
            if let requesterName = requester.name, let profileImageUrl = helper.profileImageUrl {
                textLabel?.text = "\(requesterName) is being helped."
                helperImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            }
        } else if let fromId = request?.fromId {
            requester = User()
            requester?.loadUserUsingCacheWithUserId(uid: fromId, controller: self)
        }
        

    }
    
    var progress: ProgressState = .three {
        didSet {
            if progress == .one {
                message.text = "In progress."
            } else if progress == .two {
                message.text = "In progress.."
            } else if progress == .three {
                message.text = "In progress..."
            } else {
                message.text = "In progress"
            }
        }
    }
    
    func handleProgress() {
        if progress == .one {
            progress = .two
        } else if progress == .two {
            progress = .three
        } else if progress == .three {
            progress = .four
        } else {
            progress = .one
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var helper: User? {
        didSet {
            request?.helper = helper
        }
    }
    
    var requester: User? {
        didSet {
            request?.requester = requester
        }
    }
        
    let helperImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "profile")
        imageView.layer.cornerRadius = 15
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
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let textLabel = textLabel else {
            return
        }
        
        textLabel.font = UIFont.systemFont(ofSize: 14)
        
        textLabel.frame = CGRect(x: 90, y: textLabel.frame.origin.y, width: textLabel.frame.width, height: textLabel.frame.height)
        
        //detailTextLabel.frame = CGRect(x: 90, y: detailTextLabel.frame.origin.y + 2, width: detailTextLabel.frame.width, height: detailTextLabel.frame.height)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        message.text = "In progress"
        self.timer = Timer.scheduledTimer(timeInterval: 0.9, target: self, selector: #selector(handleProgress), userInfo: nil, repeats: true)
        
        clipsToBounds = true
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        addSubview(message)
        addSubview(helperImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        if let heightAnchor = textLabel?.heightAnchor {
            timeLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        }
        
        message.leftAnchor.constraint(equalTo: centerXAnchor, constant: -38).isActive = true
        message.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        helperImageView.leftAnchor.constraint(equalTo: profileImageView.centerXAnchor, constant: 8).isActive = true
        helperImageView.topAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 8).isActive = true
        helperImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        helperImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fetchUserAndDoSomething(user: User) {
        if helper == nil {
            if let profileImageUrl = user.profileImageUrl {
                profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            }
            
            if let helperId = request?.helperId {
                helper = User()
                helper?.loadUserUsingCacheWithUserId(uid: helperId, controller: self)
            }
        } else {
            if let requesterName = requester?.name, let profileImageUrl = user.profileImageUrl {
                textLabel?.text = "\(requesterName) is being helped."
                helperImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            }
        }
    }
    
}

