//
//  MainVisitorViewController.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/7/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit

class MainVisitorViewController: UIViewController {
    var backgroundImageView: UIImageView!
    var logoImageView: UIImageView!
    var loginButton: RoundedButton!
    @objc var signupButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadSubviews()
        configureSubviews()
    }
    
    func loadSubviews() {
        backgroundImageView = UIImageView(image: UIImage(named: "Background"))
        self.view.addSubview(backgroundImageView)
        
        logoImageView = UIImageView(image: UIImage(named: "Logo"))
        self.view.addSubview(logoImageView)
        
        loginButton = RoundedButton(color: ColorSettings.secondaryColor)
        self.view.addSubview(loginButton)
        
        signupButton = RoundedButton(color: ColorSettings.secondaryColor)
        self.view.addSubview(signupButton)
    }
    
    func configureSubviews() {
//        self.view.addVerticalGradientLayer(topColor: ColorSettings.primaryColor, bottomColor: ColorSettings.secondaryColor)
        
        self.backgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
        
        self.logoImageView.applyShadow(shadowColor: UIColor.black)
        
        self.signupButton.setTitle("Sign Up", for: UIControlState.normal)
        self.signupButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        self.signupButton.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        self.signupButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        self.signupButton.addTarget(self, action: #selector(signupBtn_TouchUpInside(_:)), for: UIControlEvents.touchUpInside)
        
        self.loginButton.setTitle("Log In", for: UIControlState.normal)
        self.loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        self.loginButton.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        self.loginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        self.loginButton.addTarget(self, action: #selector(loginBtn_TouchUpInside(_:)), for: UIControlEvents.touchUpInside)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let screen = UIScreen.main.bounds
        
        backgroundImageView.frame = self.view.frame
        
        // Logo: Center
        let imageSize = logoImageView.image!.size
        let logoImageWidth = min(screen.size.width, screen.size.height, 400) - 24
        logoImageView.frame.size = CGSize(width: logoImageWidth, height: logoImageWidth * imageSize.height / imageSize.width)
        logoImageView.frame.origin = CGPoint(x: (screen.size.width - logoImageWidth) / 2, y: (screen.size.height - logoImageView.frame.size.height) / 2 - 90)
        // Login + Signup Buttons: Go Up From Bottom
        signupButton.frame.size = CGSize(width: screen.size.width - 48, height: 64)
        signupButton.frame.origin = CGPoint(x: 24, y: screen.height - 88)
        
        loginButton.frame.size = CGSize(width: screen.size.width - 48, height: 64)
        loginButton.frame.origin = CGPoint(x: 24, y: screen.height - 176)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = SPAuth.auth().currentUser {
            self.present(MainMemberViewController(), animated: true, completion: nil)
        }
    }
    
    @objc private func signupBtn_TouchUpInside(_ sender: UIButton!) {
        self.present(SignUpViewController(), animated: true, completion: nil)
    }
    
    @objc private func loginBtn_TouchUpInside(_ sender: UIButton!) {
        self.present(LoginViewController(), animated: true, completion: nil)
    }
}
