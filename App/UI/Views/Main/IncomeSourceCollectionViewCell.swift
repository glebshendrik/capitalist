//
//  IncomeSourceCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

class IncomeSourceCollectionViewCell : TransactionableCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var background: UIView!
    
    
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!
    
    var viewModel: IncomeSourceViewModel? {
        didSet {
            updateUI()
        }
    }
    
    override var transactionable: Transactionable? {
        return viewModel
    }
    
    override var canDelete: Bool {
        guard let viewModel = viewModel else { return super.canDelete }
        return !viewModel.isChild
    }
    
    override func updateUI() {
        updateLabels()
        updateIcon()
        super.updateUI()
    }
    
    func updateLabels() {
        nameLabel.text = viewModel?.name.uppercased()
    }
    
    func updateIcon() {
        guard let viewModel = viewModel else { return }
        iconImageView.setImage(with: viewModel.iconURL, placeholderName: viewModel.defaultIconName, renderingMode: .alwaysTemplate)
        iconImageView.tintColor = UIColor.by(.white100)
    }
    
    override func setupSelectionIndicator() {
        selectionIndicator.isHidden = true
        selectionIndicator.cornerRadius = 8
        selectionIndicator.backgroundColor = UIColor.by(.blue1)
        background.insertSubview(selectionIndicator, at: 0)
    }
}

