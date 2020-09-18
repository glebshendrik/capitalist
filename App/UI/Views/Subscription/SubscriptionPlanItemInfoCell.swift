//
//  SubscriptionPlanItemInfoCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 18.09.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

protocol SubscriptionPlanItemInfoCellDelegate : class {
    func didTapRestorePurchaseButton()
    func didTapPrivacyPolicyButton()
    func didTapTermsOfUseButton()
}

class SubscriptionPlanItemInfoCell : UITableViewCell {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var restorePurchaseButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var termsOfUseButton: UIButton!
    
    weak var delegate: SubscriptionPlanItemInfoCellDelegate?
    
    var viewModel: PlanInfoItemViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        infoLabel.text = viewModel?.infoMessage
        restorePurchaseButton.setTitle(viewModel?.restorePurchaseTitle, for: .normal)
        privacyPolicyButton.setTitle(viewModel?.privacyButtonTitle, for: .normal)
        termsOfUseButton.setTitle(viewModel?.termsButtonTitle, for: .normal)
    }
    
    @IBAction func didTapRestoreButton(_ sender: Any) {
        delegate?.didTapRestorePurchaseButton()
    }
    
    @IBAction func didTapTermsButton(_ sender: Any) {
        delegate?.didTapTermsOfUseButton()
    }
    
    @IBAction func didTapPrivacyButton(_ sender: Any) {
        delegate?.didTapPrivacyPolicyButton()
    }
}
