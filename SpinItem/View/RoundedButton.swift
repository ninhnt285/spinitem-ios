//
//  RoundedWhiteButton.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/7/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    var highlightedColor = UIColor.white
    {
        didSet {
            if isHighlighted {
                backgroundColor = highlightedColor
            }
        }
    }
    
    var defaultColor = UIColor.clear
    {
        didSet {
            if !isHighlighted {
                backgroundColor = defaultColor
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = highlightedColor
                
            } else {
                backgroundColor = defaultColor
            }
        }
    }
    
    var mainColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = mainColor.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    init(color: UIColor) {
        super.init(frame: CGRect.zero)
        self.mainColor = color
        setup()
    }
    
    func setup() {
        self.layer.borderColor = mainColor.cgColor
        self.layer.borderWidth = 2.0
        self.clipsToBounds = true
        self.setTitleColor(mainColor, for: UIControlState.normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
    }
}
