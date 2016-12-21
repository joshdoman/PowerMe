//
//  RegisterPhotoCell.swift
//  WillYou
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

class RegisterPhotoCell: UICollectionViewCell {
    
    var registerController: RegisterController?
    
    lazy var titleView: UILabel = {
        let label = UILabel()
        label.text = "Tap to upload profile pic"
        label.numberOfLines = 2
        label.textAlignment = NSTextAlignment.center
        label.font = label.font.withSize(30)
        label.textColor = UIColor(r: 110, g: 151, b: 261)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 100
        imageView.layer.masksToBounds = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfile)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    func setupViews() {
        backgroundColor = UIColor(r: 210, g: 221, b: 261)
        
        addSubview(profileImageView)
        addSubview(titleView)
        
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -100).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: widthAnchor, constant: -50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        titleView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 50).isActive = true
        titleView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

    }
    
    func handleSelectProfile() {
        registerController?.showImagePicker()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

