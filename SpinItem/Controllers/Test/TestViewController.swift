//
//  TestViewController.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 5/4/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit
import CoreMotion

class TestViewController: UIViewController {
    // Views
    var debugTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = UIColor.red
        tv.backgroundColor = UIColor(white: 1, alpha: 1)
        tv.font = UIFont.boldSystemFont(ofSize: 12)
        return tv
    }()
    var balanceView: BalanceView = {
        let bv = BalanceView()
        return bv
    }()
    // Motion Manager
    let motionManager = CMMotionManager()
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        // Do any additional setup after loading the view.
        self.loadSubviews()
        self.setupMotionManager()
    }
    func loadSubviews() {
        view.addSubview(debugTextView)
        view.addSubview(balanceView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let screen = UIScreen.main.bounds.size
        debugTextView.frame = CGRect(x: 0, y: 20, width: screen.width, height: 100)
        balanceView.frame = CGRect(x: 50, y: 120, width: screen.width - 100, height: 200)
    }
    // Attitude Values
    func setupMotionManager() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateAttitudeValue), userInfo: nil, repeats: true)
        }
    }
    @objc func updateAttitudeValue() {
        if let deviceMotion = motionManager.deviceMotion {
            debugTextView.text = "Pitch: \(deviceMotion.attitude.pitch * 180 / Double.pi)"
                + "\nRoll: \(deviceMotion.attitude.roll * 180 / Double.pi)"
                + "\nYaw: \(deviceMotion.attitude.yaw * 180 / Double.pi)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
