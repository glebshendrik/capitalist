//
//  IncomeSourceCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

class IncomeSourceCollectionViewCell : EditableCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var incomeAmountLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var progressView: BasketItemProgress!
    
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconVerticalConstraint: NSLayoutConstraint!
    let progressContainerWidth: CGFloat = 46.0
    let largeIconWidth: CGFloat = 24
    let smallIconWidth: CGFloat = 15
    let largeIconOffset: CGFloat = 0
    let smallIconOffset: CGFloat = -3
    
    var viewModel: IncomeSourceViewModel? {
        didSet {
            updateUI()
        }
    }
    
    override var canDelete: Bool {
        guard let viewModel = viewModel else { return super.canDelete }
        return !viewModel.isChild
    }

    func updateUI() {
        updateLabels()
        updateIcon()
        updateProgress()
    }
    
    func updateLabels() {
        nameLabel.text = viewModel?.name
        incomeAmountLabel.text = viewModel?.amountRounded
    }
    
    func updateIcon() {
        guard let viewModel = viewModel else { return }
        iconImageView.setImage(with: viewModel.iconURL, placeholderName: viewModel.defaultIconName, renderingMode: .alwaysTemplate)
        iconImageView.tintColor = UIColor.by(.textFFFFFF)
        
        iconWidthConstraint.constant = viewModel.areIncomesPlanned ? smallIconWidth : largeIconWidth
        iconHeightConstraint.constant = viewModel.areIncomesPlanned ? smallIconWidth : largeIconWidth
        iconVerticalConstraint.constant = viewModel.areIncomesPlanned ? smallIconOffset : largeIconOffset
        contentView.layoutIfNeeded()
    }
    
    func updateProgress() {
        guard let viewModel = viewModel else { return }
        progressView.isHidden = !viewModel.areIncomesPlanned
        progressView.isBackgroundHidden = true
        progressView.isProgressHidden = false
        progressView.progressWidth = CGFloat(viewModel.incomeProgress) * progressContainerWidth
        progressView.text = viewModel.plannedAtPeriod
        progressView.backgroundColor = UIColor.by(.dark283455)
        progressView.progressColor = viewModel.isIncomeProgressCompleted
            ? UIColor.by(.green68E79B)
            : UIColor.by(.green295C5B)
        progressView.labelColor = viewModel.isIncomeProgressCompleted
            ? UIColor.by(.dark1F263E)
            : UIColor.by(.textFFFFFF)
    }
    
}

