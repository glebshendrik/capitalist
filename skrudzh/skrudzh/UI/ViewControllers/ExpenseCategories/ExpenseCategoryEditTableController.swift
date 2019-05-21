//
//  ExpenseCategoryEditTableController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 18/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import StaticDataTableViewController

protocol ExpenseCategoryEditTableControllerDelegate {
    var basketType: BasketType { get }
    var canChangeCurrency: Bool { get }
    func validationNeeded()
    func didSelectIcon(icon: Icon)
    func didSelectCurrency(currency: Currency)
    func didSelectIncomeSourceCurrency(currency: Currency)
}

class ExpenseCategoryEditTableController : StaticDataTableViewController, UITextFieldDelegate {
    @IBOutlet weak var expenseCategoryNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var nameBackground: UIView!
    @IBOutlet weak var nameIconContainer: UIView!
    
    @IBOutlet weak var currencyTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var changeCurrencyIndicator: UIImageView!
    
    @IBOutlet weak var incomeSourceCurrencyCell: UITableViewCell!
    @IBOutlet weak var incomeSourceCurrencyTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var changeIncomeSourceCurrencyIndicator: UIImageView!
    
    @IBOutlet weak var expenseCategoryMonthlyPlannedTextField: MoneyTextField!
    @IBOutlet weak var monthlyPlannedBackground: UIView!
    @IBOutlet weak var monthlyPlannedIconContainer: UIView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    private var incomeSourceCurrencyDelegate: IncomeSourceCurrencyDelegate?
    
    var delegate: ExpenseCategoryEditTableControllerDelegate? {
        didSet {
            incomeSourceCurrencyDelegate = IncomeSourceCurrencyDelegate(delegate: delegate)
        }
    }
    
    var iconCategory: IconCategory {
        guard let basketType = delegate?.basketType else { return .expenseCategoryJoy }
        switch basketType {
        case .joy:
            return .expenseCategoryJoy
        case .risk:
            return .expenseCategoryRisk
        case .safe:
            return .expenseCategorySafe
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update(textField: expenseCategoryNameTextField)
        update(textField: expenseCategoryMonthlyPlannedTextField)
        update(textField: currencyTextField)
        update(textField: incomeSourceCurrencyTextField)
        expenseCategoryNameTextField.titleFormatter = { $0 }
        expenseCategoryMonthlyPlannedTextField.titleFormatter = { $0 }
        currencyTextField.titleFormatter = { $0 }
        incomeSourceCurrencyTextField.titleFormatter = { $0 }
        delegate?.validationNeeded()
    }
    
    @IBAction func didChangeName(_ sender: SkyFloatingLabelTextField) {
        update(textField: sender)
        delegate?.validationNeeded()
    }
    
    @IBAction func didChangeAmount(_ sender: MoneyTextField) {
        update(textField: sender)
        delegate?.validationNeeded()
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
        case expenseCategoryNameTextField:
            return nameIconContainer
        case expenseCategoryMonthlyPlannedTextField:
            return monthlyPlannedIconContainer
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
        if segue.identifier == "ShowExpenseCategoryIcons",
            let iconsViewController = segue.destination as? IconsViewControllerInputProtocol {
            iconsViewController.set(iconCategory: iconCategory)
            iconsViewController.set(delegate: self)
        }
        if  segue.identifier == "showCurrenciesScreen",
            let destination = segue.destination as? CurrenciesViewControllerInputProtocol {
            
            destination.set(delegate: self)
        }
        if  segue.identifier == "showIncomeSourceCurrenciesScreen",
            let destination = segue.destination as? CurrenciesViewControllerInputProtocol,
            let incomeSourceCurrencyDelegate = incomeSourceCurrencyDelegate {
            
            destination.set(delegate: incomeSourceCurrencyDelegate)
        }
    }
        
    func setIncomeSourceCurrency(hidden: Bool) {
        cell(incomeSourceCurrencyCell, setHidden: hidden)
    }
}

class IncomeSourceCurrencyDelegate : CurrenciesViewControllerDelegate {
    let delegate: ExpenseCategoryEditTableControllerDelegate?
    
    init(delegate: ExpenseCategoryEditTableControllerDelegate?) {
        self.delegate = delegate
    }
    
    func didSelectCurrency(currency: Currency) {
        delegate?.didSelectIncomeSourceCurrency(currency: currency)
    }
}

extension ExpenseCategoryEditTableController : IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon) {
        delegate?.didSelectIcon(icon: icon)
    }
}

extension ExpenseCategoryEditTableController : CurrenciesViewControllerDelegate {
    func didSelectCurrency(currency: Currency) {
        delegate?.didSelectCurrency(currency: currency)
    }
}
