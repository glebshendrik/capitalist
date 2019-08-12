//
//  HighlightButton.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 05/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class HighlightButton : UIButton {
    @IBInspectable var backgroundColorForHighlighted: UIColor?
    @IBInspectable var backgroundColorForNormal: UIColor?
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? backgroundColorForHighlighted : backgroundColorForNormal
        }
    }
}

class KeyboardHighlightButton : HighlightButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        // This is required to make the view grow vertically
        self.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.bounds.width, height: 56)
    }    
}
