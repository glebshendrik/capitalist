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
    func didTapSource()
    func didTapDestination()
    func didChange(amount: String?)
    func didChange(convertedAmount: String?)
    func didChange(isBuyingAsset: Bool)
    func didChange(isSellingAsset: Bool)
    func didChange(comment: String?)
    func didTapRemoveButton()
}

class TransactionEditTableController : FormFieldsTableViewController {
    
    // Fields
    @IBOutlet weak var sourceField: FormTapField!
    @IBOutlet weak var destinationField: FormTapField!
    @IBOutlet weak var amountField: FormMoneyTextField!
    @IBOutlet weak var exchangeField: FormExchangeField!
    @IBOutlet weak var isBuyingAssetSwitchField: FormSwitchValueField!
    @IBOutlet weak var isSellingAssetSwitchField: FormSwitchValueField!
    @IBOutlet weak var commentView: UITextView!
    
    // Cells
    @IBOutlet weak var sourceCell: UITableViewCell!
    @IBOutlet weak var destinationCell: UITableViewCell!
    @IBOutlet weak var amountCell: UITableViewCell!
    @IBOutlet weak var exchangeCell: UITableViewCell!
    @IBOutlet weak var isBuyingAssetCell: UITableViewCell!
    @IBOutlet weak var isSellingAssetCell: UITableViewCell!
    @IBOutlet weak var removeCell: UITableViewCell!
    
    // Buttons
    @IBOutlet weak var yesterdayButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    var delegate: TransactionEditTableControllerDelegate?
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.didAppear()
    }
    
    override func setupUI() {
        super.setupUI()
        setupAmountField()
        setupSourceField()
        setupDestinationField()
        setupExchangeField()
        setupIsBuyingAssetSwitchField()
        setupIsSellingAssetSwitchField()
        setupCommentView()
    }
    
    private func setupSourceField() {
        sourceField.didTap { [weak self] in
            self?.delegate?.didTapSource()
        }
    }
    
    private func setupDestinationField() {
        destinationField.didTap { [weak self] in
            self?.delegate?.didTapDestination()
        }
    }
        
    private func setupAmountField() {
        register(responder: amountField.textField)
        amountField.placeholder = NSLocalizedString("Сумма", comment: "Сумма")
        amountField.imageName = "amount-icon"
        amountField.didChange { [weak self] text in
            self?.delegate?.didChange(amount: text)
        }
    }
    
    private func setupExchangeField() {
        register(responder: exchangeField.amountField)
        register(responder: exchangeField.convertedAmountField)
        exchangeField.amountPlaceholder = NSLocalizedString("Сумма", comment: "Сумма")
        exchangeField.convertedAmountPlaceholder = NSLocalizedString("Сумма", comment: "Сумма")
        exchangeField.imageName = "amount-icon"
        exchangeField.didChangeAmount { [weak self] text in
            self?.delegate?.didChange(amount: text)
        }
        exchangeField.didChangeConvertedAmount { [weak self] text in
            self?.delegate?.didChange(convertedAmount: text)
        }
    }
    
    private func setupIsBuyingAssetSwitchField() {
        isBuyingAssetSwitchField.placeholder = NSLocalizedString("Покупка актива", comment: "Покупка актива")
        isBuyingAssetSwitchField.imageName = "included_in_balance_icon"
        isBuyingAssetSwitchField.didSwitch { [weak self] isBuyingAsset in
            self?.delegate?.didChange(isBuyingAsset: isBuyingAsset)
        }
    }
    
    private func setupIsSellingAssetSwitchField() {
        isSellingAssetSwitchField.placeholder = NSLocalizedString("Продажа актива", comment: "Продажа актива")
        isSellingAssetSwitchField.imageName = "included_in_balance_icon"
        isSellingAssetSwitchField.didSwitch { [weak self] isSellingAsset in
            self?.delegate?.didChange(isSellingAsset: isSellingAsset)
        }
    }
    
    private func setupCommentView() {
        register(responder: commentView)
        commentView.delegate = self
    }
    
    @IBAction func didTapYesterdayButton(_ sender: Any) {
        delegate?.didTapSaveAtYesterday()
    }
    
    @IBAction func didTapCalendarButton(_ sender: Any) {
        delegate?.didTapCalendar()
    }    
    
    @IBAction func didTapRemoveButton(_ sender: UIButton) {
        delegate?.didTapRemoveButton()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.didChange(comment: textView.text?.trimmed)
    }
}
