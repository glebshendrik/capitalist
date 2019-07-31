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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.textField.addTarget(self, action: #selector(didChangeName(_:)), for: UIControl.Event.editingChanged)
        currencyField.tapButton.addTarget(self, action: #selector(didTapCurrency(_:)), for: UIControl.Event.touchUpInside)
        amountField.textField.addTarget(self, action: #selector(didChangeAmount(_:)), for: UIControl.Event.editingChanged)
        creditLimitField.textField.addTarget(self, action: #selector(didChangeCreditLimit(_:)), for: UIControl.Event.editingChanged)
        goalAmountField.textField.addTarget(self, action: #selector(didChangeGoalAmount(_:)), for: UIControl.Event.editingChanged)
    }
    
    // TextFields didChange
    
    @objc func didChangeName(_ sender: FloatingTextField) {
        delegate?.didChange(name: sender.text?.trimmed)
    }
    
    @objc func didChangeAmount(_ sender: FloatingTextField) {
        delegate?.didChange(amount: sender.text?.trimmed)
    }
    
    @objc func didChangeCreditLimit(_ sender: FloatingTextField) {
        delegate?.didChange(creditLimit: sender.text?.trimmed)
    }
    
    @objc func didChangeGoalAmount(_ sender: FloatingTextField) {
        delegate?.didChange(goalAmount: sender.text?.trimmed)
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
    
    @objc func didTapCurrency(_ sender: Any) {
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
}
