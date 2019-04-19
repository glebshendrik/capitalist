//
//  GraphTableViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import Charts
import MSPeekCollectionViewDelegateImplementation

protocol GraphTableViewCellDelegate {
    func didTapGraphTypeButton()
    func didTapGraphScaleButton()
    func didTapAggregationTypeButton()
    func didTapLinePieSwitchButton()
    func graphFiltersAndTotalUpdateNeeded()
}

class GraphTableViewCell : UITableViewCell {
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var pieChartsCollectionView: UICollectionView!
    
    @IBOutlet weak var lineChartViewContainer: UIView!
    @IBOutlet weak var pieChartsViewContainer: UIView!
    
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var currentPositionMarker: UIView!
    @IBOutlet weak var graphTypeSwitchButton: UIButton!
    @IBOutlet weak var graphScaleSwitchButton: UIButton!
    @IBOutlet weak var linePieSwitchButton: UIButton!
    @IBOutlet weak var aggregationTypeSwitchButton: UIButton!
    
    let pieChartsCollectionViewPeekDelegate = CollectionViewItemsPeekPresenter(cellSpacing: 10, cellPeekWidth: 50, maximumItemsToScroll: 1, numberOfItemsToShow: 1, scrollDirection: .horizontal)
    
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
    
    @IBAction func didTapLinePieChartSwitchButton(_ sender: Any) {
        lineChartView.clear()
        delegate?.didTapLinePieSwitchButton()
    }
    
    @IBAction func didTapAggregationTypeSwitchButton(_ sender: Any) {
        delegate?.didTapAggregationTypeButton()
    }
    
    private func setupUI() {
        setupLineChart()
        setupPieChartsCollectionView()
        setupButtons()
    }
    
    private func setupButtons() {
        graphTypeSwitchButton.setImageToRight()
        graphScaleSwitchButton.setImageToRight()
        aggregationTypeSwitchButton.setImageToRight()
    }
    
    private func setupPieChartsCollectionView() {        
        pieChartsCollectionView.configureForPeekingDelegate()
        pieChartsCollectionView.delegate = pieChartsCollectionViewPeekDelegate
        pieChartsCollectionView.dataSource = self
        pieChartsCollectionViewPeekDelegate.contentOffsetDelegate = self
    }
    
    private func setupLineChart() {
        lineChartView.delegate = self
        
        lineChartView.leftAxis.enabled = true
        lineChartView.rightAxis.enabled = false
        lineChartView.noDataText = "Недостаточно данных"
        
        lineChartView.noDataFont = UIFont(name: "Rubik-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        lineChartView.leftAxis.labelFont = UIFont(name: "Rubik-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        lineChartView.xAxis.labelFont = UIFont(name: "Rubik-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        
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
        lineChartView.setViewPortOffsets(left: 0, top: 30, right: 0, bottom: 30)
        lineChartView.setDragOffsetX(lineChartView.frame.width / 2)
        
        lineChartView.xAxis.drawAxisLineEnabled = true
        lineChartView.xAxis.drawGridLinesEnabled = false
        
        lineChartView.xAxis.forceLabelsEnabled = true
        lineChartView.xAxis.labelPosition = .bottom
        
        lineChartView.drawBordersEnabled = false
        lineChartView.drawGridBackgroundEnabled = false
        
        lineChartView.legend.enabled = false
        
        lineChartView.renderer = LineChartAreasRenderer(dataProvider: lineChartView, animator: lineChartView.chartAnimator, viewPortHandler: lineChartView.viewPortHandler)

    }
    
    private func updateUI() {
        updateButtons()
        updateCurrentPositionMarker()
        updateDateFormatter()
        updateLineChart()
        updatePieChartsCollectionView()
    }
    
    private func updateButtons() {
        graphTypeSwitchButton.setTitle(viewModel?.graphType.title, for: .normal)
        graphScaleSwitchButton.setTitle(viewModel?.graphPeriodScale.title, for: .normal)
        aggregationTypeSwitchButton.setTitle(viewModel?.aggregationType.title, for: .normal)
        
        linePieSwitchButton.isHidden = viewModel?.linePieChartSwitchHidden ?? true
        
        if let imageName = viewModel?.linePieChartSwitchIconName {
            linePieSwitchButton.setImage(UIImage(named: imageName), for: .normal)
        }
    }
    
    private func updatePieChartsCollectionView() {
        pieChartsViewContainer.isHidden = viewModel?.pieChartHidden ?? true
        pieChartsCollectionView.reloadData()
        
        if let offset = viewModel?.pieChartsCollectionContentOffset {
            pieChartsCollectionView.setContentOffset(offset, animated: false)
        } else if let lastItemIndexPath = pieChartsCollectionView.indexPathForLastItem,
                  lastItemIndexPath.item > 0  {
            pieChartsCollectionView.scrollToItem(at: lastItemIndexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    private func updateCurrentPositionMarker() {
        currentPositionMarker.isHidden = viewModel?.isLineChartCurrentPositionMarkerHidden ?? true
    }
    
    private func updateDateFormatter() {
        guard   let viewModel = viewModel else { return }
        dateFormatter.dateFormat = viewModel.dateFormat
    }
    
    private func updateLineChart() {
        lineChartViewContainer.isHidden = viewModel?.lineChartHidden ?? false
        
        lineChartView.clear()
        lineChartView.leftAxis.resetCustomAxisMin()
        
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
        if viewModel?.lineChartCurrentPoint != currentPoint {
            viewModel?.lineChartCurrentPoint = currentPoint
            updateLineChartCurrentPointUI()
        }
        
    }
    
    private func updateLineChartCurrentPointUI() {
        delegate?.graphFiltersAndTotalUpdateNeeded()
    }
}

extension GraphTableViewCell : UICollectionViewDataSource, CollectionViewContentOffsetDelegate {
    func didChangeContentOffset(_ contentOffset: CGPoint) {
        viewModel?.pieChartsCollectionContentOffset = contentOffset
        viewModel?.currentPieChartIndex = pieChartsCollectionViewPeekDelegate.scrollView(pieChartsCollectionView, indexForItemAtContentOffset: contentOffset)
        delegate?.graphFiltersAndTotalUpdateNeeded()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfPieCharts ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PieChartCollectionViewCell", for: indexPath) as? PieChartCollectionViewCell,
            let pieChartViewModel = viewModel?.pieChartViewModel(at: indexPath) else {
                return UICollectionViewCell()
        }
        
        cell.viewModel = pieChartViewModel
        
        return cell
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

protocol CollectionViewContentOffsetDelegate {
    func didChangeContentOffset(_ contentOffset: CGPoint)
}

class CollectionViewItemsPeekPresenter : MSPeekCollectionViewDelegateImplementation {
    
    var contentOffsetDelegate: CollectionViewContentOffsetDelegate? = nil
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contentOffsetDelegate?.didChangeContentOffset(scrollView.contentOffset)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        contentOffsetDelegate?.didChangeContentOffset(scrollView.contentOffset)
    }
}
