//
//  ProfileController2.swift
//  WillYou
//
//  Created by Josh Doman on 12/20/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class ProfileController2: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var masterController: MasterController?
    var user: User? {
        didSet {
            observeMyRequests()
        }
    }
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.image = UIImage(named: "profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 75
        imageView.layer.masksToBounds = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfile)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        //label.text = "Josh"
        label.textAlignment = NSTextAlignment.center
        label.font = label.font.withSize(28)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return button
    }()
    
    let scrollView: UIScrollView = {
        let scroll = UIScrollView(frame: UIScreen.main.bounds)
        scroll.backgroundColor = .white
        return scroll
    }()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.allowsSelection = false
        return table
    }()
    
    let saveCellId = "saveCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = self.scrollView
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 500)
        //view.backgroundColor = .white
        
        tableView.frame = CGRect(x: 0, y: view.frame.height - 100, width: view.frame.width, height: 300)
        tableView.register(SaveCell.self, forCellReuseIdentifier: saveCellId)
        tableView.delegate = self
        tableView.dataSource = self
        
        setupViews()
        
    }
    
    func setupViews() {
        scrollView.addSubview(profileImageView)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(logoutButton)
        scrollView.addSubview(tableView)
        
        profileImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 75).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        nameLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20).isActive = true
        
        //tableView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30).isActive = true
        //tableView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        //tableView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        //tableView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        logoutButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 100).isActive = true
        logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func handleSelectProfile() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func setupProfileControllerWithUser(user: User) {
        self.user = user
        nameLabel.text = user.name
        profileImageView.loadImageUsingCacheWithUrlString(urlString: user.profileImageUrl!)
    }
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        FIRDatabase.database().reference().child("user-messages").removeAllObservers()
        
        masterController?.handleLogout()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: saveCellId, for: indexPath) as! SaveCell
        
        let request = Request()

        if indexPath.row == 1 {
            request.fromId = "oI7CGfFgYYaTrbsekHoDwiCYpHy2"
            request.helperId = user?.uid
        } else {
            request.helperId = "oI7CGfFgYYaTrbsekHoDwiCYpHy2"
            request.fromId = user?.uid
        }
        
        let request2 = requests[indexPath.row]
        
        cell.user = user
        cell.request = request2
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    var requests = [Request]()
    var requestDictionary = [String: Request]()
    
    func observeMyRequests() {
        FIRDatabase.database().reference().child("user-requests").child((user?.uid)!).observe(.childAdded, with: { (snapshot) in
            self.fetchRequestWithKey(child: "user-requests", id: snapshot.key)
        }, withCancel: nil)
        
        FIRDatabase.database().reference().child("user-helps").child((user?.uid)!).observe(.childAdded, with: { (snapshot) in
            self.fetchRequestWithKey(child: "user-helps", id: snapshot.key)
        }, withCancel: nil)
    }
    
    private func fetchRequestWithKey(child: String, id: String) {
        FIRDatabase.database().reference().child(child).child((user?.uid)!).child(id).observe(.childAdded, with: { (snapshot) in
            self.fetchRequestWithRequestId(requestId: snapshot.key)
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
    
    var timer: Timer?
    
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
            let height = CGFloat(90 * self.requests.count)
            self.tableView.frame = CGRect(x: 0, y: self.view.frame.height - 100, width: self.view.frame.width, height: height)
        })
    }
    
}
