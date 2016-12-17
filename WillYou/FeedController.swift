//
//  FeedController.swift
//  WillYou
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class FeedController: UITableViewController {
    
    var masterController: MasterController?
    
    var user: User? {
        didSet {
            navigationItem.title = "Will you help?"
            observeRequests()
        }
    }
    
    var timer: Timer?
    
    let requestCellId = "requestCellId"
    
    var requests = [Request]()
    var requestDictionary = [String: Request]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        registerCells()
        
    }
    
    func registerCells() {
        tableView.register(RequestCell.self, forCellReuseIdentifier: requestCellId)
    }
    
    func observeRequests() {
        let ref = FIRDatabase.database().reference().child("outstanding-requests")
        ref.observe(.childAdded, with: { (snapshot) in
            
            let requestId = snapshot.key
            self.fetchRequestWithRequestId(requestId: requestId)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            self.requestDictionary.removeValue(forKey: snapshot.key) //removes message if deleted from outside
            self.attemptReloadOfTable()
        }, withCancel: nil)
        
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
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable() {
        self.requests = Array(self.requestDictionary.values)
        self.requests.sort(by: { (request1, request2) -> Bool in
            return (request1.timestamp?.intValue)! > (request2.timestamp?.intValue)!
        })
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: requestCellId, for: indexPath) as! RequestCell
        
        cell.request = requests[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = requests[(indexPath as NSIndexPath).row]
        
        FIRDatabase.database().reference().child("outstanding-requests-by-user").observeSingleEvent(of: .value, with: {
            (snapshot) in
            
            if snapshot.hasChild((self.user?.uid)!) {
                let alertController = UIAlertController(title: "You can't help someone when you're in need yourself!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.handleCanYouHelp(request: request)
            }
            
        }, withCancel: nil)
    }
    
    func handleCanYouHelp(request: Request) {
        //print(123)
        let alertController = UIAlertController(title: "Will you help?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action -> Void in
            self.handleYes(request: request)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func handleYes(request: Request) {
        
        guard let chatPartnerId = request.fromId else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = User()
            user.uid = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user)
            
        }, withCancel: nil)
    }
    
    func showChatControllerForUser(_ user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.feedController = self
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
}
