//
//  IncomeSourceEditTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 17/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

protocol IncomeSourceEditTableControllerDelegate {
    var canChangeCurrency: Bool { get }
    func validationNeeded()
    func didSelectCurrency(currency: Currency)
    func didTapSetReminder()
    func didTapRemoveButton()
}

class IncomeSourceEditTableController : FloatingFieldsStaticTableViewController {
    @IBOutlet weak var incomeSourceNameTextField: FloatingTextField!
    @IBOutlet weak var currencyTextField: FloatingTextField!
    @IBOutlet weak var changeCurrencyIndicator: UIImageView!
    @IBOutlet weak var reminderButton: UIButton!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var removeCell: UITableViewCell!
    
    var delegate: IncomeSourceEditTableControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        incomeSourceNameTextField.updateAppearance()
        currencyTextField.updateAppearance()
        delegate?.validationNeeded()
    }
    
    @IBAction func didChangeName(_ sender: FloatingTextField) {
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
        if  segue.identifier == "showCurrenciesScreen",
            let destination = segue.destination as? CurrenciesViewController {
            
            destination.set(delegate: self)
        }
    }
}

extension IncomeSourceEditTableController : CurrenciesViewControllerDelegate {
    func didSelectCurrency(currency: Currency) {
        delegate?.didSelectCurrency(currency: currency)
    }
}
