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
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var creditContainer: UIView?
    @IBOutlet weak var creditLabel: UILabel?
    
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var iconVerticalConstraint: NSLayoutConstraint?
    let largeIconWidth: CGFloat = 24
    let smallIconWidth: CGFloat = 15
    let largeIconOffset: CGFloat = 0
    let smallIconOffset: CGFloat = -3
        
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
        updateCreditLimit()
        super.updateUI()
    }
    
    func updateLabels() {
        guard let viewModel = viewModel else { return }
        nameLabel.text = viewModel.name
        amountLabel.text = viewModel.amountRounded
    }
    
    func updateIcon() {
        guard let viewModel = viewModel else { return }
        iconImageView.setImage(with: viewModel.iconURL, placeholderName: viewModel.defaultIconName, renderingMode: .alwaysTemplate)
        iconImageView.tintColor = UIColor.by(.textFFFFFF)
        
        iconWidthConstraint?.constant = viewModel.inCredit ? smallIconWidth : largeIconWidth
        iconHeightConstraint?.constant = viewModel.inCredit ? smallIconWidth : largeIconWidth
        iconVerticalConstraint?.constant = viewModel.inCredit ? smallIconOffset : largeIconOffset
        contentView.layoutIfNeeded()
    }
    
    func updateCreditLimit() {
        guard let viewModel = viewModel else { return }
        creditContainer?.isHidden = !viewModel.inCredit
        creditLabel?.text = viewModel.credit
    }
}
