//
//  FiltersSelectionViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 03/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import AlignedCollectionViewFlowLayout

protocol FiltersSelectionViewControllerDelegate {
    func didSelectFilters(dateRangeFilter: DateRangeTransactionFilter?, sourceOrDestinationFilters: [SourceOrDestinationTransactionFilter])
}

class FiltersSelectionViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable {
    
    var navigationBarTintColor: UIColor? = UIColor.by(.dark333D5B)
    
    var delegate: FiltersSelectionViewControllerDelegate? = nil
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: FiltersSelectionViewModel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        navigationController?.navigationBar.barTintColor = UIColor.by(.dark333D5B)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        delegate?.didSelectFilters(dateRangeFilter: viewModel.selectedDateRangeFilter,
                                   sourceOrDestinationFilters: viewModel.selectedFilters)
        closeButtonHandler()
    }
    
    func set(dateRangeFilter: DateRangeTransactionFilter?, sourceOrDestinationFilters: [SourceOrDestinationTransactionFilter]) {
        viewModel.set(dateRangeFilter: dateRangeFilter, sourceOrDestinationFilters: sourceOrDestinationFilters)
    }
}

protocol FromDateSelectionHandlerDelegate {
    func didSelectFromDate(date: Date?)
}

protocol ToDateSelectionHandlerDelegate {
    func didSelectToDate(date: Date?)
}

extension FiltersSelectionViewController : DateRangeCollectionViewCellDelegate, FromDateSelectionHandlerDelegate, ToDateSelectionHandlerDelegate {
    
    class FromDateSelectionHandler : DatePickerViewControllerDelegate {
        let delegate: FromDateSelectionHandlerDelegate
        
        init(delegate: FromDateSelectionHandlerDelegate) {
            self.delegate = delegate
        }
        
        func didSelect(date: Date?) {
            delegate.didSelectFromDate(date: date)
        }
    }
    
    class ToDateSelectionHandler : DatePickerViewControllerDelegate {
        let delegate: ToDateSelectionHandlerDelegate
        
        init(delegate: ToDateSelectionHandlerDelegate) {
            self.delegate = delegate
        }
        
        func didSelect(date: Date?) {
            delegate.didSelectToDate(date: date)
        }
    }
    
    func didTapFromDate() {
        showDatePicker(date: viewModel.fromDate,
                       minDate: nil,
                       maxDate: viewModel.fromDateMaxDate,
                       delegate: FromDateSelectionHandler(delegate: self))
    }
    
    func didTapToDate() {
        showDatePicker(date: viewModel.toDate,
                       minDate: viewModel.toDateMinDate,
                       maxDate: nil,
                       delegate: ToDateSelectionHandler(delegate: self))
    }
    
    func didSelectFromDate(date: Date?) {
        viewModel.fromDate = date
        updateUI()
    }
    
    func didSelectToDate(date: Date?) {
        viewModel.toDate = date
        updateUI()
    }
        
    private func showDatePicker(date: Date?, minDate: Date?, maxDate: Date?, delegate: DatePickerViewControllerDelegate) {
        let datePickerController = DatePickerViewController()
        datePickerController.set(delegate: delegate)
        datePickerController.set(date: date, minDate: minDate, maxDate: maxDate)
        datePickerController.modalPresentationStyle = .custom
        present(datePickerController, animated: true, completion: nil)
    }
}


extension FiltersSelectionViewController {
    private func setupUI() {
        setupNavigationBar()
        setupCollectionView()
        setupActivityIndicator()
    }
    
    private func setupNavigationBar() {
        setupNavigationBarAppearance()
        navigationItem.title = "Фильтры"
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let alignedFlowLayout = collectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.horizontalAlignment = .left
        alignedFlowLayout?.verticalAlignment = .top
    }
    
    private func setupActivityIndicator() {
        activityIndicator.showLoader()
    }
    
    private func updateUI() {
        collectionView.reloadData()
    }
    
    private func loadData() {
        set(activityIndicator, hidden: false)
        firstly {
            viewModel.loadFilters()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки фильтров", theme: .error)
        }.finally {
            self.set(self.activityIndicator, hidden: true)
            self.updateUI()
        }
    }
}

extension FiltersSelectionViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(index: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let section = viewModel.section(at: indexPath.section) else { return UICollectionViewCell() }
        
        func dequeueCell(for identifier: String) -> UICollectionViewCell {
            return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        }
        
        switch section {
        case is DateRangeFilterSection:
            guard let cell = dequeueCell(for: "DateRangeCollectionViewCell") as? DateRangeCollectionViewCell else { return UICollectionViewCell() }
            
            cell.configure(with: self, fromDate: viewModel.fromDate, toDate: viewModel.toDate)
            
            return cell
        case is SourceOrDestinationTransactionFiltersSection:
            guard   let cell = dequeueCell(for: "SelectableFilterCollectionViewCell") as? SelectableFilterCollectionViewCell,
                let filtersSection = section as? SourceOrDestinationTransactionFiltersSection,
                let filterViewModel = filtersSection.filterViewModel(at: indexPath.row) else { return UICollectionViewCell() }
            
            cell.viewModel = filterViewModel
            
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let section = viewModel.section(at: indexPath.section) else { return CGSize.zero }
        
        switch section {
        case is DateRangeFilterSection:
            return CGSize(width: collectionView.frame.size.width - 32.0, height: 28.0)
        case is SourceOrDestinationTransactionFiltersSection:
            guard   let filtersSection = section as? SourceOrDestinationTransactionFiltersSection,
                    let filter = filtersSection.filterViewModel(at: indexPath.row) else { return CGSize.zero }
            
            let titleSize = filter.title.size(withAttributes: [
                NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 13.0) ?? UIFont.boldSystemFont(ofSize: 13)
                ])
            let edgeInsets = UIEdgeInsets(top: 5.0, left: 6.0, bottom: 3.0, right: 10.0)
            return CGSize(width: titleSize.width + edgeInsets.horizontal, height: 24.0)
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard   let filtersSection = viewModel.section(at: indexPath.section) as? SourceOrDestinationTransactionFiltersSection,
                let filter = filtersSection.filterViewModel(at: indexPath.row) else { return }
        
        filter.toggle()
        collectionView.reloadItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard   let section = viewModel.section(at: indexPath.section),
                kind == UICollectionView.elementKindSectionHeader,
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FiltersSelectionSectionHeaderView", for: indexPath) as? FiltersSelectionSectionHeaderView else {
                    
                    return UICollectionReusableView()
                    
        }
        
        headerView.titleLabel.text = section.title
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 60.0)
    }
}
