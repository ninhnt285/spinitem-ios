//
//  PreviewView.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/13/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit

class PreviewView: UIImageView {
    var currentImageIndex = 0 {
        didSet {
            if images.count > 0 {
                if currentImageIndex < 0 {
                    currentImageIndex = images.count - 1
                }
                if currentImageIndex >= images.count {
                    currentImageIndex = 0
                }
                self.image = images[currentImageIndex]
            } else {
                self.image = UIImage(named: "Logo")
            }
            self.contentMode = UIViewContentMode.scaleAspectFit
        }
    }
    var distanceX: CGFloat = 0
    var lastUpdateTime: Double = 0
    var images: [UIImage] = [] {
        didSet {
            self.currentImageIndex = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(images: [UIImage]) {
        super.init(frame: CGRect.zero)
        self.images = images
        customInit()
    }
    
    func customInit() {
        loadSubviews()
        configureSubviews()
    }
    
    func loadSubviews() {
        if images.count > 0 {
            self.image = images[0]
        } else {
            self.image = UIImage(named: "Logo")
        }
        self.contentMode = UIViewContentMode.scaleAspectFit
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(panGesture)
    }
    
    func configureSubviews() {
        self.backgroundColor = UIColor(white: 0, alpha: 0)
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        let epsilonX: CGFloat = 3
        
        distanceX += translation.x
        if (distanceX > epsilonX) {
            currentImageIndex += 1
            distanceX = 0
        }
        if (distanceX < -epsilonX) {
            currentImageIndex -= 1
            distanceX = 0
        }
        
        sender.setTranslation(CGPoint.zero, in: self)
    }
}
