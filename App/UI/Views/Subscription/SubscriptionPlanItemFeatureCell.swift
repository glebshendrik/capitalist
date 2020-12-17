//
//  SubscriptionPlanItemFeatureCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 18.09.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

class SubscriptionPlanItemFeatureCell : UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var viewModel: PlanFeatureItemViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }
        iconImageView.image = UIImage(named: viewModel.imageName)
        descriptionLabel.text = viewModel.description
    }
}
