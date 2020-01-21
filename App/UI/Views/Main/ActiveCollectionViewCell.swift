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
      
    override var transactionable: Transactionable? {
        return viewModel
    }
    
    override func setupIcon() {
        super.setupIcon()        
        icon.backgroundCornerRadius = 8
    }
        
    override func updateIcon() {
        super.updateIcon()
        guard let viewModel = viewModel else { return }
        icon.backgroundViewColor = iconBackgroundColor(basketType: viewModel.basketType)
        icon.defaultIconName = viewModel.defaultIconName
        icon.iconURL = viewModel.iconURL
    }
    
    override func updateProgress() {
        super.updateProgress()
        guard let viewModel = viewModel else { return }
        progress.backgroundColor = progressBackgroundColor(basketType: viewModel.basketType)
        progress.progressColor = progressColor(basketType: viewModel.basketType, completed: viewModel.isMonthlyPaymentPlanCompleted)
        progress.isHidden = !viewModel.areExpensesPlanned
        progress.progressWidth = CGFloat(viewModel.spendingProgress) * progressContainerWidth
        progress.text = viewModel.plannedAtPeriod        
    }
    
    
    override func updateDescription() {
        super.updateDescription()
        itemDescription.titleText = viewModel?.name
        itemDescription.amountText = viewModel?.investedRounded
        itemDescription.subAmountText = viewModel?.costRounded
        itemDescription.isSubAmountHidden = false
    }
}
