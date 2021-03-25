//
//  QuestionPollCollectionViewCell.swift
//  Capitalist
//
//  Created by Gleb Shendrik on 23.03.2021.
//  Copyright © 2021 Real Tranzit. All rights reserved.
//

import UIKit

class QuestionPollCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var bottomConstraintStack: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    var delegate: WelcomePollSlideProtocol!
    @IBOutlet weak var titleCell: UILabel!
    @IBOutlet weak var currencyField: UITextField!
    
    func customize() {
        let halfHeight = self.frame.height / 2
        bottomConstraintStack.constant = halfHeight - contentStack.frame.height / 2
        
        currencyField.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
    }
    
    @objc func myTextFieldDidChange(_ textField: UITextField) {

        if let amountString = textField.text {
            let val = Int(amountString)?.moneyDecimalString(with: Currency(code: "", name: "", translatedName: "", symbol: "", subunitToUnit: 1, decimalMark: "", symbolFirst: false, priority: 1, thousandsSeparator: ""))
            textField.text = val
        }
    }
    
}
