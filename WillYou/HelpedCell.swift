//
//  HelpedCell.swift
//  WillYou
//
//  Created by Josh Doman on 12/31/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class HelpedCell: UITableViewCell, UserDelegate {
    
    var request: Request? {
        didSet {
            setupCell()
        }
    }
    
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
    
    var helper: User?
    var requester: User?
    
    fileprivate func setupNameAndProfileImage() {
        if let helper = request?.helper {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: helper.profileImageUrl!)
            self.helper = helper
        }
        
        requester = User()
        if let requestId = request?.fromId {
            requester?.loadUserUsingCacheWithUserId(uid: requestId, controller: self)
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
        self.textLabel?.font = UIFont.systemFont(ofSize: 15)
        self.textLabel?.text = "\((helper?.name)!) saved \((requester?.name)!)"
    }
    
}
