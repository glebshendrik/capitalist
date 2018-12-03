//
//  RegistrationViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 03/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

class RegistrationViewController : UITableViewController {
    
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    
    var viewModel: RegistrationViewModel!
    
    @IBAction func didTapRegisterButton(_ sender: Any) {
        viewModel.registerWith(firstname: firstnameTextField.text,
                               email: emailTextField.text,
                               password: passwordTextField.text,
                               passwordConfirmation: passwordConfirmationTextField.text)
            
            .ensure {
                
            }
            .done {
                                
            }.catch { e in
                
            }
        
    }
}
