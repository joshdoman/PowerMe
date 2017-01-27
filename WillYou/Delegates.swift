//
//  Delegates.swift
//  WillYou
//
//  Created by Josh Doman on 12/26/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import Foundation

protocol RequestDelegate: class {
    func fetchRequestsAndDoSomething()
}

protocol UserDelegate: class {
    func fetchUserAndDoSomething(user: User)
}

@objc
protocol CenterViewControllerDelegate {
    @objc optional func toggleLeftPanel()
    @objc optional func toggleRightPanel()
    @objc optional func collapseSidePanels()
}

protocol SidePanelViewControllerDelegate {
    func buttonSelected(button: ButtonState)
    func getIsRequester() -> Bool
}

