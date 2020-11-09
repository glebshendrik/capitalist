//
//  BankWarningInfoTableViewCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 16.06.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

protocol BankWarningInfoTableViewCellDelegate : EntityInfoTableViewCellDelegate {
    func didTapBankWarningInfoButton(field: BankWarningInfoField?)
}

class BankWarningInfoTableViewCell : EntityInfoTableViewCell, InteractiveFieldViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var connectButton: HighlightButton!
    @IBOutlet weak var warningIconImageView: UIImageView!
    @IBOutlet weak var syncActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stackView: UIStackView!
    var interactiveFieldViews: [InteractiveFieldView] = []    
    
    var bankWarningDelegate: BankWarningInfoTableViewCellDelegate? {
        return delegate as? BankWarningInfoTableViewCellDelegate
    }
    
    var bankWarningField: BankWarningInfoField? {
        return field as? BankWarningInfoField
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        syncActivityIndicator.startAnimating()
    }
    
    override func updateUI() {
        guard let bankWarningField = bankWarningField else { return }
        
        titleLabel.text = bankWarningField.title
        messageLabel.text = bankWarningField.message
        connectButton.setTitle(bankWarningField.buttonText, for: .normal)
        
        warningIconImageView.isHidden = bankWarningField.isWarningIconHidden
        syncActivityIndicator.isHidden = bankWarningField.isSyncingIndicatorHidden
        connectButton.isEnabled = bankWarningField.isButtonEnabled
        connectButton.isUserInteractionEnabled = bankWarningField.isButtonEnabled
        interactiveFieldViews.forEach { $0.removeFromSuperview() }
        if !bankWarningField.areCredentialsFieldsHidden {
            interactiveFieldViews = bankWarningField.interactiveCredentials
                .sorted(by: { $0.position > $1.position })
                .compactMap {
                    let fieldView = InteractiveFieldView()
                    fieldView.interactiveCredentials = $0
                    fieldView.delegate = self
                    return fieldView
                }
            interactiveFieldViews
                .forEach { self.stackView.addArrangedSubview($0) }
        }        
    }
    
    @IBAction func didTapButton(_ sender: Any) {
        guard
            let bankWarningField = bankWarningField,
            bankWarningField.isButtonEnabled
        else {
            return
        }        
        bankWarningDelegate?.didTapBankWarningInfoButton(field: bankWarningField)
    }
    
    func didChangeFieldValue(field: InteractiveFieldView) {
        guard let bankWarningField = bankWarningField else { return }
        bankWarningField.interactiveCredentials = interactiveFieldViews.compactMap { $0.interactiveCredentials }
        connectButton.isEnabled = bankWarningField.isButtonEnabled
        connectButton.isUserInteractionEnabled = bankWarningField.isButtonEnabled
    }
}


