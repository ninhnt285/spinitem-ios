//
//  CaptureViewControllerOld.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/3/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class CaptureViewControllerOld: UIViewController, AVCapturePhotoCaptureDelegate {
    // Camera
    let captureSession = AVCaptureSession()
    var currentCamera: AVCaptureDevice!
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // Captured Images
    let neededImageNumber = 36
    var processedPhotoNumber = 0
    var photos: [UIImage?]!
    var trackIndexs: [Int64]!
    var currentPreviewIndex: Int = 0
    
    // Motion Manager
    let motionManager = CMMotionManager()
    var timer: Timer!
    
    // View Items
    @IBOutlet weak var capturePreviewView: UIView!
    @IBOutlet weak var debugTextView: UITextView!
    @IBOutlet weak var processedPreviewImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photos = [UIImage?](repeating: nil, count: neededImageNumber)
        trackIndexs = [Int64](repeating: -1, count: neededImageNumber)
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        setupRunningCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cameraPreviewLayer?.frame = capturePreviewView.frame
    }
    
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
        cameraPreviewLayer?.frame = capturePreviewView.frame
        capturePreviewView.layer.addSublayer(cameraPreviewLayer!)
    }
    
    func setupRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    func setupMotionManager() {
        motionManager.startDeviceMotionUpdates()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func stopMotionManager() {
        timer.invalidate()
        motionManager.stopDeviceMotionUpdates()
    }

    @objc func update() {
        if let deviceMotion = motionManager.deviceMotion {
            self.debugTextView.text = "Pitch: \(deviceMotion.attitude.pitch * 180 / Double.pi)"
                + "\nRoll: \(deviceMotion.attitude.roll * 180 / Double.pi)"
                + "\nYaw: \(deviceMotion.attitude.yaw * 180 / Double.pi)"
            
            if let index = getIndexFromAngle(angle: deviceMotion.attitude.yaw) {
                if trackIndexs[index] == -1 {
                    photos[index] = UIImage()
                    capturePhoto(index: index)
                }
            }
        }
    }
    
    func capturePhoto(index: Int) {
        let settings = AVCapturePhotoSettings()
        trackIndexs[index] = settings.uniqueID
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    func getIndexFromAngle(angle: Double) -> Int? {
        let corner = 360.0 / Double(neededImageNumber)
        let epsilon = (corner / 10 < 3.0) ? 3.0 : corner / 10
        
        var newAngle = angle
        if newAngle < 0 {
            newAngle += (2 * Double.pi)
        }
        newAngle = newAngle * 180 / Double.pi
        self.debugTextView.text = "\(newAngle)"
        
        if (newAngle < epsilon) || (newAngle > 360.0 - epsilon) {
            return 0
        }
        
        let index = Int(newAngle / corner)
        if (abs(newAngle - corner * Double(index)) < epsilon) {
            return index
        }
        
        return nil
    }
    
    func getIndexFromUniqueId(uniqueId: Int64) -> Int {
        for i in 0...35 {
            if trackIndexs[i] == uniqueId {
                return i
            }
        }
        return -1
    }
    
    func startPreview() {
        processedPreviewImage.contentMode = UIViewContentMode.scaleAspectFill
        processedPreviewImage.image = photos[currentPreviewIndex]
        processedPreviewImage.isHidden = false
        cameraPreviewLayer?.isHidden = true
        
        stopMotionManager()
        captureSession.stopRunning()
    }
    
    @IBAction func startBtn_TouchUpInside(_ sender: UIButton) {
        cameraPreviewLayer?.isHidden = false
        processedPreviewImage.isHidden = true
        photos = [UIImage?](repeating: nil, count: neededImageNumber)
        processedPhotoNumber = 0
        
        setupMotionManager()
        setupRunningCaptureSession()
    }
    
    @IBAction func forwardBtn_TouchUpInside(_ sender: Any) {
        currentPreviewIndex += 1
        if (currentPreviewIndex >= neededImageNumber) {
            currentPreviewIndex = 0
        }
        processedPreviewImage.image = photos[currentPreviewIndex]
    }
    
    @IBAction func previousBtn_TouchUpInside(_ sender: Any) {
        currentPreviewIndex -= 1
        if (currentPreviewIndex < 0) {
            currentPreviewIndex = neededImageNumber - 1
        }
        processedPreviewImage.image = photos[currentPreviewIndex]
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let index = getIndexFromUniqueId(uniqueId: photo.resolvedSettings.uniqueID)
        if index >= 0 {
            if let imageData = photo.fileDataRepresentation() {
                photos[index] = UIImage(data: imageData)
                processedPhotoNumber += 1
                if (processedPhotoNumber == neededImageNumber) {
                    startPreview()
                }
            }
        }
    }
}
