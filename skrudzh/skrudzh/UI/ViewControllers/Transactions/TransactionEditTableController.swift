//
//  TransactionEditTableController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 26/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import StaticTableViewController

protocol TransactionEditTableControllerDelegate {
    func validationNeeded()
    func needsFirstResponder()
    func didSaveAtYesterday()
    func didChangeAmount()
    func didChangeConvertedAmount()
    func didTapComment()
    func didTapCalendar()
    func didTapWhom()
    func didTapBorrowedTill()
    func didTapReturn()
    func didChange(includedInBalance: Bool)
    func didTapStartable()
    func didTapCompletable()
    func didTapRemoveButton()
}

class TransactionEditTableController : FloatingFieldsStaticTableViewController {
    @IBOutlet weak var startableNameTextField: FloatingTextField!
    @IBOutlet weak var startableIconImageView: UIImageView!
    @IBOutlet weak var startableBalanceLabel: UILabel!
    @IBOutlet weak var startableCell: UITableViewCell!
    
    @IBOutlet weak var completableNameTextField: FloatingTextField!
    @IBOutlet weak var completableIconImageView: UIImageView!
    @IBOutlet weak var completableBalanceLabel: UILabel!
    @IBOutlet weak var completableCell: UITableViewCell!
    
    @IBOutlet weak var amountCell: UITableViewCell!
    @IBOutlet weak var amountTextField: MoneyTextField!
    @IBOutlet weak var amountCurrencyLabel: UILabel!
    
    @IBOutlet weak var exchangeAmountsCell: UITableViewCell!
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
    
    @IBOutlet weak var debtCell: UITableViewCell!
    @IBOutlet weak var whomButton: UIButton!
    @IBOutlet weak var borrowedTillButton: UIButton!
    
    @IBOutlet weak var returnCell: UITableViewCell!
    @IBOutlet weak var returnButton: UIButton!
    
    @IBOutlet weak var inBalanceCell: UITableViewCell!
    @IBOutlet weak var inBalanceSwitch: UISwitch!
    
    @IBOutlet weak var removeCell: UITableViewCell!
    @IBOutlet weak var removeButton: UIButton!
    
    var delegate: TransactionEditTableControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update(textField: startableNameTextField)
        update(textField: completableNameTextField)
        update(textField: amountTextField)
        update(textField: exchangeStartableAmountTextField)
        update(textField: exchangeCompletableAmountTextField)
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
    
    @IBAction func didTapWhomButton(_ sender: Any) {
        view.endEditing(true)
        delegate?.didTapWhom()
    }
    
    @IBAction func didTapBorrowedTillButton(_ sender: Any) {
        view.endEditing(true)
        delegate?.didTapBorrowedTill()
    }
    
    @IBAction func didTapReturnButton(_ sender: Any) {
        view.endEditing(true)
        delegate?.didTapReturn()
    }
    
    @IBAction func didSwitchInBalance(_ sender: Any) {
        view.endEditing(true)
        delegate?.didChange(includedInBalance: inBalanceSwitch.isOn)
    }
    
    @IBAction func didTapRemoveButton(_ sender: UIButton) {
        delegate?.didTapRemoveButton()
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        if let floatingLabelTextField = textField as? FloatingTextField {
            update(textField: floatingLabelTextField)
            exchangeStartableAmountBackground.isHidden = floatingLabelTextField != exchangeStartableAmountTextField
            exchangeCompletableAmountBackground.isHidden = floatingLabelTextField != exchangeCompletableAmountTextField
        }
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        if let floatingLabelTextField = textField as? FloatingTextField {
            update(textField: floatingLabelTextField)
            exchangeStartableAmountBackground.isHidden = true
            exchangeCompletableAmountBackground.isHidden = true
        }
    }
    
    private func update(textField: FloatingTextField) {        
        textField.updateAppearance()
        updateAmountFields()
    }

    func update(needsExchange: Bool) {
        setAmountCell(hidden: needsExchange)
        setExchangeAmountsCell(hidden: !needsExchange)
    }
    
    func setAmountCell(hidden: Bool, animated: Bool = false, reload: Bool = true) {
        set(cell: amountCell, hidden: hidden, animated: animated, reload: reload)
    }
    
    func setExchangeAmountsCell(hidden: Bool, animated: Bool = false, reload: Bool = true) {
        set(cell: exchangeAmountsCell, hidden: hidden, animated: animated, reload: reload)
    }
    
    func setDebtCell(hidden: Bool, animated: Bool = false, reload: Bool = true) {
        set(cell: debtCell, hidden: hidden, animated: animated, reload: reload)
    }
    
    func setReturnCell(hidden: Bool, animated: Bool = false, reload: Bool = true) {
        set(cell: returnCell, hidden: hidden, animated: animated, reload: reload)
    }
    
    func setInBalanceCell(hidden: Bool, animated: Bool = false, reload: Bool = true) {
        set(cell: inBalanceCell, hidden: hidden, animated: animated, reload: reload)
    }
    
    func setRemoveButton(hidden: Bool) {
        set(cell: removeCell, hidden: hidden, animated: false, reload: true)
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

extension TransactionEditTableController {
    typealias FieldAppearance = (text: UIColor, placeholder: UIColor, title: UIColor, selectedTitle: UIColor)
    
    private func amountFieldsOptions(isFirstResponders: Bool) -> (startableFieldAppearance: FieldAppearance, completableFieldAppearance: FieldAppearance, whiteLineHidden: Bool) {
        
        let dark = UIColor(red: 0.52, green: 0.57, blue: 0.63, alpha: 1)
        
        return isFirstResponders
            ? (startableFieldAppearance: (text: .white,
                                          placeholder: .white,
                                          title: .white,
                                          selectedTitle: .white),
               completableFieldAppearance: (text: .white,
                                            placeholder: .white,
                                            title: .clear,
                                            selectedTitle: .clear),
               whiteLineHidden: false)
            : (startableFieldAppearance: (text: dark,
                                          placeholder: dark,
                                          title: dark,
                                          selectedTitle: dark),
               completableFieldAppearance: (text: dark,
                                            placeholder: dark,
                                            title: .clear,
                                            selectedTitle: .clear),
               whiteLineHidden: true)
    }
    
    private func updateAmountFields() {
        let isFirstResponders = exchangeCompletableAmountTextField.isFirstResponder || exchangeStartableAmountTextField.isFirstResponder
        
        let options = amountFieldsOptions(isFirstResponders: isFirstResponders)
        
        exchangeStartableAmountTextField.textColor = options.startableFieldAppearance.text
        exchangeStartableAmountTextField.placeholderColor = options.startableFieldAppearance.placeholder
        exchangeStartableAmountTextField.titleColor = options.startableFieldAppearance.title
        exchangeStartableAmountTextField.selectedTitleColor = options.startableFieldAppearance.selectedTitle
        
        exchangeCompletableAmountTextField.textColor = options.completableFieldAppearance.text
        exchangeCompletableAmountTextField.placeholderColor = options.completableFieldAppearance.placeholder
        exchangeCompletableAmountTextField.titleColor = options.completableFieldAppearance.title
        exchangeCompletableAmountTextField.selectedTitleColor = options.startableFieldAppearance.selectedTitle
        exchangesWhiteLine.isHidden = options.whiteLineHidden
    }
}
