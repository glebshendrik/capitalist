//
//  ExpenseCategoryEditTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 18/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol ExpenseCategoryEditTableControllerDelegate {
    func didTapIcon()
    func didChange(name: String?)
    func didChange(monthlyPlanned: String?)
    func didTapCurrency()
    func didTapIncomeSourceCurrency()    
    func didTapSetReminder()
    func didTapRemoveButton()
}

class ExpenseCategoryEditTableController : FloatingFieldsStaticTableViewController {
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var nameField: FormTextField!
    @IBOutlet weak var currencyField: FormTapField!
    @IBOutlet weak var incomeSourceCurrencyField: FormTapField!
    @IBOutlet weak var monthlyPlannedField: FormMoneyTextField!
    
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    
    @IBOutlet weak var incomeSourceCurrencyCell: UITableViewCell!
    @IBOutlet weak var removeCell: UITableViewCell!
    
    var delegate: ExpenseCategoryEditTableControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.textField.addTarget(self, action: #selector(didChangeName(_:)), for: UIControl.Event.editingChanged)
        monthlyPlannedField.textField.addTarget(self, action: #selector(didChangeMonthlyPlanned(_:)), for: UIControl.Event.editingChanged)
        currencyField.tapButton.addTarget(self, action: #selector(didTapCurrency(_:)), for: UIControl.Event.touchUpInside)
        incomeSourceCurrencyField.tapButton.addTarget(self, action: #selector(didTapIncomeSourceCurrency(_:)), for: UIControl.Event.touchUpInside)
    }
    
    @objc func didChangeName(_ sender: FloatingTextField) {
        delegate?.didChange(name: sender.text?.trimmed)
    }
    
    @objc func didChangeMonthlyPlanned(_ sender: FloatingTextField) {
        delegate?.didChange(monthlyPlanned: sender.text?.trimmed)
    }
    
    @objc func didTapCurrency(_ sender: Any) {
        delegate?.didTapCurrency()
    }
    
    @objc func didTapIncomeSourceCurrency(_ sender: Any) {
        delegate?.didTapIncomeSourceCurrency()
    }
        
    @IBAction func didTapSetReminder(_ sender: UIButton) {
        delegate?.didTapSetReminder()
    }
    
    @IBAction func didTapRemoveButton(_ sender: UIButton) {
        delegate?.didTapRemoveButton()
    }
}
