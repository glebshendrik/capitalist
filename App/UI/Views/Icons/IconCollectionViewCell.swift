//
//  IconCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import AlamofireImage

class IconCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    
    var viewModel: IconViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }
        
        func placeholderName() -> String {            
            switch viewModel.category {
            case .expenseSource:
                return "wallet-icon"
            case .expenseSourceGoal:
                return "goal-wallet-icon"
            case .expenseCategoryJoy:
                return "smile-icon"
            case .expenseCategoryRisk:
                return "smile-icon"
            case .expenseCategorySafe:
                return "smile-icon"
            case .expenseSourceDebt:
                return "wallet-icon"
            }
        }
        
        iconImageView.setImage(with: viewModel.url, placeholderName: placeholderName(), renderingMode: .alwaysTemplate)
        iconImageView.tintColor = UIColor(red: 0.25, green: 0.27, blue: 0.38, alpha: 1)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale        
    }
}
