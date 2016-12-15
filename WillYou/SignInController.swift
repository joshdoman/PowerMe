//
//  ViewController.swift
//  WillYou
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

class SignInController: UIViewController {
    
    let lightBlueColor = UIColor(r: 210, g: 251, b: 261)
    
    lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        button.backgroundColor = UIColor(r: 110, g: 151, b: 261)
        button.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)//TODO-- change selector back to handleGetHelp
        
        return button
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        button.backgroundColor = UIColor(r: 150, g: 191, b: 202)
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)//TODO-- change selector back to handleGetHelp
        
        return button
    }()
    
    lazy var titleView: UILabel = {
        let label = UILabel()
        label.text = "WillYou"
        label.textAlignment = NSTextAlignment.center
        label.font = label.font.withSize(70)
        label.textColor = UIColor(r: 110, g: 151, b: 261)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        view.backgroundColor = .white
        
    }
    
    func setupViews() {
        view.addSubview(signInButton)
        view.addSubview(registerButton)
        view.addSubview(titleView)
        
        titleView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        titleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        registerButton.anchorToTop(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        signInButton.anchorToTop(nil, left: view.leftAnchor, bottom: registerButton.topAnchor, right: view.rightAnchor)
        signInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

}

