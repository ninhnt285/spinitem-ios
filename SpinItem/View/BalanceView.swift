//
//  BalanceView.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 5/5/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit

class BalanceView: UIView {
    var contentLayer: CAShapeLayer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    init() {
        super.init(frame: CGRect.zero)
        customInit()
    }
    
    func customInit() {
        loadSubviews()
        configureSubviews()
    }
    func loadSubviews() {
        
    }
    func configureSubviews() {
        self.clipsToBounds = true
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // Init points
        let margin: CGFloat = 24.0
        let padding: CGFloat = 8.0
        var borderPartWidth = (rect.width - 2 * margin) / 3.0
        if borderPartWidth >= rect.height - 2 * margin {
            borderPartWidth = rect.height - 2 * margin
        }
        let contentPartWidth = borderPartWidth - padding * 2.0 / 3.0
        let centerPoint = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        let contentAngle:CGFloat = asin(1.0 / 3.0)
        
        // Draw content layer
        var yPosition = centerPoint.y - contentPartWidth / 6.0
        let contentPath = UIBezierPath()
        contentPath.move(to: CGPoint(x: margin + padding, y: centerPoint.y))
        contentPath.addLine(to: CGPoint(x: margin + padding + contentPartWidth * 1.5 - cos(contentAngle) * contentPartWidth / 2.0, y: yPosition))
        contentPath.addArc(withCenter: centerPoint, radius: contentPartWidth / 2.0, startAngle: CGFloat.pi + contentAngle, endAngle: CGFloat.pi * 2 - contentAngle, clockwise: true)
        contentPath.addLine(to: CGPoint(x: margin + padding + contentPartWidth * 3, y: centerPoint.y))
        yPosition += contentPartWidth / 3.0
        contentPath.addLine(to: CGPoint(x: margin + padding + contentPartWidth * 1.5 + cos(contentAngle) * contentPartWidth / 2.0, y: yPosition))
        contentPath.addArc(withCenter: centerPoint, radius: contentPartWidth / 2.0, startAngle: contentAngle, endAngle: CGFloat.pi - contentAngle, clockwise: true)
        contentPath.close()
        contentLayer = CAShapeLayer()
        contentLayer?.path = contentPath.cgPath
        contentLayer?.fillColor = UIColor.lightGray.cgColor
        self.layer.addSublayer(contentLayer!)
        
        // Draw line
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2)
        context?.setLineCap(CGLineCap.round)
        context?.beginPath()
        context?.move(to: CGPoint(x: 0, y: centerPoint.y))
        context?.addLine(to: CGPoint(x: rect.width, y: centerPoint.y))
        context?.setStrokeColor(UIColor(red: 0, green: 1, blue: 0, alpha: 0.5).cgColor)
        context?.strokePath()
    }
}
