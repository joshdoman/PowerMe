//
//  MasterController.swift
//  WillYou
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class MasterController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UserDelegate {
    
    
    var VCArr: [UIViewController]!
    var feedController: FeedController!
    var helpController: HelpController!
    var profileController: ProfileController2!
    
    var user: User? {
        didSet {
            Model.currentUser = user
        }
    }
    
    var currentIndex: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        
        feedController = FeedController()
        helpController = HelpController()
        helpController?.view.tag = 1
        profileController = ProfileController2()
        profileController?.view.tag = 0
        
        let nc = UINavigationController(rootViewController: feedController)
        nc.view.tag = 2
        
        VCArr = [profileController, helpController, nc]
        
        setViewControllers([VCArr[1]], direction: .forward, animated: true, completion: nil)
        
        checkIfUserIsLoggedIn()
    }
    
    func goLeftToHelpController(goLeft: Bool) {
        if goLeft {
            setViewControllers([VCArr[1]], direction: .reverse, animated: true, completion: nil)
        } else {
            setViewControllers([VCArr[1]], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else if view is UIPageControl {
                view.backgroundColor = .clear
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let vc = pageViewController.viewControllers else { return }
        guard let first = vc.first else { return }
        
        currentIndex = first.view.tag //Page Index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = VCArr.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard VCArr.count > previousIndex else {
            return nil
        }
        
        return VCArr[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = VCArr.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < VCArr.count else {
            return nil
        }
        
        return VCArr[nextIndex]
    }
    
    func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func setupControllersWithUser(user: User) {
        profileController?.setupProfileControllerWithUser(user: user)
        profileController?.masterController = self
        helpController?.user = user
        helpController?.masterController = self
        feedController?.user = user
        feedController?.masterController = self
    }
    
    func fetchUserAndSetupViewControllers() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid  else {
            return
        }
        
        user = User()
        user?.loadUserUsingCacheWithUserId(uid: uid, controller: self)
    }
    
    func fetchUserAndDoSomething(user: User) {
        setupControllersWithUser(user: user)
        checkIfHasOutstandingRequest()
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            
            UserDefaults.standard.setIsLoggedIn(value: false)
            
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            
        } else {
            
            fetchUserAndSetupViewControllers()
            
        }
    }
    
    func checkIfHasOutstandingRequest() {
        guard let uid = user?.uid, let charger = user?.charger else {
            return
        }
        
        FIRDatabase.database().reference().child("outstanding-requests-by-user").child(charger).child(uid).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            
            UserDefaults.standard.setHasPendingRequest(value: true)
            self.helpController?.request = Request()
            self.helpController?.request?.requestId = snapshot.key
            self.helpController?.setupObserverOfMyRequest()
            
        }, withCancel: nil)
    }
    
    func handleLogout() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        FIRDatabase.database().reference().child("user-messages").removeAllObservers()
        FIRDatabase.database().reference().child("helps").removeAllObservers()
        FIRDatabase.database().reference().child("users").child(uid).child("token").removeValue()
        
        UserDefaults.standard.setIsLoggedIn(value: false)
        let sc = SignInController()
        sc.modalTransitionStyle = .crossDissolve
        present(sc, animated: true, completion: nil)
    }
    
    func removeAllMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        
        ref.observeSingleEvent(of: .value, with: {
            (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let messageIds = Array(dictionary.keys)
                for id in messageIds {
                    self.removeAllMessagesForUser(uid: id)
                    ref.child(id).removeValue()
                }
            }
            
        }, withCancel: nil)
        
    }
    
    func removeAllMessagesForUser(uid: String) {
        guard let myUid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid).child(myUid)

        ref.observeSingleEvent(of: .value, with: {
            (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let messageIds = Array(dictionary.keys)
                for id in messageIds {
                    FIRDatabase.database().reference().child("messages").child(id).removeValue()
                    ref.child(id).removeValue()
                }
            }
            
        }, withCancel: nil)
        
    }
    
    //pass nil helper if want to completely delete request, give helper a value if want to make request permanent
    func removeMyOutstandingRequest(helper: User?) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let charger = user?.charger else {
            return
        }
        
        FIRDatabase.database().reference().child("user-messages").child(uid).removeAllObservers()
        
        let ref = FIRDatabase.database().reference().child("outstanding-requests-by-user").child(charger).child(uid)
        
        ref.observeSingleEvent(of: .childAdded, with: {
            (snapshot) in
            
            let requestId = snapshot.key
            
            if let myHelper = helper {
                self.addCompletedRequest(requestId: requestId, helper: myHelper)
            } else {
                FIRDatabase.database().reference().child("requests").child(requestId).removeValue()
            }
            
            ref.removeValue()
            
            self.removeAllMessages()
            
        }, withCancel: nil)
        
        UserDefaults.standard.setHasPendingRequest(value: false)
        helpController?.showHelpButton()
    }
    
    func addCompletedRequest(requestId: String, helper: User) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let helperId = helper.uid else {
            return
        }
        
        FIRDatabase.database().reference().child("user-requests").child(uid).child(helperId).updateChildValues([requestId: 1])
        FIRDatabase.database().reference().child("user-helps").child(helperId).child(uid).updateChildValues([requestId: 1])
        FIRDatabase.database().reference().child("requests").child(requestId).updateChildValues(["helperId": helperId])
        FIRDatabase.database().reference().child("helps").updateChildValues([requestId: 1])
    }
    
    func setCanSwipe(canSwipe: Bool) {
        if canSwipe {
            self.dataSource = self
        } else {
            self.dataSource = nil
        }
    }
    
}
