//
//  ActiveEditTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SDWebImageSVGCoder

protocol ActiveEditTableControllerDelegate : FormFieldsTableViewControllerDelegate {
    func didTapIcon()
    func didTapActiveType()
    func didChange(name: String?)
    func didTapCurrency()
    func didTapExpenseSource()
    func didChange(isMovingFundsFromWallet: Bool)
    func didChange(cost: String?)
    func didChange(alreadyPaid: String?)
    func didChange(goalAmount: String?)
    func didChange(monthlyPayment: String?)
    func didChange(isIncomePlanned: Bool)
    func didTapActiveIncomeType()
    func didChange(monthlyPlannedIncome: String?)
    func didChange(annualPercent: String?)
    func didTapSetReminder()
    func didTapRemoveButton()
}

class ActiveEditTableController : FormFieldsTableViewController {
    
    @IBOutlet weak var icon: IconView!
    @IBOutlet weak var iconPen: UIView!
        
    @IBOutlet weak var activeTypeField: FormTapField!
    @IBOutlet weak var nameField: FormTextField!
    @IBOutlet weak var currencyField: FormTapField!
    @IBOutlet weak var isMovingFundsFromWalletSwitchField: FormSwitchValueField!
    @IBOutlet weak var expenseSourceField: FormTapField!
    @IBOutlet weak var costField: FormMoneyTextField!
    @IBOutlet weak var goalAmountField: FormMoneyTextField!
    @IBOutlet weak var alreadyPaidField: FormMoneyTextField!    
    @IBOutlet weak var monthlyPaymentField: FormMoneyTextField!
    @IBOutlet weak var plannedIncomeSwitchField: FormSwitchValueField!
    @IBOutlet weak var activeIncomeTypeField: FormTapField!
    @IBOutlet weak var monthlyPlannedIncomeField: FormMoneyTextField!
    @IBOutlet weak var annualPercentField: FormPercentTextField!
    
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    
    @IBOutlet weak var bankButton: HighlightButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var reminderCell: UITableViewCell!
    
    @IBOutlet weak var isMovingFundsFromWalletCell: UITableViewCell!
    @IBOutlet weak var expenseSourceCell: UITableViewCell!
    @IBOutlet weak var activeIncomeTypeCell: UITableViewCell!
    @IBOutlet weak var alreadyPaidCell: UITableViewCell!
    @IBOutlet weak var goalAmountCell: UITableViewCell!
    @IBOutlet weak var monthlyPlannedIncomeCell: UITableViewCell!
    @IBOutlet weak var annualPercentCell: UITableViewCell!
    @IBOutlet weak var removeCell: UITableViewCell!
    @IBOutlet weak var bankCell: UITableViewCell!
    
    weak var delegate: ActiveEditTableControllerDelegate?
        
    override var formFieldsTableViewControllerDelegate: FormFieldsTableViewControllerDelegate? {
        return delegate
    }
        
    override func setupUI() {
        super.setupUI()
        setupActiveTypeField()
        setupNameField()
        setupCurrencyField()
        setupOnBalanceSwitchField()
        setupExpenseSourceField()
        setupCostField()
        setupAlreadyPaidField()
        setupGoalAmountField()
        setupMonthlyPaymentField()
        setupPlannedIncomeSwitchField()
        setupActiveIncomeTypeField()
        setupMonthlyPlannedIncomeField()
        setupAnnualPercentField()
    }
    
    func setupActiveTypeField() {
        activeTypeField.placeholder = NSLocalizedString("Тип актива", comment: "Тип актива")
        activeTypeField.imageName = "active-type-icon"
        activeTypeField.didTap { [weak self] in
            self?.delegate?.didTapActiveType()
        }
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
    
    func setupOnBalanceSwitchField() {
        isMovingFundsFromWalletSwitchField.placeholder = NSLocalizedString("Списать сумму с кошелька", comment: "")
        isMovingFundsFromWalletSwitchField.imageName = "included_in_balance_icon"
        isMovingFundsFromWalletSwitchField.didSwitch { [weak self] isMovingFundsFromWallet in
            self?.delegate?.didChange(isMovingFundsFromWallet: isMovingFundsFromWallet)
        }
    }
    
    func setupExpenseSourceField() {
        expenseSourceField.placeholder = NSLocalizedString("Кошелек", comment: "Кошелек")
        expenseSourceField.imageName = TransactionableType.expenseSource.defaultIconName
        expenseSourceField.didTap { [weak self] in
            self?.delegate?.didTapExpenseSource()
        }
    }
    
    func setupCostField() {
        register(responder: costField.textField)
        costField.placeholder = NSLocalizedString("Стоимость актива", comment: "Стоимость актива")
        costField.imageName = "amount-icon"
        costField.didChange { [weak self] text in
            self?.delegate?.didChange(cost: text)
        }
    }
    
    func setupAlreadyPaidField() {
        register(responder: alreadyPaidField.textField)
        alreadyPaidField.placeholder = NSLocalizedString("Потратил ранее", comment: "Потратил ранее")
        alreadyPaidField.imageName = "amount-icon"
        alreadyPaidField.didChange { [weak self] text in
            self?.delegate?.didChange(alreadyPaid: text)
        }
    }
    
    func setupGoalAmountField() {
        register(responder: goalAmountField.textField)
        goalAmountField.placeholder = NSLocalizedString("Хочу накопить", comment: "Хочу накопить")
        goalAmountField.imageName = "planned-amount-icon"
        goalAmountField.didChange { [weak self] text in
            self?.delegate?.didChange(goalAmount: text)
        }
    }
    
    func setupMonthlyPaymentField() {
        register(responder: monthlyPaymentField.textField)
        monthlyPaymentField.placeholder = NSLocalizedString("Планирую инвестировать в месяц", comment: "Планирую инвестировать в месяц")
        monthlyPaymentField.imageName = "planned-amount-icon"
        monthlyPaymentField.didChange { [weak self] text in
            self?.delegate?.didChange(monthlyPayment: text)
        }
    }
    
    func setupPlannedIncomeSwitchField() {
        plannedIncomeSwitchField.placeholder = NSLocalizedString("Актив приносит доход", comment: "Актив приносит доход")
        plannedIncomeSwitchField.imageName = "included_in_balance_icon"
        plannedIncomeSwitchField.didSwitch { [weak self] isIncomePlanned in
            self?.delegate?.didChange(isIncomePlanned: isIncomePlanned)
        }
    }
    
    func setupActiveIncomeTypeField() {
        activeIncomeTypeField.placeholder = NSLocalizedString("Способ расчета дохода", comment: "Способ расчета дохода")
        activeIncomeTypeField.imageName = "active-type-icon"
        activeIncomeTypeField.didTap { [weak self] in
            self?.delegate?.didTapActiveIncomeType()
        }
    }
    
    func setupMonthlyPlannedIncomeField() {
        register(responder: monthlyPlannedIncomeField.textField)
        monthlyPlannedIncomeField.placeholder = NSLocalizedString("Планируемый доход в месяц", comment: "Планируемый доход в месяц")
        monthlyPlannedIncomeField.imageName = "amount-icon"
        monthlyPlannedIncomeField.didChange { [weak self] text in
            self?.delegate?.didChange(monthlyPlannedIncome: text)
        }
    }
    
    func setupAnnualPercentField() {
        register(responder: annualPercentField.textField)
        annualPercentField.placeholder = NSLocalizedString("Ожидаемый годовой процент", comment: "Ожидаемый годовой процент")
        annualPercentField.imageName = "percent-icon"
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
    
    @IBAction func didTapBankButton(_ sender: Any) {
        
    }
}
