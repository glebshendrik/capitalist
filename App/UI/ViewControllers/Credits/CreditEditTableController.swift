//
//  CreditEditTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 29/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol CreditEditTableControllerDelegate {
    func didAppear()
    func didTapIcon()
    func didChange(name: String?)
    func didChange(amount: String?)
    func didChange(shouldRecordOnBalance: Bool)
    func didChange(returnAmount: String?)
    func didChange(alreadyPaid: String?)
    func didChange(monthlyPayment: String?)
    func didChange(period: Int?)
    func didTapCreditType()
    func didTapCurrency()
    func didTapExpenseSource()
    func didTapGotAt()
    func didTapSetReminder()
    func didTapRemoveButton()
}

class CreditEditTableController : FormFieldsTableViewController {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var iconBackgroundImageView: UIImageView!
    
    @IBOutlet weak var nameField: FormTextField!
    @IBOutlet weak var creditTypeField: FormTapField!
    @IBOutlet weak var currencyField: FormTapField!
    @IBOutlet weak var amountField: FormMoneyTextField!
    @IBOutlet weak var onBalanceSwitchField: FormSwitchValueField!
    @IBOutlet weak var expenseSourceField: FormTapField!
    @IBOutlet weak var returnAmountField: FormMoneyTextField!
    @IBOutlet weak var alreadyPaidField: FormMoneyTextField!
    @IBOutlet weak var monthlyPaymentField: FormMoneyTextField!
    @IBOutlet weak var gotAtField: FormTapField!
    @IBOutlet weak var periodField: FormSliderField!
    
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var reminderCell: UITableViewCell!
    
    @IBOutlet weak var onBalanceCell: UITableViewCell!
    @IBOutlet weak var expenseSourceCell: UITableViewCell!
    @IBOutlet weak var amountCell: UITableViewCell!
    @IBOutlet weak var periodCell: UITableViewCell!
    @IBOutlet weak var monthlyPaymentCell: UITableViewCell!
    @IBOutlet weak var removeCell: UITableViewCell!
    
    var delegate: CreditEditTableControllerDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.didAppear()
    }
    
    override func setupUI() {
        super.setupUI()
        setupNameField()
        setupCreditTypeField()
        setupCurrencyField()
        setupAmountField()
        setupOnBalanceSwitchField()
        setupExpenseSourceField()
        setupReturnAmountField()
        setupAlreadyPaidField()
        setupMonthlyPaymentField()
        setupGotAtField()
        setupPeriodField()
    }
    
    func setupNameField() {
        register(responder: nameField.textField)
        nameField.placeholder = NSLocalizedString("Название", comment: "Название")
        nameField.imageName = "type-icon"
        nameField.didChange { [weak self] text in
            self?.delegate?.didChange(name: text)
        }
    }
    
    func setupCreditTypeField() {
        creditTypeField.placeholder = NSLocalizedString("Тип кредита", comment: "Тип кредита")
        creditTypeField.imageName = "credit-type-icon"
        creditTypeField.didTap { [weak self] in
            self?.delegate?.didTapCreditType()
        }
    }
    
    func setupCurrencyField() {
        currencyField.placeholder = NSLocalizedString("Валюта", comment: "Валюта")
        currencyField.imageName = "currency-icon"
        currencyField.didTap { [weak self] in
            self?.delegate?.didTapCurrency()
        }
    }
    
    func setupAmountField() {
        register(responder: amountField.textField)
        amountField.placeholder = NSLocalizedString("Cумма кредита", comment: "Cумма кредита")
        amountField.imageName = "amount-icon"
        amountField.didChange { [weak self] text in
            self?.delegate?.didChange(amount: text)
        }
    }
    
    func setupOnBalanceSwitchField() {
        onBalanceSwitchField.placeholder = NSLocalizedString("Зачислить сумму на кошелек", comment: "Зачислить сумму на кошелек")
        onBalanceSwitchField.imageName = "included_in_balance_icon"
        onBalanceSwitchField.didSwitch { [weak self] shouldRecordOnBalance in
            self?.delegate?.didChange(shouldRecordOnBalance: shouldRecordOnBalance)
        }
    }
    
    func setupExpenseSourceField() {
        expenseSourceField.placeholder = NSLocalizedString("Кошелек", comment: "Кошелек")
        expenseSourceField.imageName = TransactionableType.expenseSource.defaultIconName
        expenseSourceField.didTap { [weak self] in
            self?.delegate?.didTapExpenseSource()
        }
    }
    
    func setupReturnAmountField() {
        register(responder: returnAmountField.textField)
        returnAmountField.placeholder = NSLocalizedString("Полная сумма выплаты", comment: "Полная сумма выплаты")
        returnAmountField.imageName = "amount-icon"
        returnAmountField.didChange { [weak self] text in
            self?.delegate?.didChange(returnAmount: text)
        }
    }
    
    func setupAlreadyPaidField() {
        register(responder: alreadyPaidField.textField)
        alreadyPaidField.placeholder = NSLocalizedString("Сколько уже оплатил", comment: "Сколько уже оплатил")
        alreadyPaidField.imageName = "credit-limit-icon"
        alreadyPaidField.didChange { [weak self] text in
            self?.delegate?.didChange(alreadyPaid: text)
        }
    }
    
    func setupMonthlyPaymentField() {
        register(responder: monthlyPaymentField.textField)
        monthlyPaymentField.placeholder = NSLocalizedString("Ежемесячная выплата", comment: "Ежемесячная выплата")
        monthlyPaymentField.imageName = "period-icon"
        monthlyPaymentField.didChange { [weak self] text in
            self?.delegate?.didChange(monthlyPayment: text)
        }
    }
    
    func setupGotAtField() {
        gotAtField.placeholder = NSLocalizedString("Дата получения кредита", comment: "Дата получения кредита")
        gotAtField.imageName = "calendar-icon"
        gotAtField.didTap { [weak self] in
            self?.delegate?.didTapGotAt()
        }
    }
    
    func setupPeriodField() {
        periodField.placeholder = NSLocalizedString("Срок", comment: "Срок")
        periodField.imageName = "calendar-icon"
        periodField.didChange { [weak self] value in
            self?.delegate?.didChange(period: Int(value))
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
