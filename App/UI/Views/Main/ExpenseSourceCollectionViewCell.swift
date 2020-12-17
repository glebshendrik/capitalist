//
//  ExpenseSourceCollectionViewCell.swift
//  Capitalist
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
    @IBOutlet weak var cardTypeImageView: UIImageView!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var connectionActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var warningIndicatorImageView: UIImageView!
    
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
        updateCardTypeUI()
        updateConnectionUI()
        super.updateUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        connectionActivityIndicator.startAnimating()
    }
    
    func updateLabels() {
        guard let viewModel = viewModel else { return }
        nameLabel.text = viewModel.name
        amountLabel.text = viewModel.amountRounded
        cardNumberLabel.text = viewModel.cardLastNumbers
    }
    
    func updateIcon() {
        guard let viewModel = viewModel else { return }
        iconView.iconURL = viewModel.iconURL
        iconView.defaultIconName = viewModel.defaultIconName
        iconView.vectorIconMode = .medium        
        contentView.layoutIfNeeded()
    }
    
    func updateCardTypeUI() {
        guard let cardTypeImageName = viewModel?.cardTypeImageName else {
            cardTypeImageView.image = nil
            return
        }
        cardTypeImageView.image = UIImage(named: cardTypeImageName)
    }
        
    func updateConnectionUI() {
        iconView.isHidden = viewModel?.iconHidden ?? false
        connectionActivityIndicator.isHidden = viewModel?.connectionIndicatorHidden ?? true
        warningIndicatorImageView.isHidden = viewModel?.reconnectWarningHidden ?? true
    }
    
    override func setupSelectionIndicator() {
        selectionIndicator.isHidden = true
        selectionIndicator.cornerRadius = 8
        selectionIndicator.backgroundColor = UIColor.by(.blue1)
        background.insertSubview(selectionIndicator, at: 0)
    }
}
