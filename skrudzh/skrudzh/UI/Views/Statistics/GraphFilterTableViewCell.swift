//
//  GraphFilterTableViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 18/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

class GraphFilterTableViewCell : UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var aggregatedValueLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var viewModel: GraphHistoryTransactionFilter? = nil {
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
        guard let viewModel = viewModel,
              let aggregationType = viewModel.aggregationType,
              let aggregatedValue = viewModel.aggregated,
              let value = viewModel.amount  else { return }
        
        let valueNumber = NSDecimalNumber(floatLiteral: value)
        let aggregatedValueNumber = NSDecimalNumber(floatLiteral: aggregatedValue)
        
        titleLabel.textColor = viewModel.color        
        titleLabel.text = viewModel.title
        valueLabel.text = valueNumber.moneyCurrencyString(with: viewModel.currency, shouldRound: false)
        
        if aggregationType == .percent {
            aggregatedValueLabel.text = percentsFormatter.string(from: aggregatedValueNumber)
        } else {
            aggregatedValueLabel.text = aggregatedValueNumber.moneyCurrencyString(with: viewModel.currency, shouldRound: false)
        }
    }
}
