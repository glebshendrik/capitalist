//
//  SubscriptionPlanItemDescriptionCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 18.09.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

class SubscriptionPlanItemDescriptionCell : UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var viewModel: PlanDescriptionItemViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        descriptionLabel.text = viewModel?.description
    }
}
