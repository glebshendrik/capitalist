//
//  ActiveCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 17/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

class ActiveCollectionViewCell : BasketItemCollectionViewCell {
    var viewModel: ActiveViewModel? {
        didSet {
            updateUI()
        }
    }
      
    override func setupIcon() {
        super.setupIcon()
        icon.backgroundCornerRadius = 4
    }
    
    override func updateIcon() {
        super.updateIcon()
        guard let viewModel = viewModel else { return }
        icon.defaultIconName = viewModel.defaultIconName
        icon.backgroundImage = UIImage(named: viewModel.iconBackgroundImageName)
        icon.iconURL = viewModel.iconURL
        icon.isBackgroundHidden = viewModel.isMonthlyPaymentPlanCompleted
    }
    
    override func updateProgress() {
        super.updateProgress()
        guard let viewModel = viewModel else { return }
        progress.backgroundImage = UIImage(named: viewModel.progressBackgroundImageName)
        progress.progressColor = progressColor(basketType: viewModel.basketType)
        progress.isHidden = !viewModel.areExpensesPlanned
        progress.isBackgroundHidden = !viewModel.isMonthlyPaymentPlanCompleted
        progress.isProgressHidden = viewModel.isMonthlyPaymentPlanCompleted
        progress.progressWidth = CGFloat(viewModel.spendingProgress) * progressContainerWidth
        progress.text = viewModel.plannedAtPeriod
        progress.labelColor = viewModel.isMonthlyPaymentPlanCompleted
            ? UIColor.by(.textFFFFFF)
            : UIColor.by(.dark2A314B)
    }
    
    
    override func updateDescription() {
        super.updateDescription()
        itemDescription.titleText = viewModel?.name
        itemDescription.amountText = viewModel?.investedRounded
        itemDescription.subAmountText = viewModel?.costRounded
        itemDescription.isSubAmountHidden = false
    }
}
