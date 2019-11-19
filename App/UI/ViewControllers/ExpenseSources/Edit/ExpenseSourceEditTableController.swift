//
//  ExpenseSourceEditTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import SDWebImageSVGCoder

protocol ExpenseSourceEditTableControllerDelegate {
    func didTapIcon()
    func didTapCurrency()
    func didChange(name: String?)
    func didChange(amount: String?)
    func didChange(creditLimit: String?)
    func didTapBankButton()
    func didTapRemoveButton()
}

class ExpenseSourceEditTableController : FormFieldsTableViewController {
    @IBOutlet weak var nameField: FormTextField!
    @IBOutlet weak var currencyField: FormTapField!
    @IBOutlet weak var amountField: FormMoneyTextField!
    @IBOutlet weak var creditLimitField: FormMoneyTextField!

    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var bankIconView: SVGKFastImageView!
    @IBOutlet weak var iconPen: UIImageView!
    
    @IBOutlet weak var bankButton: UIButton!
    
    @IBOutlet weak var amountCell: UITableViewCell!
    @IBOutlet weak var creditLimitCell: UITableViewCell!
    @IBOutlet weak var removeCell: UITableViewCell!
    @IBOutlet weak var bankCell: UITableViewCell!
    
    var delegate: ExpenseSourceEditTableControllerDelegate?
    
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
        setupCurrencyField()
        setupAmountField()
        setupCreditLimitField()
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
    
    private func setupAmountField() {
        register(responder: amountField.textField)
        amountField.placeholder = "Баланс"
        amountField.imageName = "amount-icon"
        amountField.didChange { [weak self] text in
            self?.delegate?.didChange(amount: text)
        }
    }
    
    private func setupCreditLimitField() {
        register(responder: creditLimitField.textField)
        creditLimitField.placeholder = "Кредитный лимит"
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
