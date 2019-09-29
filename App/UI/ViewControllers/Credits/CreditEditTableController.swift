//
//  CreditEditTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 29/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol CreditEditTableControllerDelegate {
    func didTapIcon()
    func didChange(name: String?)
    func didChange(amount: String?)
    func didChange(alreadyPaid: String?)
    func didChange(monthlyPayment: String?)
    func didChange(period: Int?)
    func didTapCreditType()
    func didTapCurrency()
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
    @IBOutlet weak var alreadyPaidField: FormMoneyTextField!
    @IBOutlet weak var monthlyPaymentField: FormMoneyTextField!
    @IBOutlet weak var gotAtField: FormTapField!
    @IBOutlet weak var periodField: FormSliderField!
    
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var periodCell: UITableViewCell!
    @IBOutlet weak var monthlyPaymentCell: UITableViewCell!
    @IBOutlet weak var removeCell: UITableViewCell!
    
    var delegate: CreditEditTableControllerDelegate?
    
    override func setupUI() {
        super.setupUI()
        setupNameField()
        setupCreditTypeField()
        setupCurrencyField()
        setupAmountField()
        setupAlreadyPaidField()
        setupMonthlyPaymentField()
        setupGotAtField()
        setupPeriodField()
    }
    
    func setupNameField() {
        register(responder: nameField.textField)
        nameField.placeholder = "Название"
        nameField.imageName = "type-icon"
        nameField.didChange { [weak self] text in
            self?.delegate?.didChange(name: text)
        }
    }
    
    func setupCreditTypeField() {
        creditTypeField.placeholder = "Тип кредита"
        creditTypeField.imageName = "credit-type-icon"
        creditTypeField.didTap { [weak self] in
            self?.delegate?.didTapCreditType()
        }
    }
    
    func setupCurrencyField() {
        currencyField.placeholder = "Валюта"
        currencyField.imageName = "currency-icon"
        currencyField.didTap { [weak self] in
            self?.delegate?.didTapCurrency()
        }
    }
    
    func setupAmountField() {
        register(responder: amountField.textField)
        amountField.placeholder = "Полная сумма выплаты"
        amountField.imageName = "amount-icon"
        amountField.didChange { [weak self] text in
            self?.delegate?.didChange(amount: text)
        }
    }
    
    func setupAlreadyPaidField() {
        register(responder: alreadyPaidField.textField)
        alreadyPaidField.placeholder = "Сколько уже оплатил"
        alreadyPaidField.imageName = "credit-limit-icon"
        alreadyPaidField.didChange { [weak self] text in
            self?.delegate?.didChange(alreadyPaid: text)
        }
    }
    
    func setupMonthlyPaymentField() {
        register(responder: monthlyPaymentField.textField)
        monthlyPaymentField.placeholder = "Ежемесячная выплата"
        monthlyPaymentField.imageName = "period-icon"
        monthlyPaymentField.didChange { [weak self] text in
            self?.delegate?.didChange(monthlyPayment: text)
        }
    }
    
    func setupGotAtField() {
        gotAtField.placeholder = "Дата получения кредита"
        gotAtField.imageName = "calendar-icon"
        gotAtField.didTap { [weak self] in
            self?.delegate?.didTapGotAt()
        }
    }
    
    func setupPeriodField() {
        periodField.placeholder = "Срок"
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
