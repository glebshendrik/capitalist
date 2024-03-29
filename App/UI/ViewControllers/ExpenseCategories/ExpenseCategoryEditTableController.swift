//
//  ExpenseCategoryEditTableController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 18/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol ExpenseCategoryEditTableControllerDelegate : FormFieldsTableViewControllerDelegate {
    func didTapIcon()
    func didChange(name: String?)
    func didChange(monthlyPlanned: String?)
    func didTapCurrency()
    func didTapSetReminder()
    func didTapRemoveButton()
}

class ExpenseCategoryEditTableController : FormFieldsTableViewController {
    @IBOutlet weak var icon: IconView!
    
    @IBOutlet weak var nameField: FormTextField!
    @IBOutlet weak var currencyField: FormTapField!
    @IBOutlet weak var monthlyPlannedField: FormMoneyTextField!
    
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    
    @IBOutlet weak var removeCell: UITableViewCell!
    @IBOutlet weak var reminderCell: UITableViewCell!
    
    weak var delegate: ExpenseCategoryEditTableControllerDelegate?
    
    override var formFieldsTableViewControllerDelegate: FormFieldsTableViewControllerDelegate? {
        return delegate
    }
        
    override func setupUI() {
        super.setupUI()
        setupNameField()
        setupCurrencyField()
        setupMonthlyPlannedField()
    }
    
    func setupNameField() {
        register(responder: nameField.textField)
        nameField.placeholder = NSLocalizedString("Название", comment: "Название")
        nameField.imageName = "type-icon"
        nameField.didChange { [weak self] text in
            self?.delegate?.didChange(name: text)
        }
    }
    
    func setupCurrencyField() {
        currencyField.placeholder = NSLocalizedString("Валюта", comment: "Валюта")
        currencyField.imageName = "currency-icon"
        currencyField.didTap { [weak self] in
            self?.delegate?.didTapCurrency()
        }
    }
        
    func setupMonthlyPlannedField() {
        register(responder: monthlyPlannedField.textField)
        monthlyPlannedField.placeholder = NSLocalizedString("Планирую тратить в месяц", comment: "Планирую тратить в месяц")
        monthlyPlannedField.imageName = "planned-amount-icon"
        monthlyPlannedField.didChange { [weak self] text in
            self?.delegate?.didChange(monthlyPlanned: text)
        }
    }
    
    @IBAction func didTapIcon(_ sender: Any) {
        delegate?.didTapIcon()
    }
    
    @IBAction func didTapSetReminder(_ sender: UIButton) {
        delegate?.didTapSetReminder()
    }
    
    @IBAction func didTapRemoveButton(_ sender: UIButton) {
        delegate?.didTapRemoveButton()
    }
}
