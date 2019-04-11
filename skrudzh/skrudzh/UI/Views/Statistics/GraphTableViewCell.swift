//
//  GraphTableViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import Charts

protocol GraphTableViewCellDelegate {
    func didTapGraphTypeButton()
    func didTapGraphScaleButton()
}

class GraphTableViewCell : UITableViewCell {
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var currentPositionMarker: UIView!
    @IBOutlet weak var graphTypeSwitchButton: UIButton!
    @IBOutlet weak var graphScaleSwitchButton: UIButton!
    
    var delegate: GraphTableViewCellDelegate?
    
    private lazy var dateFormatter: DateFormatter = {
        return DateFormatter()
    }()
    
    var viewModel: GraphViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        updateUI()
    }
    @IBAction func didTapGraphTypeButton(_ sender: Any) {
        delegate?.didTapGraphTypeButton()
    }
    
    @IBAction func didTapGraphScaleButton(_ sender: Any) {
        delegate?.didTapGraphScaleButton()
    }
    
    private func setupUI() {
        setupLineChart()
        setupButtons()
    }
    
    private func setupButtons() {
        graphTypeSwitchButton.setImageToRight()
        graphScaleSwitchButton.setImageToRight()
    }
    
    private func setupLineChart() {
        lineChartView.delegate = self
        
        lineChartView.leftAxis.enabled = true
        lineChartView.rightAxis.enabled = false
        
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = true
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = true
        lineChartView.dragEnabled = true
        
        lineChartView.leftAxis.drawZeroLineEnabled = false

        lineChartView.leftAxis.labelPosition = .insideChart
        lineChartView.leftAxis.yOffset = -8.0
        
        lineChartView.dragDecelerationFrictionCoef = 0.95
        
        lineChartView.drawMarkers = false
        lineChartView.setViewPortOffsets(left: 0, top: 30, right: 0, bottom: 40)
        lineChartView.setDragOffsetX(lineChartView.frame.width / 2)
        
        lineChartView.xAxis.drawAxisLineEnabled = true
        lineChartView.xAxis.drawGridLinesEnabled = false
        
        lineChartView.xAxis.forceLabelsEnabled = true
        lineChartView.xAxis.labelPosition = .bottom
        
        lineChartView.drawBordersEnabled = false
        lineChartView.drawGridBackgroundEnabled = false
        
        lineChartView.legend.enabled = true
        lineChartView.legend.yOffset = 0
        
        lineChartView.renderer = LineChartAreasRenderer(dataProvider: lineChartView, animator: lineChartView.chartAnimator, viewPortHandler: lineChartView.viewPortHandler)
        

    }
    
    private func updateUI() {
        updateButtons()
        updateCurrentPositionMarker()
        updateDateFormatter()
        updateLineChart()
    }
    
    private func updateButtons() {
        graphTypeSwitchButton.setTitle(viewModel?.graphType.title, for: .normal)
        graphScaleSwitchButton.setTitle(viewModel?.graphPeriodScale.title, for: .normal)
    }
    
    private func updateCurrentPositionMarker() {
        currentPositionMarker.isHidden = !(viewModel?.hasData ?? false)
    }
    
    private func updateDateFormatter() {
        guard   let viewModel = viewModel else { return }
        dateFormatter.dateFormat = viewModel.dateFormat
    }
    
    private func updateLineChart() {
        lineChartView.clear()
        lineChartView.leftAxis.resetCustomAxisMin()
        updateLineChartCurrentPointUI()
        
        guard   let viewModel = viewModel,
                let currency = viewModel.currency,
                viewModel.hasData else { return }
        
        lineChartView.xAxis.valueFormatter = DateValueFormatter(dateFormat: viewModel.dateFormat)
        lineChartView.leftAxis.valueFormatter = CurrencyValueFormatter(currency: currency)
        
        if viewModel.shouldLimitMinimumValueToZero {
            lineChartView.leftAxis.axisMinimum = 0
        }

        lineChartView.xAxis.setLabelCount(viewModel.labelsCount, force: true)
        lineChartView.xAxis.granularity = viewModel.granularity
        
        lineChartView.data = viewModel.lineChartData
        
        lineChartView.setVisibleXRangeMaximum(viewModel.visibleXRangeMaximum)
        lineChartView.zoom(scaleX: 0.0, scaleY: 0.0, x: 0.0, y: 0.0)
        lineChartView.moveViewToX(viewModel.lineChartCurrentPointWithOffset ?? lineChartView.chartXMax)
        
    }
}

extension GraphTableViewCell : ChartViewDelegate {
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
        switch chartView {
        case lineChartView:
            let point = lineChartView.getEntryByTouchPoint(point: CGPoint(x: lineChartView.frame.size.width / 2.0, y: 0.0))?.x
            updateLineChart(currentPoint: point)
        default:
            return
        }
    }
    
    private func updateLineChart(currentPoint: Double?) {
        viewModel?.lineChartCurrentPoint = currentPoint
        updateLineChartCurrentPointUI()
    }
    
    private func updateLineChartCurrentPointUI() {
        if let date = viewModel?.lineChartCurrentPointDate {
            currentDateLabel.text = dateFormatter.string(from: date)
        } else {
            currentDateLabel.text = nil
        }
        
    }
}

class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    init(dateFormat: String) {
        super.init()
        dateFormatter.dateFormat = dateFormat
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

class CurrencyValueFormatter: NSObject, IValueFormatter, IAxisValueFormatter {
    
    let currency: Currency
    
    init(currency: Currency) {
        self.currency = currency
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return format(value: value)
    }
    
    public func stringForValue(
        _ value: Double,
        entry: ChartDataEntry,
        dataSetIndex: Int,
        viewPortHandler: ViewPortHandler?) -> String {
        return format(value: value)
    }
    
    fileprivate func format(value: Double) -> String {
        
        let amount = NSDecimalNumber(floatLiteral: value)
        
        return amount.moneyCurrencyString(with: currency, shouldRound: true) ?? amount.stringValue
    }
}
