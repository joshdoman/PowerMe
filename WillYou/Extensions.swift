//
//  Extensions.swift
//  WillYou
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

let imageCache = NSCache<AnyObject, AnyObject>()
let requestCache = NSCache<AnyObject, AnyObject>()
let userCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, resp, err) in
            
            if err != nil {
                print(err!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
    
}

extension Request {
    
    func loadRequestUsingCacheWithRequestId(requestId: String, controller: RequestDelegate) {
        
        if let cachedRequest = requestCache.object(forKey: requestId as AnyObject) as? Request {
            self.copyRequest(request: cachedRequest)
            controller.fetchRequestsAndDoSomething()
            return
        }
        
        FIRDatabase.database().reference().child("requests").child(requestId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let request = Request()
                request.setValuesForKeys(dictionary)
                request.requestId = requestId
                if let helperId = request.helperId {
                    request.helper = User()
                    request.helper?.loadUserUsingCacheWithUserId(uid: helperId, controller: controller, fromRequest: true)
                }
                self.copyRequest(request: request)
                requestCache.setObject(self, forKey: requestId as AnyObject)
            }
            
            if self.helperId == nil {
                controller.fetchRequestsAndDoSomething()
            }
            
        }, withCancel: nil)
        
    }
}

extension User {
    
    func loadUserUsingCacheWithUserId(uid: String, controller: UserDelegate) {
        if let cachedUser = userCache.object(forKey: uid as AnyObject) as? User {
            self.copyUser(user: cachedUser)
            controller.fetchUserAndDoSomething(user: self)
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.setValuesForKeys(dictionary)
                self.uid = uid
                userCache.setObject(self, forKey: uid as AnyObject)
            }
            
            controller.fetchUserAndDoSomething(user: self)
            
        }, withCancel: nil)
        
    }
    
    func loadUserUsingCacheWithUserId(uid: String, controller: RequestDelegate, fromRequest: Bool) {
        
        if let cachedUser = userCache.object(forKey: uid as AnyObject) as? User {
            self.copyUser(user: cachedUser)
            controller.fetchRequestsAndDoSomething()
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.setValuesForKeys(dictionary)
                self.uid = uid
                userCache.setObject(self, forKey: uid as AnyObject)
            }
            
            controller.fetchRequestsAndDoSomething()
            
        }, withCancel: nil)
        
    }
    
    func loadUserUsingCacheWithUserId(uid: String) {
        
        if let cachedUser = userCache.object(forKey: uid as AnyObject) as? User {
            self.copyUser(user: cachedUser)
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.setValuesForKeys(dictionary)
                self.uid = uid
                requestCache.setObject(self, forKey: uid as AnyObject)
            }
                        
        }, withCancel: nil)
        
    }
}

extension UIView {
    
    func anchorToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {
        
        anchorWithConstantsToTop(top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    func anchorWithConstantsToTop(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0) {
        
        _ = anchor(top, left: left, bottom: bottom, right: right, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant)
    }
    
    func anchor(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
    
}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}

extension UserDefaults {
    
    enum UserDefaultsKeys: String {
        case isLoggedIn
        case hasPendingRequest
        case isMessaging
    }
    
    func setIsLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    func setHasPendingRequest(value: Bool) {
        set(value, forKey: UserDefaultsKeys.hasPendingRequest.rawValue)
        synchronize()
    }
    
    func hasPendingRequest() -> Bool {
        return bool(forKey: UserDefaultsKeys.hasPendingRequest.rawValue)
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
}

extension UILabel {
    func textHeight(with width: CGFloat) -> CGFloat {
        guard let text = text else {
            return 0
        }
        return text.height(with: width, font: font)
    }
}

extension String {
    func height(with width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSFontAttributeName: font], context: nil)
        return actualSize.height
    }
}

extension UIBarButtonItem {
    static func itemWith(colorfulImage: UIImage?, target: AnyObject, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(colorfulImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(r: 0, g: 122, b: 255)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }
}
