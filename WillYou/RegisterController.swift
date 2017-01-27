//
//  LoginController.swift
//  WillYou
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

class RegisterController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
        
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal //makes cells swipe horizontally
        layout.minimumLineSpacing = 0 //decreases gap between cells
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false //disables scrolling
        cv.isPagingEnabled = true //makes the cells snap (paging behavior)
        return cv
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var currentPage: Int = 0
    
    var bottomViewTopAnchor: NSLayoutConstraint?
    var bottomViewBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentPage = 0
        
        view.addSubview(collectionView)
        view.addSubview(bottomView)
        bottomView.addSubview(nextButton)
        
        collectionView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        bottomViewTopAnchor = bottomView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 75)
        bottomViewTopAnchor?.isActive = true
        bottomView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bottomViewBottomAnchor = bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomViewBottomAnchor?.isActive = true
        bottomView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        nextButton.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
        nextButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        
        observeKeyboardNotifications()
        
        registerCells()
    }
    
    let registerInfoId = "registerInfoId"
    let registerChargerId = "registerChargerId"
    let registerPhotoId = "registerPhotoId"
    let successId = "successId"
    
    var registerInfoCell: RegisterInfoCell?
    var registerChargerCell: RegisterChargerCell?
    var registerPhotoCell: RegisterPhotoCell?
    
    
    fileprivate func registerCells() {
        collectionView.register(RegisterInfoCell.self, forCellWithReuseIdentifier: registerInfoId)
        collectionView.register(RegisterChargerCell.self, forCellWithReuseIdentifier: registerChargerId)
        collectionView.register(RegisterPhotoCell.self, forCellWithReuseIdentifier: registerPhotoId)
        collectionView.register(SuccessCell.self, forCellWithReuseIdentifier: successId)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height) //makes cell size of frame
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: registerInfoId, for: indexPath) as! RegisterInfoCell
            registerInfoCell = cell
            cell.registerController = self
            return cell
        } else if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: registerChargerId, for: indexPath) as! RegisterChargerCell
            registerChargerCell = cell
            return cell
        } else if indexPath.item == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: registerPhotoId, for: indexPath) as! RegisterPhotoCell
            cell.registerController = self
            registerPhotoCell = cell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: successId, for: indexPath)
            return cell
        }
    }
    
    func showImagePicker() {
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
            registerPhotoCell?.profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func resignAllFirstResponders() {
        registerInfoCell?.nameTextField.resignFirstResponder()
        registerInfoCell?.emailTextField.resignFirstResponder()
        registerInfoCell?.passwordTextField.resignFirstResponder()
    }
    
}

