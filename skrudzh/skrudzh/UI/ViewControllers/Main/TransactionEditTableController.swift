//
//  TransactionEditTableController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 26/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import StaticDataTableViewController

protocol TransactionEditTableControllerDelegate {
    func validationNeeded()
    func needsFirstResponder()
    func didSaveAtYesterday()
    func didChangeAmount()
    func didChangeConvertedAmount()
    func didTapComment()
    func didTapCalendar()
    func didTapStartable()
    func didTapCompletable()
}

class TransactionEditTableController : StaticDataTableViewController, UITextFieldDelegate {
    @IBOutlet weak var startableNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var startableBackground: UIView!
    @IBOutlet weak var startableIconContainer: UIView!
    @IBOutlet weak var startableIconImageView: UIImageView!
    @IBOutlet weak var startableBalanceLabel: UILabel!
    @IBOutlet weak var startableCell: UITableViewCell!
    
    @IBOutlet weak var completableNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var completableBackground: UIView!
    @IBOutlet weak var completableIconContainer: UIView!
    @IBOutlet weak var completableIconImageView: UIImageView!
    @IBOutlet weak var completableBalanceLabel: UILabel!
    @IBOutlet weak var completableCell: UITableViewCell!
    
    @IBOutlet weak var amountCell: UITableViewCell!
    @IBOutlet weak var amountTextField: MoneyTextField!
    @IBOutlet weak var amountBackground: UIView!
    @IBOutlet weak var amountIconContainer: UIView!
    @IBOutlet weak var amountCurrencyLabel: UILabel!
    
    @IBOutlet weak var exchangeAmountsCell: UITableViewCell!
    @IBOutlet weak var exchangeAmountsBackground: UIView!
    @IBOutlet weak var exchangeAmountsIconContainer: UIView!
    @IBOutlet weak var exchangeStartableAmountTextField: MoneyTextField!
    @IBOutlet weak var exchangeStartableAmountCurrencyLabel: UILabel!
    @IBOutlet weak var exchangeCompletableAmountTextField: MoneyTextField!
    @IBOutlet weak var exchangeCompletableAmountCurrencyLabel: UILabel!
    @IBOutlet weak var exchangeCompletableAmountBackground: UIView!
    @IBOutlet weak var exchangeStartableAmountBackground: UIView!
    @IBOutlet weak var exchangesWhiteLine: UIView!
    
    @IBOutlet weak var yesterdayButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    var delegate: TransactionEditTableControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update(textField: startableNameTextField)
        update(textField: completableNameTextField)
        update(textField: amountTextField)
        update(textField: exchangeStartableAmountTextField)
        update(textField: exchangeCompletableAmountTextField)
        startableNameTextField.titleFormatter = { $0 }
        completableNameTextField.titleFormatter = { $0 }
        amountTextField.titleFormatter = { $0 }
        exchangeStartableAmountTextField.titleFormatter = { $0 }
        exchangeCompletableAmountTextField.titleFormatter = { $0 }
        delegate?.validationNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.needsFirstResponder()
    }
    
    @IBAction func didChangeAmount(_ sender: MoneyTextField) {
        update(textField: sender)
        delegate?.validationNeeded()
    }
    
    @IBAction func didChangeStartableAmount(_ sender: MoneyTextField) {
        update(textField: sender)
        delegate?.didChangeAmount()
        delegate?.validationNeeded()
    }
    
    @IBAction func didChangeConvertedAmount(_ sender: MoneyTextField) {
        update(textField: sender)
        delegate?.didChangeConvertedAmount()
        delegate?.validationNeeded()
    }
    
    @IBAction func didTapYesterdayButton(_ sender: Any) {
        delegate?.didSaveAtYesterday()
    }
    
    @IBAction func didTapCalendarButton(_ sender: Any) {
        view.endEditing(true)
        delegate?.didTapCalendar()
    }
    
    @IBAction func didTapCommentButton(_ sender: Any) {
        view.endEditing(true)
        delegate?.didTapComment()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
            update(textField: floatingLabelTextField)
            exchangeStartableAmountBackground.isHidden = floatingLabelTextField != exchangeStartableAmountTextField
            exchangeCompletableAmountBackground.isHidden = floatingLabelTextField != exchangeCompletableAmountTextField
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
            update(textField: floatingLabelTextField)
            exchangeStartableAmountBackground.isHidden = true
            exchangeCompletableAmountBackground.isHidden = true
        }
    }
    
    private func update(textField: SkyFloatingLabelTextField) {
        
        let focused = textField.isFirstResponder
        let present = textField.text != nil && !textField.text!.trimmed.isEmpty
        
        let textFieldOptions = self.textFieldOptions(focused: focused, present: present)
        
        fieldBackground(by: textField)?.backgroundColor = textFieldOptions.background
        textField.textColor = textFieldOptions.text
        textField.placeholderFont = textFieldOptions.placeholderFont
        textField.placeholderColor = textFieldOptions.placeholder
        textField.titleColor = textFieldOptions.placeholder
        textField.selectedTitleColor = textFieldOptions.placeholder

        if exchangeCompletableAmountTextField.isFirstResponder || exchangeStartableAmountTextField.isFirstResponder {
            exchangeStartableAmountTextField.textColor = .white
            exchangeStartableAmountTextField.placeholderColor = .white
            exchangeStartableAmountTextField.titleColor = .white
            exchangeStartableAmountTextField.selectedTitleColor = .white
            
            exchangeCompletableAmountTextField.textColor = .white
            exchangeCompletableAmountTextField.placeholderColor = .white
            exchangeCompletableAmountTextField.titleColor = .clear
            exchangeCompletableAmountTextField.selectedTitleColor = .clear
            exchangesWhiteLine.isHidden = false
        } else {
            let dark = UIColor(red: 0.52, green: 0.57, blue: 0.63, alpha: 1)
            exchangeStartableAmountTextField.textColor = dark
            exchangeStartableAmountTextField.placeholderColor = dark
            exchangeStartableAmountTextField.titleColor = dark
            exchangeStartableAmountTextField.selectedTitleColor = dark
            
            exchangeCompletableAmountTextField.textColor = dark
            exchangeCompletableAmountTextField.placeholderColor = dark
            exchangeCompletableAmountTextField.titleColor = .clear
            exchangeCompletableAmountTextField.selectedTitleColor = .clear
            exchangesWhiteLine.isHidden = true
        }
        
        iconContainer(by: textField)?.backgroundColor = textFieldOptions.iconBackground
    }
    
    private func iconContainer(by textField: UITextField) -> UIView? {
        switch textField {
        case startableNameTextField:
            return startableIconContainer
        case completableNameTextField:
            return completableIconContainer
        case amountTextField:
            return amountIconContainer
        case exchangeStartableAmountTextField:
            return exchangeAmountsIconContainer
        case exchangeCompletableAmountTextField:
            return exchangeAmountsIconContainer
        default:
            return nil
        }
    }
    
    private func fieldBackground(by textField: UITextField) -> UIView? {
        switch textField {
        case startableNameTextField:
            return startableBackground
        case completableNameTextField:
            return completableBackground
        case amountTextField:
            return amountBackground
        case exchangeStartableAmountTextField:
            return exchangeAmountsBackground
        case exchangeCompletableAmountTextField:
            return exchangeAmountsBackground
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
    
    func update(needsExchange: Bool) {
        setAmountCell(hidden: needsExchange)
        setExchangeAmountsCell(hidden: !needsExchange)
    }
    
    func setAmountCell(hidden: Bool, animated: Bool = true, reload: Bool = true) {
        cell(amountCell, setHidden: hidden)
        if reload {
            updateTable(animated: animated)
        }
    }
    
    func setExchangeAmountsCell(hidden: Bool, animated: Bool = true, reload: Bool = true) {
        cell(exchangeAmountsCell, setHidden: hidden)
        if reload {
            updateTable(animated: animated)
        }
    }
    
    func updateTable(animated: Bool = true) {
        reloadData(animated: animated, insert: .top, reload: .fade, delete: .bottom)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        tableView.deselectRow(at: indexPath, animated: false)
        if cell == startableCell {
            delegate?.didTapStartable()
        }
        
        if cell == completableCell {
            delegate?.didTapCompletable()
        }
    }
}
