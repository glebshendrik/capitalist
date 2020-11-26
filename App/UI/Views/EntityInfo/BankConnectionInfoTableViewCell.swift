//
//  BankConnectionInfoTableViewCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 16.06.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

protocol BankConnectionInfoTableViewCellDelegate : EntityInfoTableViewCellDelegate {
    func didTapConnectBankButton(field: BankConnectionInfoField?)
    func didTapDisconnectBankButton(field: BankConnectionInfoField?)
    func didTapSendInteractiveFieldsButton(field: BankConnectionInfoField?)
}

class BankConnectionInfoTableViewCell : EntityInfoTableViewCell, InteractiveFieldViewDelegate {
    @IBOutlet weak var reconnectView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var warningIconImageView: UIImageView!
    @IBOutlet weak var syncActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var reconnectItemsStackView: UIStackView!
    @IBOutlet weak var messageLabel: UILabel!
    var interactiveFieldViews: [InteractiveFieldView] = []
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var reconnectButton: HighlightButton!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var connectButton: HighlightButton!
            
    var bankConnectionDelegate: BankConnectionInfoTableViewCellDelegate? {
        return delegate as? BankConnectionInfoTableViewCellDelegate
    }
    
    var bankConnectionField: BankConnectionInfoField? {
        return field as? BankConnectionInfoField
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        syncActivityIndicator.startAnimating()
    }
    
    override func updateUI() {
        guard let bankConnectionField = bankConnectionField else { return }
        
        // Titles
        titleLabel.text = bankConnectionField.title
        messageLabel.text = bankConnectionField.message
        reconnectButton.setTitle(bankConnectionField.reconnectButtonText, for: .normal)
        connectButton.setTitle(bankConnectionField.connectButtonText, for: .normal)
        descriptionLabel.text = bankConnectionField.description
        
        // Visibility
        warningIconImageView.isHidden = bankConnectionField.isWarningIconHidden
        syncActivityIndicator.isHidden = bankConnectionField.isSyncingIndicatorHidden
        
        
        interactiveFieldViews.forEach { $0.removeFromSuperview() }
        dividerView.removeFromSuperview()
        reconnectButton.removeFromSuperview()
        if !bankConnectionField.areCredentialsFieldsHidden {
            interactiveFieldViews = bankConnectionField.interactiveCredentials
                .sorted(by: { $0.position < $1.position })
                .compactMap {
                    let fieldView = InteractiveFieldView()
                    fieldView.interactiveCredentialsField = $0
                    fieldView.delegate = self
                    return fieldView
                }
            interactiveFieldViews
                .forEach { self.reconnectItemsStackView.addArrangedSubview($0) }
        }
        
        // Permissions
        connectButton.isEnabled = bankConnectionField.isConnectButtonEnabled
        connectButton.isUserInteractionEnabled = bankConnectionField.isConnectButtonEnabled
    }
    
    @IBAction func didTapConnectButton(_ sender: Any) {
//        guard
//            let bankWarningField = bankConnectionField,
//            bankWarningField.isButtonEnabled
//        else {
//            return
//        }
//        bankConnectionDelegate?.didTapSendInteractiveFieldsButton(field: bankWarningField)
    }
    
    @IBAction func didTapDisconnectButton(_ sender: Any) {
//        guard
//            let bankWarningField = bankConnectionField,
//            bankWarningField.isButtonEnabled
//        else {
//            return
//        }
//        bankConnectionDelegate?.didTapSendInteractiveFieldsButton(field: bankWarningField)
    }
    
    @IBAction func didTapReconnectButton(_ sender: Any) {
//        guard
//            let bankWarningField = bankConnectionField,
//            bankWarningField.isButtonEnabled
//        else {
//            return
//        }
//        bankConnectionDelegate?.didTapSendInteractiveFieldsButton(field: bankWarningField)
    }
    
    @IBAction func didTapSendInteractiveFieldsButton(_ sender: Any) {
//        guard
//            let bankWarningField = bankConnectionField,
//            bankWarningField.isButtonEnabled
//        else {
//            return
//        }
//        bankConnectionDelegate?.didTapSendInteractiveFieldsButton(field: bankWarningField)
    }
    
    func didChangeFieldValue(field: InteractiveFieldView) {
        guard let bankConnectionField = bankConnectionField else { return }
        bankConnectionField.
        bankWarningField.interactiveCredentials = interactiveFieldViews.compactMap { $0.interactiveCredentials }
        connectButton.isEnabled = bankWarningField.isButtonEnabled
        connectButton.isUserInteractionEnabled = bankWarningField.isButtonEnabled
    }
}


