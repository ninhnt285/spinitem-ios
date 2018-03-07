//
//  MainMemberViewController.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/8/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit

class MainMemberViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeNavigationController = UINavigationController(rootViewController: HomeViewController())
        homeNavigationController.tabBarItem = UITabBarItem(title: "All Items", image: UIImage(named: "Home"), tag: 0)
        
        let welcomeCaptureController = WelcomeCaptureViewController()
        welcomeCaptureController.tabBarItem = UITabBarItem(title: "Capture", image: UIImage(named: "Camera"), tag: 0)
        
        let profileController = UINavigationController(rootViewController: ProfileViewController())
        profileController.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.more, tag: 2)
        
        self.viewControllers = [homeNavigationController, welcomeCaptureController, profileController]
    }
}
