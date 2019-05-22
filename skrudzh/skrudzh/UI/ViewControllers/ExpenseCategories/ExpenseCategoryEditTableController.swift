//
//  ExpenseCategoryEditTableController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 18/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

protocol ExpenseCategoryEditTableControllerDelegate {
    var basketType: BasketType { get }
    var canChangeCurrency: Bool { get }
    func validationNeeded()
    func didSelectIcon(icon: Icon)
    func didSelectCurrency(currency: Currency)
    func didSelectIncomeSourceCurrency(currency: Currency)
    func didTapRemoveButton()
    func didTapSetReminder()
}

class ExpenseCategoryEditTableController : FloatingFieldsStaticTableViewController {
    @IBOutlet weak var expenseCategoryNameTextField: FloatingTextField!
    
    @IBOutlet weak var currencyTextField: FloatingTextField!
    @IBOutlet weak var changeCurrencyIndicator: UIImageView!
    
    @IBOutlet weak var incomeSourceCurrencyCell: UITableViewCell!
    @IBOutlet weak var incomeSourceCurrencyTextField: FloatingTextField!
    @IBOutlet weak var changeIncomeSourceCurrencyIndicator: UIImageView!
    
    @IBOutlet weak var expenseCategoryMonthlyPlannedTextField: MoneyTextField!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var removeCell: UITableViewCell!
    
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    
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
        expenseCategoryNameTextField.updateAppearance()
        expenseCategoryMonthlyPlannedTextField.updateAppearance()
        currencyTextField.updateAppearance()
        incomeSourceCurrencyTextField.updateAppearance()
        delegate?.validationNeeded()
        
    }
    
    @IBAction func didChangeName(_ sender: FloatingTextField) {
        sender.updateAppearance()
        delegate?.validationNeeded()
    }
    
    @IBAction func didChangeAmount(_ sender: MoneyTextField) {
        sender.updateAppearance()
        delegate?.validationNeeded()
    }
    
    @IBAction func didTapSetReminder(_ sender: UIButton) {
        delegate?.didTapSetReminder()
    }
    
    @IBAction func didTapRemoveButton(_ sender: UIButton) {
        delegate?.didTapRemoveButton()
    }
    
    func setRemoveButton(hidden: Bool) {
        set(cell: removeCell, hidden: hidden, animated: false, reload: true)
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
        set(cell: incomeSourceCurrencyCell, hidden: hidden, animated: false, reload: true)
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
