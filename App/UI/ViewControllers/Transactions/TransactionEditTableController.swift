//
//  TransactionEditTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

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
    func didChange(comment: String?)
    func didTapRemoveButton()
}

class TransactionEditTableController : FormFieldsTableViewController {
    
    // Fields
    @IBOutlet weak var sourceField: FormTapField!
    @IBOutlet weak var destinationField: FormTapField!
    @IBOutlet weak var amountField: FormMoneyTextField!
    @IBOutlet weak var exchangeField: FormExchangeField!
    @IBOutlet weak var inBalanceSwitchField: FormSwitchValueField!
    @IBOutlet weak var commentView: UITextView!
    
    // Cells
    @IBOutlet weak var debtCell: UITableViewCell!
    @IBOutlet weak var returnCell: UITableViewCell!
    @IBOutlet weak var sourceCell: UITableViewCell!
    @IBOutlet weak var destinationCell: UITableViewCell!
    @IBOutlet weak var amountCell: UITableViewCell!
    @IBOutlet weak var exchangeCell: UITableViewCell!
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
        exchangeField.didChangeAmount { [weak self] text in
            self?.delegate?.didChange(amount: text)
        }
        exchangeField.didChangeConvertedAmount { [weak self] text in
            self?.delegate?.didChange(convertedAmount: text)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.didAppear()
    }
    
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
}
