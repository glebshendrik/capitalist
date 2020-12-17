//
//  ExpenseCategoryCollectionViewCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 17/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import AlamofireImage
import CircleProgressView
import SnapKit

class ExpenseCategoryCollectionViewCell : BasketItemCollectionViewCell {
    var viewModel: ExpenseCategoryViewModel? {
        didSet {
            updateUI()
        }
    }
    
    override var transactionable: Transactionable? {
        return viewModel
    }
    
    override var canDelete: Bool {
        guard let viewModel = viewModel else { return true }
        return !viewModel.isCredit
    }
        
    override func setupIcon() {
        super.setupIcon()
        icon.backgroundCornerRadius = 32
        icon.backgroundViewColor = iconBackgroundColor(basketType: .joy)
    }
        
    override func updateIcon() {
        super.updateIcon()
        guard let viewModel = viewModel else { return }
        icon.defaultIconName = viewModel.defaultIconName
        icon.iconURL = viewModel.iconURL
    }
            
    override func updateProgress() {
        super.updateProgress()
        guard let viewModel = viewModel else { return }
        progress.backgroundColor = progressBackgroundColor(basketType: viewModel.basketType)
        progress.progressColor = progressColor(basketType: viewModel.basketType, completed: viewModel.isSpendingProgressCompleted)
        progress.isHidden = !viewModel.areExpensesPlanned
        progress.progressWidth = CGFloat(viewModel.spendingProgress) * progressContainerWidth
        progress.text = viewModel.plannedAtPeriod
    }    
    
    override func updateDescription() {
        super.updateDescription()
        itemDescription.titleText = viewModel?.name
        itemDescription.amountText = viewModel?.spentRounded
        itemDescription.isSubAmountHidden = true
    }
}
