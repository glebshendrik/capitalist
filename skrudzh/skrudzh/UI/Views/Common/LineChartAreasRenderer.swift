//
//  LineChartAreasRenderer.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 10/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import Charts

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
    
    override func isDrawingValuesAllowed(dataProvider: ChartDataProvider?) -> Bool {
        guard let data = dataProvider?.data,
              !viewPortHandler.scaleX.isFinite else { return false }
        
        return data.entryCount < Int(CGFloat(dataProvider?.maxVisibleCount ?? 0) * viewPortHandler.scaleX)
    }
    
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
