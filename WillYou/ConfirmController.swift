//
//  AcceptController.swift
//  WillYou
//
//  Created by Josh Doman on 12/15/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class ConfirmController: UITableViewController {
    
    var user: User? {
        didSet {
            setupNavigationBar()
            observeAcceptances()
        }
    }
    
    var timer: Timer?
    var helpController: HelpController?
    
    let accepterCellId = "accepterCellId"
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var isSelectingHelper: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        registerCells()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearSelectedRows()
    }
    
    func clearSelectedRows() {
        if let selectedRow = self.tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    func registerCells() {
        tableView.register(AccepterCell.self, forCellReuseIdentifier: accepterCellId)
    }
    
    func observeAcceptances() {
        guard let uid = user?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let accepterId = snapshot.key
            
            FIRDatabase.database().reference().child("user-messages").child(uid).child(accepterId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(accepterId: accepterId, messageId: messageId)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            self.messagesDictionary.removeValue(forKey: snapshot.key) //removes message if deleted from outside
            self.attemptReloadOfTable()
        }, withCancel: nil)
    
    }
    
    fileprivate func fetchMessageWithMessageId(accepterId: String, messageId: String) {
        let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
        
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                
                self.messagesDictionary[accepterId] = message
                
                self.attemptReloadOfTable()
            }
            
        }, withCancel: nil)
    }
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.timestamp?.int32Value)! > (message2.timestamp?.int32Value)!
        })
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            
            if self.messages.isEmpty {
                if UserDefaults.standard.hasPendingRequest() {
                    self.helpController?.showPending()
                }
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: accepterCellId, for: indexPath) as! AccepterCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[(indexPath as NSIndexPath).row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
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
            if self.isSelectingHelper {
                self.showConfirmHelper(helper: user)
            } else {
                self.showChatControllerForUser(user)
            }
            
        }, withCancel: nil)
    }
    
    func showChatControllerForUser(_ user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func setupNavigationBar() {
        navigationItem.title = "Acceptances"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done!", style: .plain, target: self, action: #selector(handleDone))
    }
    
}

