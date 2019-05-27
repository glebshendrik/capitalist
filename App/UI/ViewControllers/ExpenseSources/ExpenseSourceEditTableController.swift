//
//  ExpenseSourceEditTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

protocol ExpenseSourceEditTableControllerDelegate {
    var accountType: AccountType { get }
    var canChangeCurrency: Bool { get }
    var canChangeAmount: Bool { get }
    func validationNeeded()
    func didSelectIcon(icon: Icon)
    func didSwitch(accountType: AccountType)
    func didSelectCurrency(currency: Currency)
    func didTapRemoveButton()
}

class ExpenseSourceEditTableController : FloatingFieldsStaticTableViewController {
    @IBOutlet weak var generalExpenseSourceTabTitleLabel: UILabel!
    @IBOutlet weak var generalExpenseSourceTabSelectionIndicator: UIView!
    
    @IBOutlet weak var goalExpenseSourceTabTitleLabel: UILabel!
    @IBOutlet weak var goalExpenseSourceTabSelectionIndicator: UIView!
    
    @IBOutlet weak var debtExpenseSourceTabTitleLabel: UILabel!
    @IBOutlet weak var debtExpenseSourceTabSelectionIndicator: UIView!
    
    @IBOutlet weak var expenseSourceNameTextField: FloatingTextField!
    
    @IBOutlet weak var currencyTextField: FloatingTextField!
    @IBOutlet weak var changeCurrencyIndicator: UIImageView!
    
    @IBOutlet weak var expenseSourceAmountTextField: MoneyTextField!
    
    @IBOutlet weak var expenseSourceGoalAmountTextField: MoneyTextField!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var typeSwitchCell: UITableViewCell!
    @IBOutlet weak var goalAmountCell: UITableViewCell!
    @IBOutlet weak var removeCell: UITableViewCell!
    
    var delegate: ExpenseSourceEditTableControllerDelegate?
    
    var iconCategory: IconCategory {
        return accountType == .goal ? .expenseSourceGoal : .expenseSource
    }
    
    var accountType: AccountType {
        return delegate?.accountType ?? .usual
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        expenseSourceNameTextField.updateAppearance()
        currencyTextField.updateAppearance()
        expenseSourceAmountTextField.updateAppearance()
        expenseSourceGoalAmountTextField.updateAppearance()
        delegate?.validationNeeded()
    }
    
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
        
        reloadData(animated: animated)
    }
    
    func setTypeSwitch(hidden: Bool, animated: Bool = true, reload: Bool = true) {
        set(cells: typeSwitchCell, hidden: hidden)
        if reload { updateUI(animated: animated) }
    }
    
    func setGoalAmount(hidden: Bool, animated: Bool = true, reload: Bool = true) {
        set(cells: goalAmountCell, hidden: hidden)
        if reload { updateUI(animated: animated) }
    }
        
    @IBAction func didChangeName(_ sender: FloatingTextField) {
        sender.updateAppearance()
        delegate?.validationNeeded()
    }
    
    @IBAction func didChangeAmount(_ sender: MoneyTextField) {
        sender.updateAppearance()
        delegate?.validationNeeded()
    }
    
    @IBAction func didChangeGoalAmount(_ sender: MoneyTextField) {
        sender.updateAppearance()
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
