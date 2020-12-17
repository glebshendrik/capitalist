//
//  SubscriptionPlanItemUnlimitedCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 01.10.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

protocol SubscriptionPlanItemUnlimitedCellDelegate : class {
    func didTapUnlimitedContinueButton(product: ProductViewModel)
}

class SubscriptionPlanItemUnlimitedCell : UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    weak var delegate: SubscriptionPlanItemUnlimitedCellDelegate?
    
    var viewModel: PlanUnlimitedItemViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        descriptionLabel.text = viewModel?.unlimitedDescriptionMessage
        continueButton.setTitle(viewModel?.purchaseTitle, for: .normal)
    }
    
    @IBAction func didTapContinueButton(_ sender: Any) {
        guard let product = viewModel?.product else { return }
        delegate?.didTapUnlimitedContinueButton(product: product)
    }
}
