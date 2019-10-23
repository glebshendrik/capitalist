//
//  ActiveEditTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol ActiveEditTableControllerDelegate {
    func didTapIcon()
    func didTapActiveType()
    func didChange(name: String?)
    func didTapCurrency()
    func didChange(cost: String?)
    func didChange(monthlyPayment: String?)
    func didChange(isIncomePlanned: Bool)
    func didTapActiveIncomeType()
    func didChange(monthlyPlannedIncome: String?)
    func didChange(annualPercent: String?)
    func didTapSetReminder()
    func didTapRemoveButton()
}

class ActiveEditTableController : FormFieldsTableViewController {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var iconBackgroundImageView: UIImageView!
    
    @IBOutlet weak var activeTypeField: FormTapField!
    @IBOutlet weak var nameField: FormTextField!
    @IBOutlet weak var currencyField: FormTapField!
    @IBOutlet weak var costField: FormMoneyTextField!
    @IBOutlet weak var monthlyPaymentField: FormMoneyTextField!
    @IBOutlet weak var plannedIncomeSwitchField: FormSwitchValueField!
    @IBOutlet weak var activeIncomeTypeField: FormTapField!
    @IBOutlet weak var monthlyPlannedIncomeField: FormMoneyTextField!
    @IBOutlet weak var annualPercentField: FormPercentTextField!
    
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var activeIncomeTypeCell: UITableViewCell!
    @IBOutlet weak var monthlyPlannedIncomeCell: UITableViewCell!
    @IBOutlet weak var annualPercentCell: UITableViewCell!
    @IBOutlet weak var removeCell: UITableViewCell!
    
    var delegate: ActiveEditTableControllerDelegate?
    
    override func setupUI() {
        super.setupUI()
        setupActiveTypeField()
        setupNameField()
        setupCurrencyField()
        setupCostField()
        setupMonthlyPaymentField()
        setupPlannedIncomeSwitchField()
        setupActiveIncomeTypeField()
        setupMonthlyPlannedIncomeField()
        setupAnnualPercentField()
    }
    
    func setupActiveTypeField() {
        activeTypeField.placeholder = "Тип актива"
        activeTypeField.imageName = "active-type-icon"
        activeTypeField.didTap { [weak self] in
            self?.delegate?.didTapActiveType()
        }
    }
    
    func setupNameField() {
        register(responder: nameField.textField)
        nameField.placeholder = "Название"
        nameField.imageName = "type-icon"
        nameField.didChange { [weak self] text in
            self?.delegate?.didChange(name: text)
        }
    }
    
    func setupCurrencyField() {
        currencyField.placeholder = "Валюта"
        currencyField.imageName = "currency-icon"
        currencyField.didTap { [weak self] in
            self?.delegate?.didTapCurrency()
        }
    }
    
    func setupCostField() {
        register(responder: costField.textField)
        costField.placeholder = "Стоимость актива"
        costField.imageName = "amount-icon"
        costField.didChange { [weak self] text in
            self?.delegate?.didChange(cost: text)
        }
    }
    
    func setupMonthlyPaymentField() {
        register(responder: monthlyPaymentField.textField)
        monthlyPaymentField.placeholder = "Планирую инвестировать в месяц"
        monthlyPaymentField.imageName = "planned-amount-icon"
        monthlyPaymentField.didChange { [weak self] text in
            self?.delegate?.didChange(monthlyPayment: text)
        }
    }
    
    func setupPlannedIncomeSwitchField() {
        plannedIncomeSwitchField.placeholder = "Актив приносит доход"
        plannedIncomeSwitchField.imageName = "included_in_balance_icon"
        plannedIncomeSwitchField.didSwitch { [weak self] isIncomePlanned in
            self?.delegate?.didChange(isIncomePlanned: isIncomePlanned)
        }
    }
    
    func setupActiveIncomeTypeField() {
        activeIncomeTypeField.placeholder = "Способ расчета дохода"
        activeIncomeTypeField.imageName = "active-type-icon"
        activeIncomeTypeField.didTap { [weak self] in
            self?.delegate?.didTapActiveIncomeType()
        }
    }
    
    func setupMonthlyPlannedIncomeField() {
        register(responder: monthlyPlannedIncomeField.textField)
        monthlyPlannedIncomeField.placeholder = "Планируемый доход в месяц"
        monthlyPlannedIncomeField.imageName = "planned-amount-icon"
        monthlyPlannedIncomeField.didChange { [weak self] text in
            self?.delegate?.didChange(monthlyPlannedIncome: text)
        }
    }
    
    func setupAnnualPercentField() {
        register(responder: annualPercentField.textField)
        annualPercentField.placeholder = "Ожидаемый годовой процент"
        annualPercentField.imageName = "planned-amount-icon"
        annualPercentField.didChange { [weak self] text in
            self?.delegate?.didChange(annualPercent: text)
        }
    }
    
    @IBAction func didTapIcon(_ sender: Any) {
        delegate?.didTapIcon()
    }
    
    @IBAction func didTapReminderButton(_ sender: Any) {
        delegate?.didTapSetReminder()
    }
    
    @IBAction func didTapRemoveButton(_ sender: UIButton) {
        delegate?.didTapRemoveButton()
    }
}
