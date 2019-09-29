    //
//  Slider.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 29/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
    
class Slider : UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let point = CGPoint(x: bounds.minX, y: bounds.midY)
        return CGRect(origin: point, size: CGSize(width: bounds.width, height: 3))
    }
}
