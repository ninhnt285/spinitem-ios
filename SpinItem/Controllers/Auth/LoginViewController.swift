//
//  LoginViewController.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/7/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    var keyboardHeight: CGFloat = 0.0
    var scrollView: UIScrollView!
    var titleLabel: UILabel!
    var emailLabel: UILabel!
    var emailField: UITextField!
    var emailLine: UIView!
    var passwordLabel: UILabel!
    var passwordField: UITextField!
    var passwordLine: UIView!
    
    var dismissButton: UIButton!
    var continueButton: RoundedButton!
    var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSubviews()
        configureSubviews()
    }
    
    func loadSubviews() {
        self.scrollView = UIScrollView()
        self.titleLabel = UILabel()
        self.scrollView.addSubview(self.titleLabel)
        
        self.emailLabel = UILabel()
        self.scrollView.addSubview(self.emailLabel)
        self.emailField = UITextField()
        self.scrollView.addSubview(self.emailField)
        self.emailLine = UIView()
        self.scrollView.addSubview(self.emailLine)
        
        self.passwordLabel = UILabel()
        self.scrollView.addSubview(self.passwordLabel)
        self.passwordField = UITextField()
        self.scrollView.addSubview(self.passwordField)
        self.passwordLine = UIView()
        self.scrollView.addSubview(self.passwordLine)
        
        self.view.addSubview(scrollView)
        
        self.dismissButton = UIButton()
        self.view.addSubview(self.dismissButton)
        
        self.continueButton = RoundedButton(color: UIColor.white)
        self.view.addSubview(self.continueButton)
        
        self.activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.view.addSubview(self.activityView)
    }
    
    func configureSubviews() {
        self.view.addVerticalGradientLayer(topColor: ColorSettings.primaryColor, bottomColor: ColorSettings.secondaryColor)
        
        titleLabel.text = "Log In"
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        titleLabel.textColor = UIColor.white
        
        emailLabel.text = "EMAIL"
        emailLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        emailLabel.textColor = UIColor.white
        emailField.delegate = self
        emailField.addTarget(self, action: #selector(textFieldChanged(_:)), for: UIControlEvents.editingChanged)
        emailField.textContentType = UITextContentType.emailAddress
        emailField.keyboardType = UIKeyboardType.emailAddress
        emailField.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)
        emailField.textColor = UIColor.white
        emailField.returnKeyType = UIReturnKeyType.next
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.spellCheckingType = .no
        emailLine.backgroundColor = UIColor.white
        
        passwordLabel.text = "PASSWORD"
        passwordLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        passwordLabel.textColor = UIColor.white
        passwordField.delegate = self
        passwordField.addTarget(self, action: #selector(textFieldChanged(_:)), for: UIControlEvents.editingChanged)
        passwordField.textContentType = UITextContentType.password
        passwordField.isSecureTextEntry = true
        passwordField.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)
        passwordField.textColor = UIColor.white
        passwordField.returnKeyType = UIReturnKeyType.next
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.spellCheckingType = .no
        passwordLine.backgroundColor = UIColor.white
        
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        dismissButton.setImage(UIImage(named: "BackArrow"), for: UIControlState.normal)
        dismissButton.addTarget(self, action: #selector(self.dismissBtn_TouchUpInside(_:)), for: UIControlEvents.touchUpInside)
        
        continueButton.setTitleColor(ColorSettings.secondaryColor, for: .normal)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        continueButton.highlightedColor = UIColor(white: 1.0, alpha: 1.0)
        continueButton.defaultColor = UIColor.white
        continueButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        setContinueButton(enabled: false)
        
        activityView.color = ColorSettings.secondaryColor
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let screen = UIScreen.main.bounds
        
        dismissButton.frame = CGRect(x: 0, y: 20, width: 44, height: 44)
        
        var y: CGFloat = 84
        titleLabel.frame = CGRect(x: 48, y: y, width: screen.width - 96, height: 24)
        y += 48
        
        emailLabel.frame = CGRect(x: 48, y: y, width: screen.width - 96, height: 17)
        y += 29
        emailField.frame = CGRect(x: 48, y: y, width: screen.width - 96, height: 22)
        emailLine.frame = CGRect(x: 48, y: y + 26, width: screen.width - 96, height: 1)
        y += 44
        
        passwordLabel.frame = CGRect(x: 48, y: y, width: screen.width - 96, height: 17)
        y += 29
        passwordField.frame = CGRect(x: 48, y: y, width: screen.width - 96, height: 22)
        passwordLine.frame = CGRect(x: 48, y: y + 26, width: screen.width - 96, height: 1)
        y += 44
        
        scrollView.frame = self.view.frame
        scrollView.contentSize = CGSize(width: screen.width, height: max(screen.height, y))
        scrollView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        continueButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        continueButton.center = CGPoint(x: view.center.x,
                                        y: view.frame.height - keyboardHeight - 16.0 - continueButton.frame.height / 2)
        
        activityView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        activityView.center = continueButton.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector:#selector(self.keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    @objc func keyboardWillAppear(_ notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        keyboardHeight = keyboardFrame.height
        continueButton.center = CGPoint(x: view.center.x,
                                        y: view.frame.height - keyboardHeight - 16.0 - continueButton.frame.height / 2)
        activityView.center = continueButton.center
    }
    
    @objc func textFieldChanged(_ target:UITextField) {
        let email = emailField.text
        let password = passwordField.text
        let formFilled = email != nil && email != "" && password != nil && password != ""
        setContinueButton(enabled: formFilled)
        
        continueButton.center = CGPoint(x: view.center.x,
                                        y: view.frame.height - keyboardHeight - 16.0 - continueButton.frame.height / 2)
        activityView.center = continueButton.center
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            emailField.resignFirstResponder()
            passwordField.becomeFirstResponder()
            break
        case passwordField:
            handleLogin()
            break
        default:
            break
        }
        return true
    }
    
    func setContinueButton(enabled:Bool) {
        if enabled {
            continueButton.alpha = 1.0
            continueButton.isEnabled = true
        } else {
            continueButton.alpha = 0.5
            continueButton.isEnabled = false
        }
    }
    
    @objc func handleLogin() {
        guard let email = emailField.text else { return }
        guard let pass = passwordField.text else { return }
        
        setContinueButton(enabled: false)
        continueButton.setTitle("", for: .normal)
        activityView.startAnimating()
        
        SPAuth.auth().signIn(withEmail: email, password: pass) { (user, error) in
            DispatchQueue.main.async(execute: {
                if error == nil && user != nil {
                    self.dismiss(animated: false, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Error", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    self.setContinueButton(enabled: true)
                    self.continueButton.setTitle("Continue", for: UIControlState.normal)
                    self.activityView.stopAnimating()
                }
            })
        }
    }
    
    @objc func dismissBtn_TouchUpInside(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
