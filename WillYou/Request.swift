//
//  Request.swift
//  WillYou
//
//  Created by Josh Doman on 12/14/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

class Request: NSObject {
    
    var requestId: String?
    var requester: User?
    var helperId: String?
    var helper: User?
    var fromId: String?
    var charger: String?
    var message: String?
    var location: String?
    var timestamp: NSNumber?
    
    func copyRequest(request: Request) {
        self.requestId = request.requestId
        self.requester = request.requester
        self.helperId = request.helperId
        self.helper = request.helper
        self.fromId = request.fromId
        self.charger = request.charger
        self.message = request.message
        self.location = request.location
        self.timestamp = request.timestamp
    }
}
