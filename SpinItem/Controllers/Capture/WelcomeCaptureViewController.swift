//
//  WelcomeCaptureViewController.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/8/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit
import CoreMotion

class WelcomeCaptureViewController: UIViewController {
    let motion = CMMotionManager()
    
    var captureInsideButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        btn.backgroundColor = UIColor.gray
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
        btn.setImage(UIImage(named: "CaptureInside"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(handleStartCapture), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
    var captureOutsideButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        btn.backgroundColor = UIColor.gray
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
        btn.setImage(UIImage(named: "CaptureOutside"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(handleStartCapture), for: UIControlEvents.touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSubviews()
        configureSubviews()
    }
    
    func loadSubviews() {
        view.addSubview(captureInsideButton)
        view.addSubview(captureOutsideButton)
    }
    
    func configureSubviews() {
        self.view.backgroundColor = ColorSettings.backgroundColor
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let screen = UIScreen.main.bounds
        let buttonHeight = captureInsideButton.frame.height / 2
        
        if screen.width > screen.height {
            captureInsideButton.center = CGPoint(x: screen.width / 2 - buttonHeight - 15, y: screen.height / 2)
            captureOutsideButton.center = CGPoint(x: screen.width / 2 + buttonHeight + 15, y: screen.height / 2)
        } else {
            captureInsideButton.center = CGPoint(x: screen.width / 2, y: screen.height / 2 - buttonHeight - 15)
            captureOutsideButton.center = CGPoint(x: screen.width / 2, y: screen.height / 2 + buttonHeight + 15)
        }
    }
    
    @objc func handleStartCapture() {
        if motion.isDeviceMotionAvailable {
            self.present(CaptureViewController(), animated: true, completion: nil)
        }
    }
}
