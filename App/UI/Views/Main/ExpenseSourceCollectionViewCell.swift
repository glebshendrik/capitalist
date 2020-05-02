//
//  ExpenseSourceCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import AlamofireImage
import CircleProgressView

class ExpenseSourceCollectionViewCell : TransactionableCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var iconView: IconView!
    
    var viewModel: ExpenseSourceViewModel? {
        didSet {
            updateUI()
        }
    }
      
    override var transactionable: Transactionable? {
        return viewModel
    }
    
    override func updateUI() {
        updateLabels()
        updateIcon()
        super.updateUI()
    }
    
    func updateLabels() {
        guard let viewModel = viewModel else { return }
        nameLabel.text = viewModel.name
        amountLabel.text = viewModel.amountRounded
    }
    
    func updateIcon() {
        guard let viewModel = viewModel else { return }
        iconView.iconURL = viewModel.iconURL
        iconView.defaultIconName = viewModel.defaultIconName
        iconView.iconType = viewModel.iconType
        iconView.vectorIconMode = .compact        
        contentView.layoutIfNeeded()
    }
        
    override func setupSelectionIndicator() {
        selectionIndicator.isHidden = true
        selectionIndicator.cornerRadius = 8
        selectionIndicator.backgroundColor = UIColor.by(.blue1)
        background.insertSubview(selectionIndicator, at: 0)
    }
}
