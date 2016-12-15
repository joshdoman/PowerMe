//
//  MasterController.swift
//  WillYou
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class MasterController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var VCArr: [UIViewController]!
    var feedController: FeedController?
    var helpController: HelpController?
    var profileController: ProfileController?
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        
        feedController = FeedController()
        helpController = HelpController()
        profileController = ProfileController()
        
        profileController?.masterController = self
        
        VCArr = [profileController!, helpController!, UINavigationController(rootViewController: feedController!)]
        
        setViewControllers([VCArr[1]], direction: .forward, animated: true, completion: nil)
        
        checkIfUserIsLoggedIn()
    }
    
    func goToGreenVC() {
        setViewControllers([VCArr[1]], direction: .forward, animated: true, completion: nil)
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
        helpController?.user = user
        feedController?.user = user
    }
    
    func fetchUserAndSetupViewControllers() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid  else {
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.setValuesForKeys(dictionary)
                user.uid = uid
                self.setupControllersWithUser(user: user)
            }
            
        }, withCancel: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            
            UserDefaults.standard.setIsLoggedIn(value: false)
            
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            
        } else {
            
            fetchUserAndSetupViewControllers()
            
        }
    }
    
    func handleLogout() {
        UserDefaults.standard.setIsLoggedIn(value: false)
        let sc = SignInController()
        sc.modalTransitionStyle = .crossDissolve
        present(sc, animated: true, completion: nil)
    }
}
