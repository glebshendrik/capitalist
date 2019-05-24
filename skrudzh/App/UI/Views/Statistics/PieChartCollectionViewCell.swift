//
//  PieChartCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import Charts

struct PieChartViewModel {
    var chartData: PieChartData
    var date: String
    var amount: String
}

class PieChartCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var pieChartView: PieChartView!
    
    var viewModel: PieChartViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        updateUI()
    }
    
    private func setupUI() {
        pieChartView.usePercentValuesEnabled = false
        pieChartView.legend.enabled = false
        pieChartView.entryLabelFont  = UIFont(name: "Rubik-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
        pieChartView.entryLabelColor = .darkGray
        pieChartView.highlightPerTapEnabled = false
        pieChartView.drawMarkers = false
        pieChartView.drawSlicesUnderHoleEnabled = false
        pieChartView.holeRadiusPercent = 0.52
        pieChartView.transparentCircleRadiusPercent = 0.58
        pieChartView.chartDescription?.enabled = false
        pieChartView.drawCenterTextEnabled = true
        pieChartView.drawHoleEnabled = true
        pieChartView.rotationAngle = 0
        pieChartView.rotationEnabled = false
        
    }
    
    private func updateUI() {
        pieChartView.clear()
        guard   let chartData = viewModel?.chartData,
                let date = viewModel?.date,
                let amount = viewModel?.amount,
                case let dateString = "\(date)\n",
                case let string = "\(dateString)\(amount)",
                let rangeOfDate = string.range(of: dateString),
                let rangeOfAmount = string.range(of: amount),
                let paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle else { return }
        
        pieChartView.data = chartData
        
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let dateFont = UIFont(name: "Rubik-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
        let amountFont = UIFont(name: "Rubik-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        
        let attributedString = NSMutableAttributedString(string: string)
        
        attributedString.setAttributes([.font : dateFont,
                                        .foregroundColor : UIColor.gray,
                                        .paragraphStyle : paragraphStyle],
                                       range: NSRange(rangeOfDate, in: string))
        
        attributedString.setAttributes([.font : amountFont,
                                        .paragraphStyle : paragraphStyle],
                                       range: NSRange(rangeOfAmount, in: string))                
        
        pieChartView.centerAttributedText = attributedString
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

