//
//  ExpenseCategoryCollectionViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 17/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import AlamofireImage
import CircleProgressView

class ExpenseCategoryCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var progressView: CircleProgressView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var monthlySpentLabel: UILabel!
    @IBOutlet weak var monthlyPlannedLabel: UILabel!
    
    var viewModel: ExpenseCategoryViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }
        
        let joyColor = UIColor(red: 1, green: 0.85, blue: 0.27, alpha: 1)
        let joyBackgroundColor = UIColor(red: 0.99, green: 0.85, blue: 0.32, alpha: 1)
        
        let riskColor = UIColor(red: 0.49, green: 0.52, blue: 1, alpha: 1)
        let riskBackgroundColor = UIColor(red: 0.53, green: 0.56, blue: 1, alpha: 1)
        
        let safeColor = UIColor(red: 0.13, green: 0.86, blue: 0.27, alpha: 1)
        let safeBackgroundColor = UIColor(red: 0.49, green: 0.88, blue: 0.36, alpha: 1)
        
        func basketColor() -> UIColor {
            switch viewModel.expenseCategory.basketType {
            case .joy:
                return joyColor
            case .risk:
                return riskColor
            case .safe:
                return safeColor
            }
        }
        
        func iconTintColor() -> UIColor {
            if viewModel.isMonthlyPlanCompleted {
                return .white
            }
            return basketColor()
        }
        
        func progressInnerColor() -> UIColor {
            guard viewModel.isMonthlyPlanCompleted else {
                return .white
            }
            
            switch viewModel.expenseCategory.basketType {
            case .joy:
                return joyBackgroundColor
            case .risk:
                return riskBackgroundColor
            case .safe:
                return safeBackgroundColor
            }
        }
        
        nameLabel.text = viewModel.name
        monthlySpentLabel.text = viewModel.monthlySpent
        monthlyPlannedLabel.text = viewModel.monthlyPlanned
        monthlyPlannedLabel.isHidden = !viewModel.areMonthlyExpensesPlanned
        iconImageView.setImage(with: viewModel.iconURL,
                               placeholderName: "smile-icon",
                               renderingMode: .alwaysTemplate)
        progressView.progress = viewModel.monthlySpentProgress
        iconImageView.tintColor = iconTintColor()
        progressView.centerFillColor = progressInnerColor()
        progressView.trackFillColor = basketColor()
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
