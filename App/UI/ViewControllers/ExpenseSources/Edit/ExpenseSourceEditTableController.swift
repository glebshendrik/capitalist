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
    func didTap(accountType: AccountType)
    func didTapIcon()
    func didTapCurrency()
    func didChange(name: String?)
    func didChange(amount: String?)
    func didChange(creditLimit: String?)
    func didChange(goalAmount: String?)
    func didTapBankButton()
    func didTapRemoveButton()
}

class ExpenseSourceEditTableController : FormFieldsTableViewController {
    @IBOutlet private weak var usualTabLabel: UILabel!
    @IBOutlet private weak var usualTabSelection: UIView!
    
    @IBOutlet private weak var goalTabLabel: UILabel!
    @IBOutlet private weak var goalTabSelection: UIView!
    
    @IBOutlet private weak var debtTabLabel: UILabel!
    @IBOutlet private weak var debtTabSelection: UIView!
    
    @IBOutlet weak var nameField: FormTextField!    
    @IBOutlet weak var currencyField: FormTapField!
    @IBOutlet weak var amountField: FormMoneyTextField!
    @IBOutlet weak var creditLimitField: FormMoneyTextField!
    @IBOutlet weak var goalAmountField: FormMoneyTextField!

    @IBOutlet weak var accountTypeLabel: UILabel!

    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var bankIconView: SVGKFastImageView!
    @IBOutlet weak var iconPen: UIImageView!
    
    @IBOutlet weak var bankButton: UIButton!
    
    @IBOutlet weak var typeSwitchCell: UITableViewCell!
    @IBOutlet weak var amountCell: UITableViewCell!
    @IBOutlet weak var creditLimitCell: UITableViewCell!
    @IBOutlet weak var goalAmountCell: UITableViewCell!
    @IBOutlet weak var removeCell: UITableViewCell!
    @IBOutlet weak var bankCell: UITableViewCell!
    
    var delegate: ExpenseSourceEditTableControllerDelegate?
    
    override var lastResponder: UIView? {
        if !isHidden(cell: goalAmountCell) {
            return goalAmountField.textField
        }
        
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
        setupGoalAmountField()
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
    
    private func setupGoalAmountField() {
        register(responder: goalAmountField.textField)
        goalAmountField.placeholder = "Хочу накопить"
        goalAmountField.imageName = "planned-amount-icon"
        goalAmountField.didChange { [weak self] text in
            self?.delegate?.didChange(goalAmount: text)
        }
    }
    
    @IBAction func didTapUsualTab(_ sender: Any) {
        delegate?.didTap(accountType: .usual)
        updateTabsAppearence(accountType: .usual)
    }
    
    @IBAction func didTapGoalTab(_ sender: Any) {
        delegate?.didTap(accountType: .goal)
        updateTabsAppearence(accountType: .goal)
    }
    
    @IBAction func didTapDebtTab(_ sender: Any) {
        delegate?.didTap(accountType: .debt)
        updateTabsAppearence(accountType: .debt)
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
    
    private func updateTabsAppearence(accountType: AccountType) {
        
        func tabsAppearances(for accountType: AccountType) -> (usual: TabAppearance, goal: TabAppearance, debt: TabAppearance) {
            let selectedColor = UIColor.by(.textFFFFFF)
            let unselectedColor = UIColor.by(.text9EAACC)
            
            let selectedTabAppearance: TabAppearance = (textColor: selectedColor, isHidden: false)
            let unselectedTabAppearance: TabAppearance = (textColor: unselectedColor, isHidden: true)
            
            switch accountType {
            case .usual:
                return (usual: selectedTabAppearance,
                        goal: unselectedTabAppearance,
                        debt: unselectedTabAppearance)
            case .goal:
                return (usual: unselectedTabAppearance,
                        goal: selectedTabAppearance,
                        debt: unselectedTabAppearance)
            case .debt:
                return (usual: unselectedTabAppearance,
                        goal: unselectedTabAppearance,
                        debt: selectedTabAppearance)
                
            }
        }
        
        let tabsAppearance = tabsAppearances(for: accountType)
        
        usualTabLabel.textColor = tabsAppearance.usual.textColor
        goalTabLabel.textColor = tabsAppearance.goal.textColor
        debtTabLabel.textColor = tabsAppearance.debt.textColor
        
        usualTabSelection.isHidden = tabsAppearance.usual.isHidden
        goalTabSelection.isHidden = tabsAppearance.goal.isHidden
        debtTabSelection.isHidden = tabsAppearance.debt.isHidden
    }
}
