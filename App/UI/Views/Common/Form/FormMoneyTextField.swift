//
//  FormMoneyTextField.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 25/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class FormMoneyTextField : FormTextField {
    var moneyTextField: MoneyTextField = MoneyTextField()
    
    var currency: Currency? {
        get { return moneyTextField.currency }
        set { moneyTextField.currency = newValue }
    }
    
    override func createTextField() -> FloatingTextField {
        return moneyTextField
    }
}
