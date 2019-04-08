//
//  GraphTableViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import Charts

private class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
//        dateFormatter.dateFormat = "MMM, yy"
        dateFormatter.dateFormat = "dd/MM"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

class GraphTableViewCell : UITableViewCell {
    @IBOutlet weak var lineChartView: LineChartView!
    
    var viewModel: GraphViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
//        lineChartView.delegate = self
        
        lineChartView.leftAxis.enabled = true
        lineChartView.rightAxis.enabled = false

        lineChartView.xAxis.setLabelCount(5, force: true)
        
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.pinchZoomEnabled = false
        
        
        lineChartView.dragEnabled = true
        lineChartView.xAxis.drawAxisLineEnabled = true
        lineChartView.leftAxis.drawZeroLineEnabled = true
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.valueFormatter = DateValueFormatter()
        lineChartView.xAxis.forceLabelsEnabled = true

        lineChartView.drawBordersEnabled = false
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.chartDescription?.font = UIFont(name: "Rubik-Regular", size: 12)!
        lineChartView.chartDescription?.text = ""
        lineChartView.leftAxis.valueFormatter = LargeValueFormatter(appendix: nil)
        
        if viewModel.numberOfDataPoints > 0 {
            lineChartView.xAxis.granularity = viewModel.granularity
        }
        
        lineChartView.data = viewModel.incomeChartData
        
        
        if viewModel.numberOfDataPoints > 0 {
            lineChartView.setVisibleXRangeMaximum(4 * viewModel.granularity)
            lineChartView.moveViewToX(lineChartView.chartXMax)
        }
        
    }
}
