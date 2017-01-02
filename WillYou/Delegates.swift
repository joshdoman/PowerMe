//
//  Delegates.swift
//  WillYou
//
//  Created by Josh Doman on 12/26/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

protocol RequestDelegate: class {
    func fetchRequestsAndDoSomething()
}

protocol UserDelegate: class {
    func fetchUserAndDoSomething(user: User)
}

