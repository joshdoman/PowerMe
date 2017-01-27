//
//  ContainerViewController.swift
//  WillYou
//
//  Created by Josh Doman on 1/4/17.
//  Copyright © 2017 Josh Doman. All rights reserved.
//

import UIKit

class ChatLogContainerController: UIViewController {
    
    var centerNavigationController: UINavigationController!
    var centerViewController: ChatLogController? {
        didSet {
            centerViewController?.delegate = self
            
            addLeftPanelViewController()
        }
    }
    
    var currentState: SlideOutState = .bothCollapsed {
        didSet {
            let shouldShowShadow = currentState != .bothCollapsed
            showShadowForCenterViewController(shouldShowShadow: shouldShowShadow)
        }
    }
    
    var leftViewController: ChatSidePanelViewController?
    
    let centerPanelExpandedOffset: CGFloat = 60
    
    var delegate: CenterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerNavigationController = UINavigationController(rootViewController: centerViewController!)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMove(toParentViewController: self)
        
        view.backgroundColor = .white
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
    func addLeftPanelViewController() {
        if (leftViewController == nil) {
            leftViewController = ChatSidePanelViewController()
        }
        addChildSidePanelController(sidePanelController: leftViewController!)
    }
    
    func addChildSidePanelController(sidePanelController: ChatSidePanelViewController) {
        sidePanelController.delegate = centerViewController
        
        view.insertSubview(sidePanelController.view, at: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMove(toParentViewController: self)
    }
}

extension ChatLogContainerController: CenterViewControllerDelegate {
    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .leftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func toggleRightPanel() {
    }
    
    func collapseSidePanels() {
        switch (currentState) {
        case .rightPanelExpanded:
            toggleRightPanel()
        case .leftPanelExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
    
    func addRightPanelViewController() {
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .leftPanelExpanded
            
            animateCenterPanelXPosition(targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
            centerViewController?.currentState = currentState
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .bothCollapsed
                
                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil;
                self.centerViewController?.currentState = self.currentState
            }
        }
    }
    
    func animateRightPanel(shouldExpand: Bool) {
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
}

extension ChatLogContainerController: UIGestureRecognizerDelegate {
    // MARK: Gesture recognizer
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
        
        if currentState == .bothCollapsed && !gestureIsDraggingFromLeftToRight {
            return
        }
        
        switch(recognizer.state) {
        case .began:
            if (currentState == .bothCollapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addLeftPanelViewController()
                } else {
                    addRightPanelViewController()
                }
                
                showShadowForCenterViewController(shouldShowShadow: true)
            }
        case .changed:
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translation(in: view).x
            //print(recognizer.view!.center.x / view.bounds.size.width)
            recognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
            if (currentState == .bothCollapsed) {
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                if hasMovedGreaterThanHalfway {
                    self.centerViewController?.currentState = .leftPanelExpanded
                }
            } else {
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x < view.bounds.size.width
                if hasMovedGreaterThanHalfway {
                    self.centerViewController?.currentState = .bothCollapsed
                }
            }
        case .ended:
            if (leftViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
        case .cancelled:
            print("canceled")
        default:
            break
        }
    }
    
}

