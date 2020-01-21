//
//  CreditTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import AlamofireImage

class CreditTableViewCell : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var monthlyPaymentLabel: UILabel!
    @IBOutlet weak var nextDateLabel: UILabel!
    @IBOutlet weak var progressView: ProgressView!
    
    var placeholderName: String {
        return "credit-default-icon"
    }
    
    var imageTintColor: UIColor {
        return UIColor.by(.textFFFFFF)
    }
    
    var viewModel: CreditViewModel? {
        didSet {
            updateUI()
        }
    }
    
    var paymentsProgress: CGFloat {
        guard let viewModel = viewModel else { return 0.0 }
        return CGFloat(viewModel.paymentsProgress)
    }
    
    func updateUI() {
        nameLabel.text = viewModel?.name
        typeLabel.text = viewModel?.typeName
        monthlyPaymentLabel.text = viewModel?.monthlyPayment
        nextDateLabel.text = viewModel?.nextPaymentDate
        iconImageView.setImage(with: viewModel?.iconURL,
                               placeholderName: placeholderName,
                               renderingMode: .alwaysTemplate)
        iconImageView.tintColor = imageTintColor
        
        progressView.progressColor = UIColor.by(.blue6B93FB)
        progressView.limitText = viewModel?.returnAmount
        progressView.progressText = viewModel?.paidAmount
        progressView.labelsColor = UIColor.by(.textFFFFFF)
        progressView.progressWidth = progressView.bounds.width * paymentsProgress
//        contentView.layoutIfNeeded()
    }
}
