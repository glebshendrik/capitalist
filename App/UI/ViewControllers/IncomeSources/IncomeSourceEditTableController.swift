//
//  IncomeSourceEditTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 17/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

protocol IncomeSourceEditTableControllerDelegate {
    func didChange(name: String?)
    func didTapCurrency()
    func didTapSetReminder()
    func didTapRemoveButton()
}

class IncomeSourceEditTableController : FloatingFieldsStaticTableViewController {
    @IBOutlet weak var nameField: FormTextField!
    @IBOutlet weak var currencyField: FormTapField!
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var removeCell: UITableViewCell!
    
    var delegate: IncomeSourceEditTableControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.textField.addTarget(self, action: #selector(didChangeName(_:)), for: UIControl.Event.editingChanged)
        currencyField.tapButton.addTarget(self, action: #selector(didTapCurrency(_:)), for: UIControl.Event.touchUpInside)
    }
    
    @objc func didChangeName(_ sender: FloatingTextField) {
        delegate?.didChange(name: sender.text?.trimmed)
    }
    
    @objc func didTapCurrency(_ sender: Any) {
        delegate?.didTapCurrency()
    }
    
    @IBAction func didTapSetReminder(_ sender: UIButton) {
        delegate?.didTapSetReminder()
    }
    
    @IBAction func didTapRemoveButton(_ sender: UIButton) {
        delegate?.didTapRemoveButton()
    }
}
