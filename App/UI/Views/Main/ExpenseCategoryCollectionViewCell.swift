//
//  ExpenseCategoryCollectionViewCell.swift
//  Three Baskets
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
    
    override var canDelete: Bool {
        guard let viewModel = viewModel else { return true }
        return !viewModel.isCredit
    }
        
    override func setupIcon() {
        super.setupIcon()
        icon.backgroundCornerRadius = 24
    }
    
    override func updateIcon() {
        super.updateIcon()
        guard let viewModel = viewModel else { return }
        icon.defaultIconName = viewModel.defaultIconName
        icon.backgroundImage = UIImage(named: viewModel.iconBackgroundImageName)
        icon.iconURL = viewModel.iconURL
        icon.isBackgroundHidden = viewModel.isSpendingProgressCompleted
    }
        
    override func updateProgress() {
        super.updateProgress()
        guard let viewModel = viewModel else { return }        
        progress.backgroundImage = UIImage(named: viewModel.progressBackgroundImageName)
        progress.progressColor = progressColor(basketType: viewModel.basketType)
        progress.isHidden = !viewModel.areExpensesPlanned
        progress.isBackgroundHidden = !viewModel.isSpendingProgressCompleted
        progress.isProgressHidden = viewModel.isSpendingProgressCompleted
        progress.progressWidth = CGFloat(viewModel.spendingProgress) * progressContainerWidth
        progress.text = viewModel.planned
        progress.labelColor = viewModel.isSpendingProgressCompleted
            ? UIColor.by(.textFFFFFF)
            : UIColor.by(.dark2A314B)
    }
    
    
    override func updateDescription() {
        super.updateDescription()
        itemDescription.titleText = viewModel?.name
        itemDescription.amountText = viewModel?.spentRounded
        itemDescription.isSubAmountHidden = true
    }
}
