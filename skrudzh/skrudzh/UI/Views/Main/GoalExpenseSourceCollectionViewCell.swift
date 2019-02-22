//
//  GoalExpenseSourceCollectionViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 25/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import AlamofireImage
import CircleProgressView

class GoalExpenseSourceCollectionViewCell : ExpenseSourceCollectionViewCell {
    @IBOutlet weak var progressView: CircleProgressView!
    
    override var placeholderName: String {
        return "wallet-goal-default-icon"
    }
    
    override func updateUI() {
        super.updateUI()
        
        guard let viewModel = viewModel else { return }
        
        func progressInnerColor() -> UIColor {
            guard viewModel.isGoalCompleted else {
                return .white
            }
            
            return UIColor(red: 107.0 / 255.0, green: 147.0 / 255.0, blue: 251.0 / 255.0, alpha: 1)
        }
        
        func iconTintColor() -> UIColor {
            if viewModel.isGoalCompleted {
                return .white
            }
            return imageTintColor
        }
        
        iconImageView.tintColor = iconTintColor()
        
        progressView.progress = viewModel.goalProgress
        progressView.centerFillColor = progressInnerColor()
        progressView.trackFillColor = imageTintColor
        
        
    }        
}
