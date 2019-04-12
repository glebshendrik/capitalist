//
//  PieChartCollectionViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 12/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import Charts


class PieChartCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var pieChartView: PieChartView!
    
    var chartData: PieChartData? = nil {
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
        pieChartView.legend.enabled = false
        
//        pieChartView.drawBordersEnabled = false
        pieChartView.drawMarkers = false
//        pieChartView.setViewPortOffsets(left: 0, top: 30, right: 0, bottom: 30)
    }
    
    private func updateUI() {
        pieChartView.clear()
        guard let chartData = chartData else { return }
        pieChartView.data = chartData
        pieChartView.centerText = chartData.dataSets.first?.label
    }
}

