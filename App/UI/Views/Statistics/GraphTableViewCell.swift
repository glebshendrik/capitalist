//
//  GraphTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import Charts
import MSPeekCollectionViewDelegateImplementation
import BetterSegmentedControl

protocol GraphTableViewCellDelegate {
    func didTapGraphTypeButton()
    func didChangeRange()
}

class GraphTableViewCell : UITableViewCell {
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!    
    @IBOutlet weak var pieChartsViewContainer: UIView!
    @IBOutlet weak var pieChartsCollectionView: UICollectionView!
    @IBOutlet weak var pieChartsNoDataLabel: UILabel!
    @IBOutlet weak var tabs: BetterSegmentedControl!
    private var tabsInitialized: Bool = false
    
    let pieChartsCollectionViewPeekDelegate = CollectionViewItemsPeekPresenter(cellSpacing: 30, cellPeekWidth: 30, maximumItemsToScroll: 1, numberOfItemsToShow: 1, scrollDirection: .horizontal)
    
    var delegate: GraphTableViewCellDelegate?
    
    private lazy var dateFormatter: DateFormatter = {
        return DateFormatter()
    }()
    
    var viewModel: GraphViewModel? = nil {
        didSet {
            setupTabs()
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        updateUI()
    }
                
    @IBAction func didChangeGraphTab(_ sender: Any) {
        viewModel?.setGraphType(by: tabs.index)
        delegate?.didTapGraphTypeButton()
    }
    
    private func setupUI() {
        setupPieChartsCollectionView()
    }
    
    private func setupTabs() {
        guard !tabsInitialized else { return }
        tabs.segments = LabelSegment.segments(withTitles: [NSLocalizedString("ВСЕ", comment: "ВСЕ"),
                                                           NSLocalizedString("ДОХОД", comment: "ДОХОД"),
                                                           NSLocalizedString("РАСХОДЫ", comment: "РАСХОДЫ")],
                                              normalBackgroundColor: UIColor.clear,
                                              normalFont: UIFont(name: "Roboto-Regular", size: 12)!,
                                              normalTextColor: UIColor.by(.white100),
                                              selectedBackgroundColor: UIColor.by(.white12),
                                              selectedFont: UIFont(name: "Roboto-Regular", size: 12)!,
                                              selectedTextColor: UIColor.by(.white100))
        tabs.addTarget(self, action: #selector(didChangeGraphTab(_:)), for: .valueChanged)
        tabsInitialized = true
    }
    
    private func setupPieChartsCollectionView() {        
        pieChartsCollectionView.configureForPeekingDelegate()
        pieChartsCollectionView.delegate = pieChartsCollectionViewPeekDelegate
        pieChartsCollectionView.dataSource = self
        pieChartsCollectionViewPeekDelegate.contentOffsetDelegate = self
    }
    
    private func updateUI() {
        updateTabs()
        updateLabels()
        updatePieChartsCollectionView()
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    private func updateTabs() {
        tabs.setIndex(viewModel?.graphTypeIndex ?? 0, animated: true)
    }
    
    private func updateLabels() {
        UIView.transition(with: totalLabel,
             duration: 0.25,
              options: .transitionCrossDissolve,
           animations: { [weak self] in
               self?.totalLabel.text = self?.viewModel?.total
               self?.subtitleLabel.text = self?.viewModel?.subtitle
        }, completion: nil)
    }
    
    private func updatePieChartsCollectionView() {
        pieChartsNoDataLabel.isHidden = viewModel?.hasData ?? true
        pieChartsCollectionView.reloadData()
        
        if let offset = viewModel?.collectionContentOffset {
            pieChartsCollectionView.setContentOffset(offset, animated: false)
        } else if let lastItemIndexPath = pieChartsCollectionView.indexPathForLastItem,
                  lastItemIndexPath.item > 0  {
            pieChartsCollectionView.scrollToItem(at: lastItemIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

extension GraphTableViewCell : UICollectionViewDataSource, CollectionViewContentOffsetDelegate {
    func didChangeContentOffset(_ contentOffset: CGPoint) {
        guard let viewModel = viewModel else { return }
        
        viewModel.collectionContentOffset = contentOffset
        let newIndex = pieChartsCollectionViewPeekDelegate.scrollView(pieChartsCollectionView, indexForItemAtContentOffset: contentOffset)
        if viewModel.currentChartIndex != newIndex {
            viewModel.set(chartIndex: newIndex)
            delegate?.didChangeRange()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfGraphs ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PieChartCollectionViewCell", for: indexPath) as? PieChartCollectionViewCell,
            let viewModel = viewModel else {
                return UICollectionViewCell()
        }
        
        if indexPath.item == viewModel.currentChartIndex {
            cell.set(chartData: viewModel.pieChartData)
            updateLabels()
        }
        else {
            cell.set(chartData: viewModel.emptyChartData)
        }
        
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
    
    private func format(value: Double) -> String {
        
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
