//
//  FormPercentTextField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 23/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class FormPercentTextField : FormTextField {
    var percentTextField: PercentTextField = PercentTextField()
        
    override func createTextField() -> FloatingTextField {
        return percentTextField
    }
}
