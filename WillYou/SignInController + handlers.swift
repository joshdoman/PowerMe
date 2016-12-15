//
//  ViewController + handlers.swift
//  WillYou
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

extension SignInController {
    
    func handleRegister() {
        let rc = RegisterController()
        rc.modalTransitionStyle = .crossDissolve
        present(rc, animated: true, completion: nil)
    }
    
    func handleSignIn() {
        let lc = LoginController()
        lc.modalTransitionStyle = .crossDissolve
        present(lc, animated: true, completion: nil)
    }
    
}
