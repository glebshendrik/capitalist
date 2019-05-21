//
//  FloatingFieldsStaticTableViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 21/05/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import StaticDataTableViewController

class FloatingFieldsStaticTableViewController : StaticDataTableViewController, UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let floatingLabelTextField = textField as? FloatingTextField {
            floatingLabelTextField.updateAppearance()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let floatingLabelTextField = textField as? FloatingTextField {
            floatingLabelTextField.updateAppearance()
        }
    }
}
