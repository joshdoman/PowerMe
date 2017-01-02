//
//  FeedController2.swift
//  WillYou
//
//  Created by Josh Doman on 12/31/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class FeedController2: UITableViewController, RequestDelegate {
    
    var user: User? {
        didSet {
            navigationItem.title = "WillYou"
            observeRequests()
            observeHelps()
        }
    }
    
    var timer: Timer?
    var masterController: MasterController?
    var selectedCellIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
    }
    
    var requests = [Request]()
    var requestDictionary = [String: Request]()
    var helps = [Request]()
    var helpDictionary = [String: Request]()
    
    let helpedCellId = "helpedCellId"
    let requestCellId = "requestCellId"
    let placeholderCellId = "placeholderCellId"
    
    func registerCells() {
        tableView.register(RequestCell.self, forCellReuseIdentifier: requestCellId)
        tableView.register(HelpedCell.self, forCellReuseIdentifier: helpedCellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: placeholderCellId)
    }
    
    func observeRequests() {
        guard let charger = user?.charger, let uid = user?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("outstanding-requests-by-user").child(charger)
        ref.observe(.childAdded, with: { (snapshot) in
            
            if snapshot.key != uid, let dictionary = snapshot.value as? [String: AnyObject] {
                let requestIds = Array(dictionary.keys)
                if let requestId = requestIds.first {
                    self.fetchRequestWithRequestId(requestId: requestId)
                }
            }
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let requestIds = Array(dictionary.keys)
                if let requestId = requestIds.first {
                    self.requestDictionary.removeValue(forKey: requestId)
                    self.attemptReloadOfTable()
                }
            }
        }, withCancel: nil)
    }
    
    func observeHelps() {
        FIRDatabase.database().reference().child("helps").observe(.childAdded, with: { (snapshot) in
            let requestId = snapshot.key
            self.fetchCompletedRequestWithRequestId(requestId: requestId)
        })
    }
    
    private func fetchCompletedRequestWithRequestId(requestId: String) {
        let request = Request()
        helpDictionary[requestId] = request
        request.loadRequestUsingCacheWithRequestId(requestId: requestId, controller: self)
    }
    
    private func fetchRequestWithRequestId(requestId: String) {
        let messageReference = FIRDatabase.database().reference().child("requests").child(requestId)
        
        messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let request = Request()
                request.setValuesForKeys(dictionary)
                request.requestId = requestId
                self.requestDictionary[requestId] = request
            }
            
            self.attemptReloadOfTable()
            
        }, withCancel: nil)
    }
    
    func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable() {
        self.requests = Array(self.requestDictionary.values)
        self.requests.sort(by: { (request1, request2) -> Bool in
            if let int1 = request1.timestamp?.intValue, let int2 = request2.timestamp?.intValue {
                return int1 < int2
            } else {
                return false
            }
        })
        
        self.helps = Array(self.helpDictionary.values)
        self.helps.sort(by: { (request1, request2) -> Bool in
            if let int1 = request1.timestamp?.intValue, let int2 = request2.timestamp?.intValue {
                return int1 > int2
            } else {
                return false
            }
        })
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return max(1, requests.count)
        } else {
            return helps.count
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Outstanding requests"
        }
        return "Recent"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if requests.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: requestCellId, for: indexPath) as! RequestCell
                
                cell.request = requests[indexPath.row]
                cell.feedController = self
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: placeholderCellId, for: indexPath)
                cell.textLabel?.text = "No one needs help right now. Phew!"
                cell.textLabel?.numberOfLines = 2
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .lightGray
                cell.textLabel?.font =  UIFont.systemFont(ofSize: 25)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: helpedCellId, for: indexPath) as! HelpedCell
            
            cell.request = helps[indexPath.row]
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        }
    }
        
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1 {
            return 72
        } else if indexPath == selectedCellIndex {
            return 216
        } else {
            return 120
        }
    }
    
    func fetchRequestsAndDoSomething() {
        attemptReloadOfTable()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedCellIndex == indexPath {
            selectedCellIndex = nil
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            selectedCellIndex = indexPath
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let helpAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Save the day!" , handler: { (action:UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            self.handleAccepted(request: self.requests[indexPath.item])
        })
        
        helpAction.backgroundColor = Model.blueColor

        return [helpAction]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if selectedCellIndex == indexPath {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func handleAccepted(request: Request) {
        guard let chatPartnerId = request.fromId else {
            return
        }
        
        let user = User()
        user.loadUserUsingCacheWithUserId(uid: chatPartnerId)
        showChatControllerForUser(user: user, request: request)
    }
    
    func showChatControllerForUser(user: User, request: Request) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.feedController2 = self
        chatLogController.user = user
        chatLogController.request = request
        chatLogController.isRequester = false
        selectedCellIndex = nil
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func removeRequest(request: Request) {
        requestDictionary.removeValue(forKey: request.requestId!)
        attemptReloadOfTable()
    }
}

