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
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        commonInit()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        commonInit()
//    }
//    
//    private func commonInit() {
//        addTarget(self, action: #selector(touchUp(sender:)), for: UIControl.Event.touchUpInside)
//        addTarget(self, action: #selector(touchUp(sender:)), for: UIControl.Event.touchUpOutside)
//        addTarget(self, action: #selector(touchUp(sender:)), for: UIControl.Event.touchCancel)
//        addTarget(self, action: #selector(touchDown(sender:)), for: UIControl.Event.touchDown)
//    }
//    
//    @objc private func touchDown(sender: UIButton) {
//        backgroundColor = backgroundColorForHighlighted
//    }
//    
//    @objc private func touchUp(sender: UIButton) {
//        backgroundColor = backgroundColorForNormal
//    }
}
