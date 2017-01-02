//
//  ProfileController2.swift
//  WillYou
//
//  Created by Josh Doman on 12/20/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class ProfileController2: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, RequestDelegate {
    
    var masterController: MasterController?
    var user: User? {
        didSet {
            observeMyRequests()
            chargerImageView.image = UIImage(named: (user?.charger)!)
            //chargerLabel.text = (user?.charger)!
        }
    }
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
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
    
    let activityLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Activity"
        label.textAlignment = NSTextAlignment.center
        label.font = label.font.withSize(20)
        label.textColor = Model.blueColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let chargerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let chargerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let chargerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.font = label.font.withSize(17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let saveCellId = "saveCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = scrollView
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height - 50 + 90)
        
        tableView.frame = CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: getTableViewHeight())
        tableView.register(SaveCell.self, forCellReuseIdentifier: saveCellId)
        tableView.delegate = self
        tableView.dataSource = self
        
        setupViews()
        
    }
    
    func getTableViewHeight() -> CGFloat {
        return CGFloat(max(90, 90 * requests.count))
    }
    
    func setupViews() {
        scrollView.addSubview(profileImageView)
        scrollView.addSubview(logoutButton)
        scrollView.addSubview(tableView)
        scrollView.addSubview(chargerImageView)
        scrollView.addSubview(activityLabel)
        scrollView.addSubview(nameLabel)

        profileImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 75).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        nameLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20).isActive = true
        
        logoutButton.bottomAnchor.constraint(equalTo: profileImageView.topAnchor, constant: -20).isActive = true
        logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        activityLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -10).isActive = true
        activityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        chargerImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30).isActive = true
        chargerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        chargerImageView.bottomAnchor.constraint(equalTo: activityLabel.topAnchor, constant: -30).isActive = true
        chargerImageView.widthAnchor.constraint(equalToConstant: 220).isActive = true
        
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
    
    func updateProfileImage() {
        guard let uid = user?.uid else {
            return
        }
                
        let imageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
        
        if let image = profileImageView.image {
            if let uploadData = UIImageJPEGRepresentation(image, 0.1) {
            
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                    if error != nil {
                        print(error!)
                        return
                    }
                
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        FIRDatabase.database().reference().child("users").child(uid).updateChildValues(["profileImageUrl": profileImageUrl])
                    }
                })
            }
        }
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
        FIRDatabase.database().reference().child("helps").removeAllObservers()
        //FIRDatabase.database().reference().child("user-requests").child((user?.uid)!).removeAllObservers()
        //FIRDatabase.database().reference().child("user-helps").child((user?.uid)!).removeAllObservers()
        
        masterController?.handleLogout()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !requests.isEmpty {
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
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.text = "No activity yet"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .lightGray
            cell.textLabel?.font =  UIFont.systemFont(ofSize: 25)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, requests.count)
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
        
        self.timer2?.invalidate()
        self.timer2 = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(handleSecondReload), userInfo: nil, repeats: false)
    }
    
    func handleSecondReload() {
        //attemptReloadOfTable()
    }
    
    private func fetchRequestWithKey(child: String, id: String) {
        FIRDatabase.database().reference().child(child).child((user?.uid)!).child(id).observe(.childAdded, with: { (snapshot) in
            self.fetchRequestWithRequestId(requestId: snapshot.key)
        }, withCancel: nil)
    }
    
    private func fetchRequestWithRequestId(requestId: String) {
        let request = Request()
        request.loadRequestUsingCacheWithRequestId(requestId: requestId, controller: self)
        requestDictionary[requestId] = request
    }
    
    func fetchRequestsAndDoSomething() {
        attemptReloadOfTable()
    }
    
    var timer: Timer?
    var timer2: Timer?
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable() {
        self.requests = Array(self.requestDictionary.values)
        self.requests.sort(by: { (request1, request2) -> Bool in
            if let t1 = request1.timestamp?.intValue, let t2 = request2.timestamp?.intValue {
                return t1 > t2
            } else {
                return false
            }
        })
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            let height = CGFloat(90 * self.requests.count)
            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + height - 50)
            self.tableView.frame = CGRect(x: 0, y: self.view.frame.height - 50, width: self.view.frame.width, height: height)
        })
    }
}
