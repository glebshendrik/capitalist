//
//  TransactionEditTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import UIKit
import SwifterSwift

protocol TransactionEditTableControllerDelegate : FormFieldsTableViewControllerDelegate {
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
    func didTapPadButton(type: OperationType)
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
    
    lazy var amountKeyboardInputAccessoryView: UIView = {
        return createAmountKeyboardInputAccessoryView()
    }()
    
    lazy var amountSaveButton: KeyboardHighlightButton = {
        return createSaveButton()
    }()
    
    lazy var plusPadButtton: UIButton = {
        return createPadButton(type: .plus)
    }()
    
    lazy var minusPadButtton: UIButton = {
        return createPadButton(type: .minus)
    }()
    
    lazy var equalPadButtton: UIButton = {
        return createPadButton(type: .equal)
    }()
        
    override var formFieldsTableViewControllerDelegate: FormFieldsTableViewControllerDelegate? {
        return delegate
    }
        
    let didAppearOnce = Once()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppearOnce.run {
            delegate?.didAppear()
        }
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
    
    override func keyboardInputAccessoryViewFor(_ responder: UIResponder) -> UIView {
        switch responder {
        case amountField.textField, exchangeField.amountField, exchangeField.convertedAmountField:
            return amountKeyboardInputAccessoryView
        default:
            return super.keyboardInputAccessoryViewFor(responder)
        }
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
        isSellingAssetSwitchField.placeholder = NSLocalizedString("Полная продажа актива", comment: "")
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
    
    func createAmountKeyboardInputAccessoryView() -> UIView {
        let containerView = UIInputView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 115), inputViewStyle: .keyboard)
        let padsStackView = UIStackView(arrangedSubviews: [plusPadButtton, minusPadButtton, equalPadButtton], axis: .horizontal, spacing: 6, alignment: .fill, distribution: .fillEqually)
//        let saveButton = createSaveButton()
        containerView.addSubview(amountSaveButton)
        containerView.addSubview(padsStackView)
        amountSaveButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(48)
            make.top.equalTo(containerView).offset(10)
            make.left.equalTo(containerView).offset(24)
            make.right.equalTo(containerView).offset(-24)
            make.bottom.equalTo(padsStackView.snp_top).offset(-10)
        }
        padsStackView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(46)
            make.left.equalTo(containerView).offset(6)
            make.right.equalTo(containerView).offset(-6)
            make.bottom.equalTo(containerView).offset(-1)
        }
        return containerView
    }
    
    private func createPadButton(type: OperationType) -> KeyboardHighlightButton {
        let button = KeyboardHighlightButton()
        button.backgroundColorForHighlighted = UIColor(hexString: "#444444")
        button.backgroundColorForNormal = UIColor(red: 100 / 255.0, green: 104 / 255.0, blue: 105 / 255.0, alpha: 1.0)
        button.backgroundColor = UIColor(red: 100 / 255.0, green: 104 / 255.0, blue: 105 / 255.0, alpha: 1.0)
        button.cornerRadius = 5
        button.setImage(UIImage(named: type.padIconName), for: .normal)
        button.addTarget(self, action: #selector(didTapPadButton(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func didTapPadButton(_ sender: UIButton) {
        guard let padType = padTypeBy(sender) else { return }        
        delegate?.didTapPadButton(type: padType)
    }
    
    private func padTypeBy(_ button: UIButton) -> OperationType? {
        switch button {
        case plusPadButtton:
            return .plus
        case minusPadButtton:
            return .minus
        case equalPadButtton:
            return .equal
        default:
            return nil
        }
    }
}

enum OperationType : String {
    case plus, minus, equal
    
    var padIconName: String {
        return "\(self.rawValue)-key-icon"
    }
}
