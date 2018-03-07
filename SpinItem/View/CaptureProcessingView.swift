//
//  CaptureProcessing.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/7/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit

class CaptureProcessingView: UIView {
    var tickTotal: Int = 36 {
        didSet {
            self.tickMarks = [Bool](repeating: false, count: tickTotal)
        }
    }
    var tickMarks: [Bool] = []
    var currentIndex: Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var text: String = "" {
        didSet {
            self.mainLabel.text = text
        }
    }
    
    private var mainLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    init(frame: CGRect, tickTotal: Int = 36) {
        super.init(frame: frame)
        customInit()
    }
    
    func customInit() {
        loadSubviews()
        configureSubviews()
    }
    
    func loadSubviews() {
        mainLabel = UILabel()
        self.addSubview(mainLabel)
    }
    
    func configureSubviews() {
        self.backgroundColor = UIColor(white: 0, alpha: 0)
        
        tickMarks = [Bool](repeating: false, count: tickTotal)
        text = "Focus on the item \nand Press Start"
        
        self.mainLabel.textColor = UIColor.green
        self.mainLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.mainLabel.textAlignment = NSTextAlignment.center
        self.mainLabel.numberOfLines = 0
    }
    
    override func draw(_ rect: CGRect) {
        let centerPoint = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        let radius = Double(self.frame.size.width / 2 - 10)
        let angleStep = Double.pi * 2 / Double(tickTotal)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2)
        context?.setLineCap(CGLineCap.round)
        
        for i in 0..<tickTotal {
            let angle = angleStep * Double(i)
            let startPoint = CGPoint(
                x: Double(centerPoint.x) + cos(angle) * (radius - 20),
                y: Double(centerPoint.y) + sin(angle) * (radius - 20)
            )
            let endPoint = CGPoint(
                x: Double(centerPoint.x) + cos(angle) * radius,
                y: Double(centerPoint.y) + sin(angle) * radius
            )
            
            context?.beginPath()
            context?.move(to: startPoint)
            context?.addLine(to: endPoint)
            
            if (tickMarks[i]) {
                context?.setStrokeColor(UIColor.green.cgColor)
            } else {
                context?.setStrokeColor(UIColor.lightGray.cgColor)
            }
            if (currentIndex == i) {
                context?.setStrokeColor(UIColor.red.cgColor)
            }
            context?.strokePath()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = self.frame.size
        
        mainLabel.frame.size = CGSize(width: size.width - 70, height: size.height - 70)
        mainLabel.center = CGPoint(x: size.width / 2, y: size.height / 2)
    }
}
