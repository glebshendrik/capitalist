//
//  IncomeSourceEditTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 17/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

protocol IncomeSourceEditTableControllerDelegate {
    func didTapIcon()
    func didChange(name: String?)
    func didTapCurrency()
    func didChange(monthlyPlanned: String?)
    func didTapSetReminder()
    func didTapRemoveButton()
}

class IncomeSourceEditTableController : FormFieldsTableViewController {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var iconBackgroundImageView: UIImageView!
    
    @IBOutlet weak var nameField: FormTextField!
    @IBOutlet weak var currencyField: FormTapField!
    @IBOutlet weak var monthlyPlannedField: FormMoneyTextField!
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var removeCell: UITableViewCell!
    @IBOutlet weak var reminderCell: UITableViewCell!
    
    var delegate: IncomeSourceEditTableControllerDelegate?
    
    override func setupUI() {
        super.setupUI()
        setupNameField()
        setupCurrencyField()
        setupMonthlyPlannedField()
    }
    
    private func setupNameField() {
        register(responder: nameField.textField)
        nameField.placeholder = "Название"
        nameField.imageName = "type-icon"
        nameField.didChange { [weak self] text in
            self?.delegate?.didChange(name: text)
        }
    }
    
    private func setupCurrencyField() {
        currencyField.placeholder = "Валюта"
        currencyField.imageName = "currency-icon"
        currencyField.didTap { [weak self] in
            self?.delegate?.didTapCurrency()
        }
    }
    
    func setupMonthlyPlannedField() {
        register(responder: monthlyPlannedField.textField)
        monthlyPlannedField.placeholder = "Планируемый доход в месяц"
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
