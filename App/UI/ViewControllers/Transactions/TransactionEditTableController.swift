//
//  TransactionEditTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import StaticTableViewController

protocol TransactionEditTableControllerDelegate {
    func didAppear()
    func didTapSaveAtYesterday()
    func didTapCalendar()
    func didTapWhom()
    func didTapBorrowedTill()
    func didTapReturn()
    func didTapSource()
    func didTapDestination()
    func didChange(amount: String?)
    func didChange(convertedAmount: String?)
    func didChange(includedInBalance: Bool)
    func didTapRemoveButton()
}

class TransactionEditTableController : FormFieldsTableViewController {
    
    // Fields
    @IBOutlet weak var sourceField: FormTapField!
    @IBOutlet weak var destinationField: FormTapField!
    @IBOutlet weak var amountField: FormMoneyTextField!
    // Exchange field
    @IBOutlet weak var sourceAmountTextField: MoneyTextField!
    @IBOutlet weak var sourceAmountCurrencyLabel: UILabel!
    @IBOutlet weak var sourceAmountBackground: UIView!
    @IBOutlet weak var convertedAmountTextField: MoneyTextField!
    @IBOutlet weak var convertedAmountCurrencyLabel: UILabel!
    @IBOutlet weak var convertedAmountBackground: UIView!
    @IBOutlet weak var amountsWhiteLine: UIView!
    // Exchange field end
    @IBOutlet weak var inBalanceSwitchField: FormSwitchValueField!
    
    // Cells
    @IBOutlet weak var debtCell: UITableViewCell!
    @IBOutlet weak var returnCell: UITableViewCell!
    @IBOutlet weak var sourceCell: UITableViewCell!
    @IBOutlet weak var destinationCell: UITableViewCell!
    @IBOutlet weak var amountCell: UITableViewCell!
    @IBOutlet weak var amountsCell: UITableViewCell!
    @IBOutlet weak var inBalanceCell: UITableViewCell!
    @IBOutlet weak var removeCell: UITableViewCell!
    
    // Buttons
    @IBOutlet weak var yesterdayButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var whomButton: UIButton!
    @IBOutlet weak var borrowedTillButton: UIButton!
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    var delegate: TransactionEditTableControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountField.didChange { [weak self] text in
            self?.delegate?.didChange(amount: text)
        }
        sourceField.didTap { [weak self] in
            self?.delegate?.didTapSource()
        }
        destinationField.didTap { [weak self] in
            self?.delegate?.didTapDestination()
        }
        inBalanceSwitchField.didSwitch { [weak self] includedInBalance in
            self?.delegate?.didChange(includedInBalance: includedInBalance)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.didAppear()
    }
    
//    @IBAction func didChangeSourceAmount(_ sender: MoneyTextField) {
//        update(textField: sender)
//        delegate?.didChangeAmount()
//        delegate?.validationNeeded()
//    }
//
//    @IBAction func didChangeConvertedAmount(_ sender: MoneyTextField) {
//        update(textField: sender)
//        delegate?.didChangeConvertedAmount()
//        delegate?.validationNeeded()
//    }
    
    @IBAction func didTapYesterdayButton(_ sender: Any) {
        delegate?.didTapSaveAtYesterday()
    }
    
    @IBAction func didTapCalendarButton(_ sender: Any) {
        delegate?.didTapCalendar()
    }
    
    @IBAction func didTapWhomButton(_ sender: Any) {
        delegate?.didTapWhom()
    }
    
    @IBAction func didTapBorrowedTillButton(_ sender: Any) {
        delegate?.didTapBorrowedTill()
    }
    
    @IBAction func didTapReturnButton(_ sender: Any) {
        delegate?.didTapReturn()
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
