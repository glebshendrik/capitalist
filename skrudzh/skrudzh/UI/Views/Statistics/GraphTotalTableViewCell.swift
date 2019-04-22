//
//  GraphTotalTableViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 18/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

class GraphTotalTableViewCell : UITableViewCell {
    @IBOutlet weak var aggregatedValueLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var viewModel: GraphViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    lazy var percentsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1
        formatter.percentSymbol = "%"
        return formatter
    }()
    
    private func updateUI() {
        guard   let viewModel = viewModel,
                case let aggregationType = viewModel.aggregationType,
                let date = viewModel.currentDate,
                let aggregatedTotal = viewModel.filtersAggregatedTotal,
                let value = viewModel.filtersTotalByDate[date],
                let currency = viewModel.currency else { return }
        
        let valueNumber = NSDecimalNumber(floatLiteral: value)
        let aggregatedValueNumber = NSDecimalNumber(floatLiteral: aggregatedTotal)
        
        valueLabel.text = valueNumber.moneyCurrencyString(with: currency, shouldRound: false)
        
        if aggregationType == .percent {
            aggregatedValueLabel.text = "100%"
        } else {
            aggregatedValueLabel.text = aggregatedValueNumber.moneyCurrencyString(with: currency, shouldRound: false)
        }
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
