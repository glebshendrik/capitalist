//
//  ExpenseCategoryTableViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

class ExpenseCategoryTableViewCell : UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var monthlySpentLabel: UILabel!
    
    var viewModel: ExpenseCategoryViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }
                
        func basketColor() -> UIColor {
            switch viewModel.expenseCategory.basketType {
            case .joy:
                return UIColor(red: 1, green: 0.85, blue: 0.27, alpha: 1)
            case .risk:
                return UIColor(red: 0.49, green: 0.52, blue: 1, alpha: 1)
            case .safe:
                return UIColor(red: 0.13, green: 0.86, blue: 0.27, alpha: 1)
            }
        }
        
        func defaultIconName() -> String {
            switch viewModel.expenseCategory.basketType {
            case .joy:
                return "joy-default-icon"
            case .risk:
                return "risk-default-icon"
            case .safe:
                return "safe-default-icon"
            }
        }
        
        nameLabel.text = viewModel.name
        monthlySpentLabel.text = viewModel.monthlySpentRounded
        iconImageView.setImage(with: viewModel.iconURL,
                               placeholderName: defaultIconName(),
                               renderingMode: .alwaysTemplate)
        iconImageView.tintColor = basketColor()
    }
}
