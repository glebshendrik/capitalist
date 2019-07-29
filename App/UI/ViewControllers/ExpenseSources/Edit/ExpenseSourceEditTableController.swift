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

class ExpenseSourceEditTableController : FloatingFieldsStaticTableViewController {
    @IBOutlet private weak var usualTabLabel: UILabel!
    @IBOutlet private weak var usualTabSelection: UIView!
    
    @IBOutlet private weak var goalTabLabel: UILabel!
    @IBOutlet private weak var goalTabSelection: UIView!
    
    @IBOutlet private weak var debtTabLabel: UILabel!
    @IBOutlet private weak var debtTabSelection: UIView!
    
    @IBOutlet weak var nameField: FormTextField!    
    @IBOutlet weak var currencyField: FloatingTextField!
    @IBOutlet weak var amountField: MoneyTextField!
    @IBOutlet weak var creditLimitField: MoneyTextField!
    @IBOutlet weak var goalAmountField: MoneyTextField!
    
    @IBOutlet weak var currencyArrow: UIImageView!

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.updateAppearance()
        nameField.addError(message: "Testing very long error so it should place two lines long error so it should place two lines")
        currencyField.updateAppearance()
        amountField.updateAppearance()
        creditLimitField.updateAppearance()
        goalAmountField.updateAppearance()
    }
    
    // TextFields didChange
    
    @IBAction func didChangeFieldText(_ sender: FloatingTextField) {
        sender.updateAppearance()
        let text = sender.text?.trimmed
        
        if sender == nameField {
            delegate?.didChange(name: text)
        }
        if sender == amountField {
            nameField.addError(message: "Testing very long error so it should place two lines long error so it should place two lines")
            delegate?.didChange(amount: text)
        }
        if sender == creditLimitField {
            nameField.addError(message: "Testing very long error so it should place two lines")
            delegate?.didChange(creditLimit: text)
        }
        if sender == goalAmountField {
            delegate?.didChange(goalAmount: text)
        }
    }
    
    // Buttons didTap
    
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
    
    @IBAction func didTapCurrency(_ sender: Any) {
        delegate?.didTapCurrency()
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
    
    // Cells visibility
    
//    func setTypeSwitch(hidden: Bool, animated: Bool = true, reload: Bool = true) {
//        set(cells: typeSwitchCell, hidden: hidden)
//        if reload { reloadData(animated: animated) }
//    }
//
//    func setAmount(hidden: Bool, animated: Bool = true, reload: Bool = true) {
//        set(cells: amountCell, hidden: hidden)
//        if reload { reloadData(animated: animated) }
//    }
//
//    func setCreditLimit(hidden: Bool, animated: Bool = true, reload: Bool = true) {
//        set(cells: creditLimitCell, hidden: hidden)
//        if reload { reloadData(animated: animated) }
//    }
//
//    func setGoalAmount(hidden: Bool, animated: Bool = true, reload: Bool = true) {
//        set(cells: goalAmountCell, hidden: hidden)
//        if reload { reloadData(animated: animated) }
//    }
//
//    func setRemoveButton(hidden: Bool) {
//        set(cell: removeCell, hidden: hidden, animated: false, reload: true)
//    }
//
//    func setBankButton(hidden: Bool, animated: Bool = true, reload: Bool = true) {
//        set(cell: bankCell, hidden: hidden, animated: animated, reload: reload)
//    }
    
    
}
