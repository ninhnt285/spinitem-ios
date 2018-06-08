//
//  CaptureViewController.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/9/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class CaptureViewController: UIViewController {
    let neededImageNumber = 36
    var processedPhotoNumber = 0
    var captureIndex = 0
    var photos: [SPImage] = []
    var trackIndexs: [Int64?]!
    
    // Camera
    let captureSession = AVCaptureSession()
    var currentCamera: AVCaptureDevice!
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewView: UIView!
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // Capture Processing
    var isStarted: Bool = false
    
    // Motion Manager
    let motionManager = CMMotionManager()
    var timer: Timer!
    
    // Subviews
    var captureProcessingView: CaptureProcessingView!
    var startButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Start", for: UIControlState.normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        btn.setTitleColor(UIColor.green, for: UIControlState.normal)
        btn.addTarget(self, action: #selector(startBtn_TouchUpInside(_:)), for: UIControlEvents.touchUpInside)
        return btn
    }()
    var closeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Close", for: UIControlState.normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        btn.setTitleColor(UIColor.green, for: UIControlState.normal)
        btn.addTarget(self, action: #selector(closeBtn_TouchUpInside(_:)), for: UIControlEvents.touchUpInside)
        return btn
    }()
    var debugTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = UIColor.red
        tv.backgroundColor = UIColor(white: 0, alpha: 0)
        tv.font = UIFont.boldSystemFont(ofSize: 12)
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0..<neededImageNumber {
            photos.append(SPImage())
        }
        // Track index that captured or processing by uniqid
        trackIndexs = [Int64?](repeating: nil, count: neededImageNumber)
        
        loadSubviews()
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        setupRunningCaptureSession()
        setupMotionManager()
    }
    
    // Subviews and Layouts
    func loadSubviews() {
        cameraPreviewView = UIView()
        self.view.addSubview(cameraPreviewView)
        
        captureProcessingView = CaptureProcessingView(frame: CGRect(x: 0, y: 20, width: 100, height: 100), tickTotal: neededImageNumber)
        self.view.addSubview(captureProcessingView)
        
        self.view.addSubview(startButton)
        self.view.addSubview(closeButton)
        self.view.addSubview(debugTextView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let screen = UIScreen.main.bounds
        
        cameraPreviewView.frame = screen
        cameraPreviewLayer?.frame = screen
        
        captureProcessingView.frame.size = CGSize(width: min(screen.width, screen.height), height: min(screen.width, screen.height))
        captureProcessingView.center = self.view.center
        
        startButton.frame.size = startButton.sizeThatFits(CGSize(width: screen.width - 24, height: 100))
        startButton.center = CGPoint(x: screen.width / 2, y: screen.height - 20 - startButton.frame.size.height / 2)
        
        closeButton.frame.size = closeButton.sizeThatFits(CGSize(width: screen.width - 24, height: 100))
        closeButton.frame.origin = CGPoint(x: screen.width - startButton.frame.size.width - 20, y: 20)
        
        debugTextView.frame = CGRect(x: 0, y: 20, width: screen.width - closeButton.frame.width - 24, height: 100)
    }
    
    // Camera
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.back)
        let devices = deviceDiscoverySession.devices
        currentCamera = devices[0]
    }
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = cameraPreviewView.frame
        cameraPreviewView.layer.addSublayer(cameraPreviewLayer!)
    }
    func setupRunningCaptureSession() {
        UIApplication.shared.isIdleTimerDisabled = true
        captureSession.startRunning()
    }
    
    // Attitude Values
    func setupMotionManager() {
        motionManager.startDeviceMotionUpdates()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateAttitudeValue), userInfo: nil, repeats: true)
    }
    @objc func updateAttitudeValue() {
        if let deviceMotion = motionManager.deviceMotion {
            debugTextView.text = "Pitch: \(deviceMotion.attitude.pitch * 180 / Double.pi)"
                + "\nRoll: \(deviceMotion.attitude.roll * 180 / Double.pi)"
                + "\nYaw: \(deviceMotion.attitude.yaw * 180 / Double.pi)"
            
            if let index = getIndexFromAngle(angle: deviceMotion.attitude.yaw) {
                self.captureProcessingView.currentIndex = index
                if isStarted {
                    capturePhoto(index: index)
                }
            }
        }
    }
    func getIndexFromAngle(angle: Double) -> Int? {
        let angleStep = Double.pi * 2 / Double(self.neededImageNumber)
        let epsilon = (angleStep / 10 < 0.03) ? 0.03 : angleStep / 10
        var newAngle = angle
        if newAngle < 0 {
            newAngle += (2 * Double.pi)
        }
        if (newAngle < epsilon) || (newAngle > 2 * Double.pi - epsilon) {
            return 0
        }
        let index = Int(newAngle / angleStep)
        if (abs(newAngle - angleStep * Double(index)) < epsilon) {
            return index
        }
        return nil
    }
    func getIndexFromUniqueId(uniqueId: Int64) -> Int {
        for i in 0...(neededImageNumber-1) {
            if trackIndexs[i] == uniqueId {
                return i
            }
        }
        return -1
    }
    
    // Handlers
    func startPreview() {
        timer.invalidate()
        motionManager.stopDeviceMotionUpdates()
        captureSession.stopRunning()
        UIApplication.shared.isIdleTimerDisabled = false
        
        let previewController = PreviewViewController(previewImages: self.photos)
        previewController.canSaveImage = true
        self.present(previewController, animated: true, completion: nil)
    }
    
    @objc func startBtn_TouchUpInside(_ sender: UIButton) {
        self.captureProcessingView.text = "Captured Photos:\n\(processedPhotoNumber)/\(neededImageNumber)"
        isStarted = !isStarted
        if (isStarted) {
            sender.setTitle("Pause", for: UIControlState.normal)
        } else {
            sender.setTitle("Start", for: UIControlState.normal)
        }
        
        let screen = UIScreen.main.bounds
        startButton.frame.size = startButton.sizeThatFits(CGSize(width: screen.width - 24, height: 100))
    }
    
    @objc func closeBtn_TouchUpInside(_ sender: UIButton) {
        timer.invalidate()
        motionManager.stopDeviceMotionUpdates()
        captureSession.stopRunning()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func capturePhoto(index: Int) {
        if trackIndexs[index] == nil {
            photos[index].captureIndex = captureIndex
            let settings = AVCapturePhotoSettings()
            trackIndexs[index] = settings.uniqueID
            photoOutput?.capturePhoto(with: settings, delegate: self)
            captureIndex += 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIStatusBarStyle.lightContent
        }
    }
}

extension CaptureViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let index = getIndexFromUniqueId(uniqueId: photo.resolvedSettings.uniqueID)
        if index >= 0 {
            if let imageData = photo.fileDataRepresentation() {
                photos[index].index = index
                photos[index].isActive = true
                photos[index].fileData = imageData
                processedPhotoNumber += 1
                
                self.captureProcessingView.tickMarks[index] = true
                self.captureProcessingView.setNeedsDisplay()
                
                self.captureProcessingView.text = "Captured Photos:\n\(processedPhotoNumber)/\(neededImageNumber)"
                
                if (processedPhotoNumber == neededImageNumber) {
                    self.startPreview()
                }
            }
        }
    }
}
