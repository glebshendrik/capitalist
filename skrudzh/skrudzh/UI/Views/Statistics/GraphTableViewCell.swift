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
    @IBOutlet weak var currentDateLabel: UILabel!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter
    }()
    
    var viewModel: GraphViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard   let viewModel = viewModel,
                let currency = viewModel.currency else { return }
        
//        lineChartView.delegate = self
        
        lineChartView.leftAxis.enabled = true
        lineChartView.rightAxis.enabled = false

        
        
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.dragEnabled = true
        
        lineChartView.leftAxis.drawZeroLineEnabled = false
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.labelPosition = .insideChart
        lineChartView.leftAxis.yOffset = -8.0
        
        lineChartView.dragDecelerationFrictionCoef = 0.95
        
        lineChartView.drawMarkers = false
        lineChartView.setViewPortOffsets(left: 0, top: 30, right: 0, bottom: 30)
        lineChartView.setDragOffsetX(lineChartView.frame.width / 2)
        
        lineChartView.xAxis.drawAxisLineEnabled = true
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.valueFormatter = DateValueFormatter()

        lineChartView.xAxis.axisMaximum = viewModel.maxDataPoint
        lineChartView.xAxis.axisMinimum = viewModel.minDataPoint
        
        lineChartView.delegate = self
        
        let labelsCount = viewModel.numberOfDataPoints < 7 ? viewModel.numberOfDataPoints : 7
        
        lineChartView.xAxis.setLabelCount(labelsCount, force: true)
        lineChartView.xAxis.forceLabelsEnabled = true
        lineChartView.xAxis.labelPosition = .bottom
//        lineChartView.xAxis.drawLabelsEnabled = false
        
        lineChartView.drawBordersEnabled = false
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.leftAxis.valueFormatter = CurrencyValueFormatter(currency: currency)
        
        lineChartView.legend.enabled = false
        
        lineChartView.renderer = LineChartAreasRenderer(dataProvider: lineChartView, animator: lineChartView.chartAnimator, viewPortHandler: lineChartView.viewPortHandler)
        
        if viewModel.numberOfDataPoints > 0 {
            lineChartView.xAxis.granularity = viewModel.granularity            
        }
        
        lineChartView.data = viewModel.incomeChartData
        
        if viewModel.numberOfDataPoints > 0 {
            lineChartView.setVisibleXRangeMaximum(Double(labelsCount - 1) * lineChartView.xAxis.granularity)
            lineChartView.moveViewToX(lineChartView.chartXMax)
            currentDateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: lineChartView.chartXMax))
        }
        
    }
}

extension GraphTableViewCell : ChartViewDelegate {
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        let point = lineChartView.getEntryByTouchPoint(point: CGPoint(x: lineChartView.frame.size.width / 2.0, y: 0.0))
        if let date = point?.x {
            currentDateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: date))
        }
    }
}

class AreaFillFormatter: IFillFormatter {
    
    let fillLineDataSet: LineChartDataSet
    
    init(fillLineDataSet: LineChartDataSet) {
        self.fillLineDataSet = fillLineDataSet
    }
    
    public func getFillLinePosition(dataSet: ILineChartDataSet, dataProvider: LineChartDataProvider) -> CGFloat {
        return 0.0
    }
    
    public func getFillLineDataSet() -> LineChartDataSet {
        return fillLineDataSet
    }
    
}

class LineChartAreasRenderer: LineChartRenderer {
    
    override open func drawCubicFill(
        context: CGContext,
        dataSet: ILineChartDataSet,
        spline: CGMutablePath,
        matrix: CGAffineTransform,
        bounds: XBounds)
    {
        if bounds.range <= 0
        {
            return
        }
        
        guard   let areaFillFormatter = dataSet.fillFormatter as? AreaFillFormatter,
                let previousSpline = generateSpline(for: areaFillFormatter.fillLineDataSet, bounds: bounds) else {
            super.drawCubicFill(context: context, dataSet: dataSet, spline: spline, matrix: matrix, bounds: bounds)
            return
        }
        
        let reversed =  UIBezierPath(cgPath: previousSpline).reversing().cgPath
        
        var reversedSplineStart = CGPoint(x: CGFloat(areaFillFormatter.fillLineDataSet.entryForIndex(bounds.min + bounds.range)?.x ?? 0.0),
                                          y: CGFloat(areaFillFormatter.fillLineDataSet.entryForIndex(bounds.min + bounds.range)?.y ?? 0.0))
        reversedSplineStart = reversedSplineStart.applying(matrix)
        
        var splineStart = CGPoint(x: CGFloat(dataSet.entryForIndex(bounds.min)?.x ?? 0.0),
                                  y: CGFloat(dataSet.entryForIndex(bounds.min)?.y ?? 0.0))
        splineStart = splineStart.applying(matrix)
        
        spline.addLine(to: reversedSplineStart)
        spline.addPath(reversed)
        spline.addLine(to: splineStart)
        
        spline.closeSubpath()
        
        if dataSet.fill != nil
        {
            drawFilledPath(context: context, path: spline, fill: dataSet.fill!, fillAlpha: dataSet.fillAlpha)
        }
        else
        {
            drawFilledPath(context: context, path: spline, fillColor: dataSet.fillColor, fillAlpha: dataSet.fillAlpha)
        }
    }
    
    private func generateSpline(for dataSet: ILineChartDataSet, bounds: XBounds) -> CGPath? {
        guard   let dataProvider = dataProvider,
            bounds.range >= 1 else { return nil }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        // the path for the cubic-spline
        let cubicPath = CGMutablePath()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        var prev: ChartDataEntry! = dataSet.entryForIndex(bounds.min)
        var cur: ChartDataEntry! = prev
        
        if cur == nil { return nil }
        
        // let the spline start
        cubicPath.move(to: CGPoint(x: CGFloat(cur.x), y: CGFloat(cur.y * phaseY)), transform: valueToPixelMatrix)
        
        for j in stride(from: (bounds.min + 1), through: bounds.range + bounds.min, by: 1)
        {
            prev = cur
            cur = dataSet.entryForIndex(j)
            
            let cpx = CGFloat(prev.x + (cur.x - prev.x) / 2.0)
            
            cubicPath.addCurve(
                to: CGPoint(
                    x: CGFloat(cur.x),
                    y: CGFloat(cur.y * phaseY)),
                control1: CGPoint(
                    x: cpx,
                    y: CGFloat(prev.y * phaseY)),
                control2: CGPoint(
                    x: cpx,
                    y: CGFloat(cur.y * phaseY)),
                transform: valueToPixelMatrix)
        }
        
        return cubicPath
    }
    
    
}
