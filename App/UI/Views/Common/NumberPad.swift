//
//  NumberPad.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 30/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol NumberPadDelegate {
    func didTapDigit(digit: Int)
    func didTapBackspace()
    func didTapPoint()
    func didTapPositiveNegativeSwitch()
}

class NumberPad : CustomView {
    @IBOutlet weak var positiveNegativeSwitchButton: UIButton!
    
    @IBAction func didTapNumber(_ sender: Any) {
    }
    
    @IBAction func didTapBackspace(_ sender: Any) {
    }
    @IBAction func didTapPoint(_ sender: Any) {
    }
    @IBAction func didTapPositiveNegativeSwitch(_ sender: Any) {
    }
    
}
