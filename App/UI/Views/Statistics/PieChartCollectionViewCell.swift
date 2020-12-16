//
//  PieChartCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import Charts

class PieChartCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var pieChartView: PieChartView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        pieChartView.usePercentValuesEnabled = false
        pieChartView.legend.enabled = false
        pieChartView.entryLabelFont  = UIFont(name: "Roboto-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
        pieChartView.entryLabelColor = .darkGray
        pieChartView.highlightPerTapEnabled = false
        pieChartView.drawMarkers = false
        pieChartView.drawSlicesUnderHoleEnabled = false
        pieChartView.holeRadiusPercent = 0.58
        pieChartView.transparentCircleRadiusPercent = 0.58
        pieChartView.chartDescription?.enabled = false
        pieChartView.drawCenterTextEnabled = false
        pieChartView.drawHoleEnabled = true
        pieChartView.holeColor = UIColor.by(.black2)
        pieChartView.rotationAngle = 0
        pieChartView.rotationEnabled = false
        pieChartView.noDataText = ""
    }
    
    func set(chartData: PieChartData?) {
        pieChartView.clear()
        guard let chartData = chartData else { return }
        pieChartView.data = chartData
        
//        pieChartView.animate(xAxisDuration: 0.0, yAxisDuration: 0.3)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

