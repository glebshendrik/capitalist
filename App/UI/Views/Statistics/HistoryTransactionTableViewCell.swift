//
//  HistoryTransactionTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class HistoryTransactionTableViewCell : UITableViewCell {
    @IBOutlet weak var destinationIconImageView: UIImageView!
    @IBOutlet weak var sourceTitleLabel: UILabel!
    @IBOutlet weak var destinationTitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var viewModel: HistoryTransactionViewModel? {
        didSet {
            updateUI()
        }
    }
    
    private func  updateUI() {
        guard let viewModel = viewModel else { return }
        
        func destinationIconTintColor() -> UIColor {
            switch viewModel.destinationType {
            case .incomeSource, .expenseSource:
                return UIColor(red: 105 / 255.0, green: 145 / 255.0, blue: 250 / 255.0, alpha: 1)
            case .expenseCategory:
                guard let basketType = viewModel.basketType else {
                    return UIColor(red: 105 / 255.0, green: 145 / 255.0, blue: 250 / 255.0, alpha: 1)
                }
                return basketColor(basketType: basketType)
            }
        }
        
        func basketColor(basketType: BasketType) -> UIColor {
            switch basketType {
            case .joy:
                return UIColor(red: 1, green: 0.85, blue: 0.27, alpha: 1)
            case .risk:
                return UIColor(red: 0.49, green: 0.52, blue: 1, alpha: 1)
            case .safe:
                return UIColor(red: 0.13, green: 0.86, blue: 0.27, alpha: 1)
            }
        }
        
        func expenseCategoryIconPlaceholderName(basketType: BasketType) -> String {
            switch basketType {
            case .joy:
                return "joy-default-icon"
            case .risk:
                return "risk-default-icon"
            case .safe:
                return "safe-default-icon"
            }
        }
        
        func defaultDestinationIconName() -> String {
            switch viewModel.destinationType {
            case .incomeSource, .expenseSource:
                return "wallet-default-icon"
            case .expenseCategory:
                guard let basketType = viewModel.basketType else {
                    return ""
                }
                return expenseCategoryIconPlaceholderName(basketType: basketType)
            }
        }
        
        destinationIconImageView.setImage(with: viewModel.destinationIconURL,
                                          placeholderName: defaultDestinationIconName(),
                                          renderingMode: .alwaysTemplate)
        destinationIconImageView.tintColor = destinationIconTintColor()
        
        sourceTitleLabel.text = viewModel.sourceTitle
        destinationTitleLabel.text = viewModel.destinationTitle
        amountLabel.text = viewModel.amount
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

