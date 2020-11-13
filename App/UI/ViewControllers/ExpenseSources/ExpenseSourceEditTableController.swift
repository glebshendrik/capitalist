//
//  ExpenseSourceEditTableController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 26/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import SDWebImageSVGCoder

protocol ExpenseSourceEditTableControllerDelegate : FormFieldsTableViewControllerDelegate {
    func didTapIcon()
    func didTapCurrency()
    func didTapCardType()
    func didChange(name: String?)
    func didChange(amount: String?)
    func didChange(creditLimit: String?)
    func didTapRemoveButton()
    func didTapBankButton()
}

class ExpenseSourceEditTableController : FormFieldsTableViewController {
    @IBOutlet weak var nameField: FormTextField!
    @IBOutlet weak var currencyField: FormTapField!
    @IBOutlet weak var amountField: FormMoneyTextField!
    @IBOutlet weak var creditLimitField: FormMoneyTextField!
    @IBOutlet weak var cardTypeField: FormImageValueField!
    
    @IBOutlet weak var icon: IconView!
    @IBOutlet weak var iconPen: UIView!
    
    @IBOutlet weak var bankButton: UIButton!
    
    @IBOutlet weak var amountCell: UITableViewCell!
    @IBOutlet weak var creditLimitCell: UITableViewCell!
    @IBOutlet weak var removeCell: UITableViewCell!
    @IBOutlet weak var bankCell: UITableViewCell!
    
    weak var delegate: ExpenseSourceEditTableControllerDelegate?
    
    override var formFieldsTableViewControllerDelegate: FormFieldsTableViewControllerDelegate? {
        return delegate
    }
    
    override var lastResponder: UIView? {
        if !isHidden(cell: creditLimitCell) {
            return creditLimitField.textField
        }
        
        if !isHidden(cell: amountCell) {
            return amountField.textField
        }
        
        return nameField.textField
    }
        
    override func setupUI() {
        super.setupUI()
        setupNameField()
        setupCardTypeField()
        setupCurrencyField()
        setupAmountField()
        setupCreditLimitField()
    }
    
    private func setupNameField() {
        register(responder: nameField.textField)
        nameField.placeholder = NSLocalizedString("Название", comment: "Название")
        nameField.imageName = "type-icon"
        nameField.didChange { [weak self] text in
            self?.delegate?.didChange(name: text)
        }
    }
    
    private func setupCardTypeField() {
        cardTypeField.placeholder = NSLocalizedString("Тип карты", comment: "")
        cardTypeField.imageName = "credit-type-icon"
        cardTypeField.didTap { [weak self] in
            self?.delegate?.didTapCardType()
        }
    }
    
    private func setupCurrencyField() {
        currencyField.placeholder = NSLocalizedString("Валюта", comment: "Валюта")
        currencyField.imageName = "currency-icon"
        currencyField.didTap { [weak self] in
            self?.delegate?.didTapCurrency()
        }
    }
    
    private func setupAmountField() {
        register(responder: amountField.textField)
        amountField.placeholder = NSLocalizedString("Баланс", comment: "Баланс")
        amountField.imageName = "amount-icon"
        amountField.didChange { [weak self] text in
            self?.delegate?.didChange(amount: text)
        }
    }
    
    private func setupCreditLimitField() {
        register(responder: creditLimitField.textField)
        creditLimitField.placeholder = NSLocalizedString("Кредитный лимит", comment: "Кредитный лимит")
        creditLimitField.imageName = "credit-limit-icon"
        creditLimitField.didChange { [weak self] text in
            self?.delegate?.didChange(creditLimit: text)
        }
    }
        
    @IBAction func didTapIcon(_ sender: Any) {
        delegate?.didTapIcon()
    }
    
    @IBAction func didTapBankButton(_ sender: Any) {
        delegate?.didTapBankButton()
    }
    
    @IBAction func didTapRemoveButton(_ sender: UIButton) {
        delegate?.didTapRemoveButton()
    }
}
