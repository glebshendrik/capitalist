//
//  ForgotPasswordTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol ForgotPasswordTableControllerDelegate : FormFieldsTableViewControllerDelegate {
    func didChange(email: String?)
}

class ForgotPasswordTableController : SaveAccessoryFormFieldsTableViewController {
    @IBOutlet weak var emailField: FormTextField!
    @IBOutlet weak var sendCodeCell: UITableViewCell!
    @IBOutlet weak var sendCodeButton: HighlightButton!
    
    var delegate: ForgotPasswordTableControllerDelegate?
    
    override var formFieldsTableViewControllerDelegate: FormFieldsTableViewControllerDelegate? {
        return delegate
    }
    
    override var saveButtonTitle: String { return NSLocalizedString("Отправить код", comment: "Отправить код") }
    override var saveButtonInForm: HighlightButton? {
        return sendCodeButton
    }
    
    override func setupUI() {
        super.setupUI()
        setupEmailField()
    }
    
    private func setupEmailField() {
        register(responder: emailField.textField)
        setupAsEmail(emailField)
        emailField.placeholder = NSLocalizedString("Email", comment: "Email")
        emailField.imageName = "email-icon"
        emailField.didChange { [weak self] text in
            self?.delegate?.didChange(email: text)
        }
    }
        
    @IBAction func didTapSendCodeButton(_ sender: Any) {
        delegate?.didTapSave()
    }
}
