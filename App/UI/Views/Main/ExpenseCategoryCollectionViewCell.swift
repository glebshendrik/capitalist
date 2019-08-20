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

class ExpenseCategoryCollectionViewCell : EditableCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var progressView: CircleProgressView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var spentLabel: UILabel!
    @IBOutlet weak var plannedLabel: UILabel!
    
    var viewModel: ExpenseCategoryViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }
        
        let joyBackgroundColor = UIColor.by(.joy6EEC99)
        let riskBackgroundColor = UIColor.by(.riskC765F0)
        let safeBackgroundColor = UIColor.by(.safe4828D1)
        let joyTrackColor = UIColor.by(.joy6EEC99).withAlphaComponent(0.5)
        let riskTrackColor = UIColor.by(.riskC765F0).withAlphaComponent(0.5)
        let safeTrackColor = UIColor.by(.safe4828D1).withAlphaComponent(0.5)
        
        func iconTintColor() -> UIColor {
            return UIColor.by(.textFFFFFF)
        }
        
        func progressTrackColor() -> UIColor {
            guard !viewModel.isSpendingProgressCompleted else {
                return UIColor.by(.dark1F263E)
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
        
        func progressTrackBackgroundColor() -> UIColor {
            guard viewModel.areExpensesPlanned else {
                return .clear
            }
            
            guard !viewModel.isSpendingProgressCompleted else {
                return UIColor.by(.dark1F263E)
            }
            
            switch viewModel.expenseCategory.basketType {
            case .joy:
                return joyTrackColor
            case .risk:
                return riskTrackColor
            case .safe:
                return safeTrackColor
            }
        }
        
        func defaultIconName() -> String {
            return viewModel.expenseCategory.basketType.iconCategory.defaultIconName
        }
        
        func progressInnerImage() -> UIImage? {
            guard !viewModel.isSpendingProgressCompleted else {
                return nil
            }
            
            switch viewModel.expenseCategory.basketType {
            case .joy:
                return UIImage(named: "joy-background")
            case .risk:
                return UIImage(named: "risk-background")
            case .safe:
                return UIImage(named: "safe-background")
            }
        }
        
        nameLabel.text = viewModel.name
        spentLabel.text = viewModel.spentRounded
        plannedLabel.text = viewModel.planned
        plannedLabel.isHidden = !viewModel.areExpensesPlanned
        iconImageView.setImage(with: viewModel.iconURL,
                               placeholderName: defaultIconName(),
                               renderingMode: .alwaysTemplate)
        progressView.progress = viewModel.spendingProgress
        iconImageView.tintColor = iconTintColor()
        
        progressView.trackWidth = 1.5
        progressView.trackBackgroundColor = progressTrackBackgroundColor()
        progressView.centerImage = progressInnerImage()
        progressView.centerFillColor = UIColor.by(.dark1F263E)
        progressView.trackFillColor = progressTrackColor()
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }        
}
