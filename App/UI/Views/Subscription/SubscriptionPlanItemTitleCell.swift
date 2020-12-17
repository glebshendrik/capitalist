//
//  SubscriptionPlanItemTitleCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 18.09.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

class SubscriptionPlanItemTitleCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    var viewModel: PlanTitleItemViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        titleLabel.text = viewModel?.title
    }
}
