//
//  BorrowEditTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol BorrowEditTableControllerDelegate : FormFieldsTableViewControllerDelegate {
    func didAppear()
    func didTapIcon()
    func didChange(name: String?)
    func didChange(amount: String?)
    func didChange(shouldRecordOnBalance: Bool)
    func didChange(comment: String?)
    func didTapCurrency()
    func didTapBorrowedAt()
    func didTapPayday()
    func didTapExpenseSource()
    func didTapReturn()
    func didTapRemoveButton()
}

class BorrowEditTableController : FormFieldsTableViewController {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var iconBackgroundImageView: UIImageView!
    
    @IBOutlet weak var nameField: FormTextField!
    @IBOutlet weak var currencyField: FormTapField!
    @IBOutlet weak var amountField: FormMoneyTextField!
    @IBOutlet weak var borrowedAtField: FormTapField!
    @IBOutlet weak var paydayField: FormTapField!
    @IBOutlet weak var onBalanceSwitchField: FormSwitchValueField!
    @IBOutlet weak var expenseSourceField: FormTapField!
    @IBOutlet weak var commentView: UITextView!
    
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var onBalanceCell: UITableViewCell!
    @IBOutlet weak var expenseSourceCell: UITableViewCell!
    @IBOutlet weak var returnCell: UITableViewCell!
    @IBOutlet weak var removeCell: UITableViewCell!
    
    var delegate: BorrowEditTableControllerDelegate?
    
    override var formFieldsTableViewControllerDelegate: FormFieldsTableViewControllerDelegate? {
        return delegate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.didAppear()
    }
    
    override func setupUI() {
        super.setupUI()
        setupNameField()
        setupCurrencyField()
        setupAmountField()
        setupBorrowedAtField()
        setupPaydayField()
        setupOnBalanceSwitchField()
        setupExpenseSourceField()
        setupCommentView()
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
    
    func setupAmountField() {
        register(responder: amountField.textField)
        amountField.placeholder = NSLocalizedString("Сумма", comment: "Сумма")
        amountField.imageName = "amount-icon"
        amountField.didChange { [weak self] text in
            self?.delegate?.didChange(amount: text)
        }
    }
    
    func setupOnBalanceSwitchField() {
        onBalanceSwitchField.placeholder = NSLocalizedString("Списать сумму с кошелька", comment: "Списать сумму с кошелька")
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
    
    func setupBorrowedAtField() {
        borrowedAtField.placeholder = NSLocalizedString("Дата займа", comment: "Дата займа")
        borrowedAtField.imageName = "calendar-icon"
        borrowedAtField.didTap { [weak self] in
            self?.delegate?.didTapBorrowedAt()
        }
    }
    
    func setupPaydayField() {
        paydayField.placeholder = NSLocalizedString("Дата возврата", comment: "Дата возврата")
        paydayField.imageName = "calendar-icon"
        paydayField.didTap { [weak self] in
            self?.delegate?.didTapPayday()
        }
    }
    
    func setupCommentView() {
        register(responder: commentView)
        commentView.delegate = self
    }
    
    @IBAction func didTapIcon(_ sender: Any) {
        delegate?.didTapIcon()
    }
    
    @IBAction func didTapReturnButton(_ sender: Any) {
        delegate?.didTapReturn()
    }
    
    @IBAction func didTapRemoveButton(_ sender: UIButton) {
        delegate?.didTapRemoveButton()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.didChange(comment: textView.text?.trimmed)
    }
}
