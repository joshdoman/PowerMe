//
//  CenterViewController.swift
//  WillYou
//
//  Created by Josh Doman on 1/4/17.
//  Copyright © 2017 Josh Doman. All rights reserved.
//

import UIKit

class CenterViewController: UIViewController {
    
    var delegate: CenterViewControllerDelegate? {
        didSet {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Show", style: .plain, target: self, action: #selector(handleShow))
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
    }
    
    func handleShow() {
        delegate?.toggleLeftPanel!()
    }
    
}

extension CenterViewController: SidePanelViewControllerDelegate {
    func buttonSelected(button: ButtonState) {
        switch (button) {
        case .done:
            print("done")
        case .cancel:
            print("cancel")
        }
        
        delegate?.collapseSidePanels?()
    }
}

