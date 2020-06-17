//
//  BankWarningInfoTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 16.06.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

protocol BankWarningInfoTableViewCellDelegate : EntityInfoTableViewCellDelegate {
    func didTapBankWarningInfoButton(field: BankWarningInfoField?)
}

class BankWarningInfoTableViewCell : EntityInfoTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var connectButton: HighlightButton!
    
    var bankWarningDelegate: BankWarningInfoTableViewCellDelegate? {
        return delegate as? BankWarningInfoTableViewCellDelegate
    }
    
    var bankWarningField: BankWarningInfoField? {
        return field as? BankWarningInfoField
    }
    
    override func updateUI() {
        titleLabel.text = bankWarningField?.title
        messageLabel.text = bankWarningField?.message
        connectButton.setTitle(bankWarningField?.buttonText, for: .normal)
    }
    
    @IBAction func didTapButton(_ sender: Any) {
        bankWarningDelegate?.didTapBankWarningInfoButton(field: bankWarningField)
    }
}
