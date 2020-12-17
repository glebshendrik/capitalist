//
//  SubscriptionPlanItemFreeCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 18.09.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

protocol SubscriptionPlanItemFreeCellDelegate : class {
    func didTapFreeContinueButton()
}

class SubscriptionPlanItemFreeCell : UITableViewCell {
    @IBOutlet weak var continueButton: UIButton!
    
    weak var delegate: SubscriptionPlanItemFreeCellDelegate?
    
    var viewModel: PlanFreeItemViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        continueButton.setTitle(viewModel?.freePurchaseTitle, for: .normal)
    }
    
    @IBAction func didTapContinueButton(_ sender: Any) {
        delegate?.didTapFreeContinueButton()
    }
}
