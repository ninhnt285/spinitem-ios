//
//  SplashController.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/7/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    var activityIndicator: UIActivityIndicatorView!
    var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSubviews()
        configureSubviews()
        self.view.backgroundColor = UIColor.white
    }
    
    func loadSubviews() {
        backgroundImageView = UIImageView(image: UIImage(named: "Background"))
        self.view.addSubview(backgroundImageView)
        
        activityIndicator = UIActivityIndicatorView()
        self.view.addSubview(activityIndicator)
    }
    
    func configureSubviews() {
//        self.view.addVerticalGradientLayer(topColor: ColorSettings.primaryColor, bottomColor: ColorSettings.secondaryColor)
        backgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
        
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.startAnimating()
    }
    
    override func viewWillLayoutSubviews() {
        let screen = UIScreen.main.bounds
        // Set layout for background image
        self.backgroundImageView.frame = self.view.frame
        
        // Set layout for activity indicator
        self.activityIndicator.frame = CGRect(x: (screen.size.width - 20) / 2, y: (screen.size.height - 20) / 2, width: 20, height: 20)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = SPAuth.auth().currentUser {
            self.present(MainMemberViewController(), animated: true, completion: nil)
        } else {
            self.present(MainVisitorViewController(), animated: false, completion: nil)
        }
    }
}
