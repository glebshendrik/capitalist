//
//  FormMoneyTextField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 25/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class FormMoneyTextField : FormTextField {
    var moneyTextField: MoneyTextField! {
        return textField as? MoneyTextField
    }
    
    override func createTextField() -> FloatingTextField {
        return MoneyTextField()
    }
}
