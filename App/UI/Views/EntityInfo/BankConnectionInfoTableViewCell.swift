//
//  BankConnectionInfoTableViewCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 16.06.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

protocol BankConnectionInfoTableViewCellDelegate : EntityInfoTableViewCellDelegate {
    func didTapConnectBankButton(field: BankConnectionInfoField)
    func didTapDisconnectBankButton(field: BankConnectionInfoField)
    func didTapSendInteractiveFieldsButton(field: BankConnectionInfoField)
    func didTapReconnectBankButton(field: BankConnectionInfoField)
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
        updateReconnectViewUI()
        updateDescriptionUI()
        updateConnectButtonUI()
        updatePermissionsUI()
    }
    
    private func updateReconnectViewUI() {
        guard let bankConnectionField = bankConnectionField else { return }
        
        reconnectView.isHidden = bankConnectionField.isReconnectViewHidden
        
        titleLabel.text = bankConnectionField.title
        warningIconImageView.isHidden = bankConnectionField.isWarningIconHidden
        syncActivityIndicator.isHidden = bankConnectionField.isSyncingIndicatorHidden
        messageLabel.text = bankConnectionField.message
        reconnectButton.setTitle(bankConnectionField.reconnectButtonText, for: .normal)
        
        updateInteractiveFieldsUI()
    }
    
    private func updateInteractiveFieldsUI() {
        guard let bankConnectionField = bankConnectionField else { return }
        
        interactiveFieldViews.forEach { $0.removeFromSuperview() }
        
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
        
        dividerView.removeFromSuperview()
        reconnectButton.removeFromSuperview()
        reconnectItemsStackView.addArrangedSubview(dividerView)
        reconnectItemsStackView.addArrangedSubview(reconnectButton)
        
        dividerView.isHidden = bankConnectionField.isDividerHidden
        reconnectButton.isHidden = bankConnectionField.isReconnectButtonHidden
    }
    
    private func updateConnectButtonUI() {
        guard let bankConnectionField = bankConnectionField else { return }
        connectButton.setTitle(bankConnectionField.connectButtonText, for: .normal)
        connectButton.isHidden = bankConnectionField.isConnectButtonHidden
        connectButton.backgroundColor = .clear
        if let asset = bankConnectionField.connectButtonBackgroundColorAsset {
            connectButton.backgroundColor = UIColor.by(asset)
        }
    }
    
    private func updateDescriptionUI() {
        guard let bankConnectionField = bankConnectionField else { return }
        descriptionLabel.text = bankConnectionField.description
        descriptionLabel.isHidden = bankConnectionField.isDescriptionHidden
    }
    
    private func updatePermissionsUI() {
        guard let bankConnectionField = bankConnectionField else { return }
        reconnectButton.isEnabled = bankConnectionField.isReconnectButtonEnabled
        reconnectButton.isUserInteractionEnabled = bankConnectionField.isReconnectButtonEnabled
        connectButton.isEnabled = bankConnectionField.isConnectButtonEnabled
        connectButton.isUserInteractionEnabled = bankConnectionField.isConnectButtonEnabled
    }
    
    @IBAction func didTapConnectButton(_ sender: Any) {
        guard
            let bankConnectionField = bankConnectionField,
            bankConnectionField.isConnectButtonEnabled
        else {
            return
        }
        if bankConnectionField.isConnectionConnected {
            bankConnectionDelegate?.didTapDisconnectBankButton(field: bankConnectionField)
        }
        else {
            bankConnectionDelegate?.didTapConnectBankButton(field: bankConnectionField)
        }
    }
        
    @IBAction func didTapReconnectButton(_ sender: Any) {
        guard
            let bankConnectionField = bankConnectionField,
            bankConnectionField.isReconnectButtonEnabled
        else {
            return
        }
        if bankConnectionField.hasInteractiveCredentialsValues {
            bankConnectionDelegate?.didTapSendInteractiveFieldsButton(field: bankConnectionField)
        }
        else if !bankConnectionField.isSyncing {
            bankConnectionDelegate?.didTapReconnectBankButton(field: bankConnectionField)
        }
    }
        
    func didChangeFieldValue(fieldView: InteractiveFieldView) {
        guard
            let bankConnectionField = bankConnectionField,
            let field = fieldView.interactiveCredentialsField
        else {
            return
        }
        bankConnectionField.update(field)
        updatePermissionsUI()
    }
}


