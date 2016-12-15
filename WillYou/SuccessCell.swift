//
//  SuccessCell.swift
//  WillYou
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

class SuccessCell: UICollectionViewCell {
    
    lazy var titleView: UILabel = {
        let label = UILabel()
        label.text = "Success! You're done!"
        label.numberOfLines = 2
        label.textAlignment = NSTextAlignment.center
        label.font = label.font.withSize(45)
        label.textColor = UIColor(r: 110, g: 151, b: 261)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    func setupViews() {
        backgroundColor = UIColor(r: 210, g: 221, b: 261)
        
        addSubview(titleView)
        
        titleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleView.widthAnchor.constraint(equalTo: widthAnchor, constant: -50).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
