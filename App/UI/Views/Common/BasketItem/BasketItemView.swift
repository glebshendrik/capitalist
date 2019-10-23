//
//  BasketItemView.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 18/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class BasketItemView : UIView {
    var didSetupConstraints = false
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            setupConstraints()
            didSetupConstraints = true
        }
        super.updateConstraints()
    }
    
    func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        
    }
}
