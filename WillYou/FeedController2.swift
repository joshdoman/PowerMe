//
//  feedController.swift
//  WillYou
//
//  Created by Josh Doman on 12/31/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class FeedController: UITableViewController, RequestDelegate, UserDelegate {
    
    var user: User? {
        didSet {
            navigationItem.title = "WillYou"
            observe()
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
    let inProgressCellId = "inProgressCellId"
    
    func registerCells() {
        tableView.register(RequestCell.self, forCellReuseIdentifier: requestCellId)
        tableView.register(HelpedCell.self, forCellReuseIdentifier: helpedCellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: placeholderCellId)
        tableView.register(InProgressCell.self, forCellReuseIdentifier: inProgressCellId)
    }
    
    var timer2: Timer?
    var elapsedtime: Double = 0
    
    func observe() {
        timer2 = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(incrementTime), userInfo: nil, repeats: true)
        FIRDatabase.database().reference().observeSingleEvent(of: .value, with: { (snapshot) in
            self.timer2?.invalidate()
            if snapshot.hasChild("outstanding-requests-by-user") {
                let when = DispatchTime.now() + self.elapsedtime
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.masterController?.setCanSwipe(canSwipe: true)
                }
            } else {
                self.masterController?.setCanSwipe(canSwipe: true)
            }
            self.observeRequests()
            self.observeHelps()
        })

    }
    
    func incrementTime() {
        elapsedtime += 0.1
    }
    
    func observeRequests() {
        guard let charger = user?.charger, let uid = user?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("outstanding-requests-by-user").child(charger)
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            if snapshot.key != uid, let dictionary = snapshot.value as? [String: AnyObject] {
                let requestIds = Array(dictionary.keys)
                guard let requestId = requestIds.first else {
                    return
                }
                
                self.fetchRequestWithRequestId(requestId: requestId)
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
                
                if request.helperId == Model.currentUser?.uid {
                    self.handleAccepted(request: request)
                } else {
                    self.setupInProgressObserver(request: request)
                }
                
                self.requestDictionary[requestId] = request
            }
            
            self.attemptReloadOfTable()
            
        }, withCancel: nil)
    }
    
    private func setupInProgressObserver(request: Request) {
        guard let id = request.requestId else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("requests").child(id)
        
        ref.observe(.childAdded, with: { (snapshot) in
            if snapshot.key == "helperId" {
                if let str = snapshot.value as? String {
                    request.helperId = str
                }
                self.attemptReloadOfTable()
            }
        })
        
        ref.observe(.childRemoved, with: { (snapshot) in
            if snapshot.key == "helperId" {
                request.helperId = nil
                self.attemptReloadOfTable()
            }
        })
    }
    
    func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable() {
        self.requests = Array(self.requestDictionary.values)
        self.requests.sort(by: { (request1, request2) -> Bool in
            if let int1 = request1.timestamp?.intValue, let int2 = request2.timestamp?.intValue {
                if request1.helperId == nil && request2.helperId == nil {
                    return int1 < int2
                } else if request1.helperId != nil && request2.helperId == nil {
                    return false
                } else if request1.helperId == nil && request2.helperId != nil {
                    return true
                } else {
                    return int1 > int2
                }
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
                let request = requests[indexPath.row]
                if request.helperId == nil {
                    let cell = tableView.dequeueReusableCell(withIdentifier: requestCellId, for: indexPath) as? RequestCell
                    
                    cell?.request = request
                    cell?.feedController = self
                    
                    guard let c = cell else {
                        return UITableViewCell()
                    }
                    return c
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: inProgressCellId, for: indexPath) as? InProgressCell
                    
                    cell?.request = request
                    cell?.selectionStyle = UITableViewCellSelectionStyle.none
                    
                    guard let c = cell else {
                        return UITableViewCell()
                    }
                    return c
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: placeholderCellId, for: indexPath)
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.textLabel?.text = "No one needs help right now. Phew!"
                cell.textLabel?.numberOfLines = 2
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .lightGray
                cell.textLabel?.font =  UIFont.systemFont(ofSize: 25)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: helpedCellId, for: indexPath) as? HelpedCell
            
            cell?.request = helps[indexPath.row]
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            
            guard let c = cell else {
                return UITableViewCell()
            }
            return c
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 72
        } else if indexPath == selectedCellIndex {
            return 216
        } else if requests.count > 0 && requests[indexPath.row].helperId != nil {
            return 96
        } else {
            return 120
        }
    }
    
    func fetchRequestsAndDoSomething() {
        attemptReloadOfTable()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if requests.count == 0 || requests[indexPath.row].helperId != nil {
            return
        }
        
        if selectedCellIndex == indexPath {
            selectedCellIndex = nil
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            selectedCellIndex = indexPath
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func handleAccepted(request: Request) {
        guard let chatPartnerId = request.fromId, let requestId = request.requestId, let uid = self.user?.uid else {
            return
        }
        
        FIRDatabase.database().reference().child("requests").child(requestId).updateChildValues(["helperId" : uid])
        
        let user = User()
        chatRequest = request
        user.loadUserUsingCacheWithUserId(uid: chatPartnerId, controller: self)
    }
    
    var chatRequest: Request?
    
    func showChatControllerForUser(user: User, request: Request) {
        let chatController = ChatLogContainerController()
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.feedController = self
        chatLogController.user = user
        chatLogController.request = request
        chatLogController.isRequester = false
        chatLogController.masterController = masterController
        selectedCellIndex = nil
        
        chatController.centerViewController = chatLogController
        chatController.modalTransitionStyle = .crossDissolve
        masterController?.present(chatController, animated: true, completion: nil)
    }
    
    func removeRequest(request: Request) {
        guard let requestId = request.requestId else {
            return
        }
        requestDictionary.removeValue(forKey: requestId)
        attemptReloadOfTable()
    }
    
    func fetchUserAndDoSomething(user: User) {
        if let request = chatRequest {
            showChatControllerForUser(user: user, request: request)
            //chatRequest = nil
        }
        
        guard let token = user.token, let name = user.name else {
            return
        }

        NetworkManager.sendSuccessNotification(toToken: token, helperName: name)
    }
}

