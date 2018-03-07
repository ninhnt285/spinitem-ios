//
//  ProfileViewController.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/8/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    var logoutButton: UIBarButtonItem!
    var planLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadSubviews()
        configureSubviews()
    }
    
    func loadSubviews() {
        logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleLogout(_:)))
        self.navigationItem.setRightBarButton(logoutButton, animated: true)
        
        planLabel = UILabel()
        view.addSubview(planLabel)
    }
    
    func configureSubviews() {
        self.title = "Profile"
        self.view.backgroundColor = ColorSettings.backgroundColor
        
        planLabel.text = "Your Plan: Trial"
        planLabel.font = UIFont.systemFont(ofSize: 18)
        planLabel.textAlignment = NSTextAlignment.center
    }
    
    override func viewWillLayoutSubviews() {
        let screen = UIScreen.main.bounds
        
        planLabel.frame.size = planLabel.sizeThatFits(screen.size)
        planLabel.center = CGPoint(x: screen.width / 2, y: (self.navigationController?.navigationBar.frame.height ?? 0) + planLabel.frame.size.height / 2 + 32)
    }

    @objc func handleLogout(_ sender: Any) {
        try! SPAuth.auth().signOut()
        self.dismiss(animated: false, completion: nil)
    }
}
