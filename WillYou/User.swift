//
//  User.swift
//  WillYou
//
//  Created by Josh Doman on 12/14/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var uid: String?
    var name: String?
    var email: String?
    var charger: String?
    var profileImageUrl: String?
    var token: String?
    
    func copyUser(user: User) {
        self.uid = user.uid
        self.name = user.name
        self.email = user.email
        self.charger = user.charger
        self.profileImageUrl = user.profileImageUrl
        self.token = user.token
    }
    
}
