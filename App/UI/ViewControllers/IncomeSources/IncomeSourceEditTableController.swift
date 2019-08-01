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
        nameField.didChange { [weak self] text in
            self?.delegate?.didChange(name: text)
        }
        currencyField.didTap { [weak self] in
            self?.delegate?.didTapCurrency()
        }
    }
        
    @IBAction func didTapSetReminder(_ sender: UIButton) {
        delegate?.didTapSetReminder()
    }
    
    @IBAction func didTapRemoveButton(_ sender: UIButton) {
        delegate?.didTapRemoveButton()
    }
}
