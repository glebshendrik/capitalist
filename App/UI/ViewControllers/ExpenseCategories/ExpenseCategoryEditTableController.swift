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

class ExpenseCategoryEditTableController : FormFieldsTableViewController {
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
        nameField.didChange { [weak self] text in
            self?.delegate?.didChange(name: text)
        }
        monthlyPlannedField.didChange { [weak self] text in
            self?.delegate?.didChange(monthlyPlanned: text)
        }
        currencyField.didTap { [weak self] in
            self?.delegate?.didTapCurrency()
        }
        incomeSourceCurrencyField.didTap { [weak self] in
            self?.delegate?.didTapIncomeSourceCurrency()
        }
    }
    
    @IBAction func didTapIcon(_ sender: Any) {
        delegate?.didTapIcon()
    }
    
    @IBAction func didTapSetReminder(_ sender: UIButton) {
        delegate?.didTapSetReminder()
    }
    
    @IBAction func didTapRemoveButton(_ sender: UIButton) {
        delegate?.didTapRemoveButton()
    }
}
