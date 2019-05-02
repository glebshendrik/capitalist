//
//  ExpenseSourceEditTableController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 26/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import StaticDataTableViewController

protocol ExpenseSourceEditTableControllerDelegate {
    var accountType: AccountType { get }
    var canChangeCurrency: Bool { get }
    var canChangeAmount: Bool { get }
    func validationNeeded()
    func didSelectIcon(icon: Icon)
    func didSwitch(accountType: AccountType)
    func didSelectCurrency(currency: Currency)
}

class ExpenseSourceEditTableController : StaticDataTableViewController, UITextFieldDelegate {
    @IBOutlet weak var generalExpenseSourceTabTitleLabel: UILabel!
    @IBOutlet weak var generalExpenseSourceTabSelectionIndicator: UIView!
    
    @IBOutlet weak var goalExpenseSourceTabTitleLabel: UILabel!
    @IBOutlet weak var goalExpenseSourceTabSelectionIndicator: UIView!
    
    @IBOutlet weak var debtExpenseSourceTabTitleLabel: UILabel!
    @IBOutlet weak var debtExpenseSourceTabSelectionIndicator: UIView!
    
    @IBOutlet weak var expenseSourceNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var nameBackground: UIView!
    @IBOutlet weak var nameIconContainer: UIView!
    
    @IBOutlet weak var currencyTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var changeCurrencyIndicator: UIImageView!
    
    @IBOutlet weak var expenseSourceAmountTextField: MoneyTextField!
    @IBOutlet weak var amountBackground: UIView!
    @IBOutlet weak var amountIconContainer: UIView!
    
    @IBOutlet weak var expenseSourceGoalAmountTextField: MoneyTextField!
    @IBOutlet weak var goalAmountBackground: UIView!
    @IBOutlet weak var goalAmountIconContainer: UIView!
        
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var typeSwitchCell: UITableViewCell!
    @IBOutlet weak var goalAmountCell: UITableViewCell!
    
    var delegate: ExpenseSourceEditTableControllerDelegate?
    
    var iconCategory: IconCategory {
        return accountType == .goal ? .expenseSourceGoal : .expenseSource
    }
    
    var accountType: AccountType {
        return delegate?.accountType ?? .usual
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update(textField: expenseSourceNameTextField)
        update(textField: expenseSourceAmountTextField)
        update(textField: expenseSourceGoalAmountTextField)
        update(textField: currencyTextField)
        expenseSourceNameTextField.titleFormatter = { $0 }
        expenseSourceAmountTextField.titleFormatter = { $0 }
        expenseSourceGoalAmountTextField.titleFormatter = { $0 }
        currencyTextField.titleFormatter = { $0 }
        delegate?.validationNeeded()
    }
    
    typealias TabAppearance = (textColor: UIColor, isHidden: Bool)
    
    func updateUI(animated: Bool = true) {
        
        func tabsAppearances(for accountType: AccountType) -> (usual: TabAppearance, goal: TabAppearance, debt: TabAppearance) {
            let selectedColor = UIColor(red: 0.42, green: 0.58, blue: 0.98, alpha: 1)
            let unselectedColor = UIColor(red: 0.52, green: 0.57, blue: 0.63, alpha: 1)
            
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
        
        generalExpenseSourceTabTitleLabel.textColor = tabsAppearance.usual.textColor
        goalExpenseSourceTabTitleLabel.textColor = tabsAppearance.goal.textColor
        debtExpenseSourceTabTitleLabel.textColor = tabsAppearance.debt.textColor
        
        generalExpenseSourceTabSelectionIndicator.isHidden = tabsAppearance.usual.isHidden
        goalExpenseSourceTabSelectionIndicator.isHidden = tabsAppearance.goal.isHidden
        debtExpenseSourceTabSelectionIndicator.isHidden = tabsAppearance.debt.isHidden
        
        reloadData(animated: animated, insert: .top, reload: .fade, delete: .bottom)
    }
    
    func setTypeSwitch(hidden: Bool, animated: Bool = true, reload: Bool = false) {
        cell(typeSwitchCell, setHidden: hidden)
        if reload { updateUI(animated: animated) }
    }
    
    func setGoalAmount(hidden: Bool, animated: Bool = true, reload: Bool = false) {
        cell(goalAmountCell, setHidden: hidden)
        if reload { updateUI(animated: animated) }
    }
        
    @IBAction func didChangeName(_ sender: SkyFloatingLabelTextField) {
        update(textField: sender)
        delegate?.validationNeeded()
    }
    
    @IBAction func didChangeAmount(_ sender: MoneyTextField) {
        update(textField: sender)
        delegate?.validationNeeded()
    }
    
    @IBAction func didChangeGoalAmount(_ sender: MoneyTextField) {
        update(textField: sender)
        delegate?.validationNeeded()
    }
    
    @IBAction func didTapGeneralExpenseSource(_ sender: Any) {
        delegate?.didSwitch(accountType: .usual)
        
    }
    
    @IBAction func didTapGoalExpenseSource(_ sender: Any) {
        delegate?.didSwitch(accountType: .goal)
    }
    
    @IBAction func didTapDebtExpenseSource(_ sender: Any) {
        delegate?.didSwitch(accountType: .debt)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
            update(textField: floatingLabelTextField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
            update(textField: floatingLabelTextField)
        }
    }
    
    private func update(textField: SkyFloatingLabelTextField) {
        
        let focused = textField.isFirstResponder
        let present = textField.text != nil && !textField.text!.trimmed.isEmpty
        
        let textFieldOptions = self.textFieldOptions(focused: focused, present: present)
        
        textField.superview?.backgroundColor = textFieldOptions.background
        textField.textColor = textFieldOptions.text
        textField.placeholderFont = textFieldOptions.placeholderFont
        textField.placeholderColor = textFieldOptions.placeholder
        textField.titleColor = textFieldOptions.placeholder
        textField.selectedTitleColor = textFieldOptions.placeholder
        iconContainer(by: textField)?.backgroundColor = textFieldOptions.iconBackground
    }
    
    private func iconContainer(by textField: UITextField) -> UIView? {
        switch textField {
        case expenseSourceNameTextField:
            return nameIconContainer
        case expenseSourceAmountTextField:
            return amountIconContainer
        case expenseSourceGoalAmountTextField:
            return goalAmountIconContainer
        default:
            return nil
        }
    }
    
    private func textFieldOptions(focused: Bool, present: Bool) -> (background: UIColor, text: UIColor, placeholder: UIColor, placeholderFont: UIFont?, iconBackground: UIColor) {
        
        let activeBackgroundColor = UIColor(red: 0.42, green: 0.58, blue: 0.98, alpha: 1)
        let inactiveBackgroundColor = UIColor(red: 0.96, green: 0.97, blue: 1, alpha: 1)
        
        let darkPlaceholderColor = UIColor(red: 0.26, green: 0.33, blue: 0.52, alpha: 1)
        let lightPlaceholderColor = UIColor.white
        
        let inavtiveTextColor = UIColor(red: 0.52, green: 0.57, blue: 0.63, alpha: 1)
        let activeTextColor = UIColor.white
        
        let bigPlaceholderFont = UIFont(name: "Rubik-Regular", size: 16)
        let smallPlaceholderFont = UIFont(name: "Rubik-Regular", size: 10)
        
        let activeIconBackground = UIColor.white
        let inactiveIconBackground = UIColor(red: 0.9, green: 0.91, blue: 0.96, alpha: 1)
        
        switch (focused, present) {
        case (true, true):
            return (activeBackgroundColor, activeTextColor, darkPlaceholderColor, smallPlaceholderFont, activeIconBackground)
        case (true, false):
            return (activeBackgroundColor, activeTextColor, lightPlaceholderColor, bigPlaceholderFont, activeIconBackground)
        case (false, true):
            return (inactiveBackgroundColor, inavtiveTextColor, inavtiveTextColor, smallPlaceholderFont, inactiveIconBackground)
        case (false, false):
            return (inactiveBackgroundColor, inavtiveTextColor, inavtiveTextColor, bigPlaceholderFont, inactiveIconBackground)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if  identifier == "showCurrenciesScreen",
            let delegate = delegate {
            return delegate.canChangeCurrency
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowExpenseSourceIcons",
            let iconsViewController = segue.destination as? IconsViewControllerInputProtocol {
            iconsViewController.set(iconCategory: iconCategory)
            iconsViewController.set(delegate: self)
        }
        if  segue.identifier == "showCurrenciesScreen",
            let destination = segue.destination as? CurrenciesViewControllerInputProtocol {
            
            destination.set(delegate: self)
        }
    }
}

extension ExpenseSourceEditTableController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        delegate?.didSelectIcon(icon: icon)
    }
}

extension ExpenseSourceEditTableController : CurrenciesViewControllerDelegate {
    func didSelectCurrency(currency: Currency) {
        delegate?.didSelectCurrency(currency: currency)
    }
}
