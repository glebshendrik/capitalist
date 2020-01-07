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
    func didSelect(filters: [TransactionableFilter])
}

class FiltersSelectionViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable {
    
    var navigationBarTintColor: UIColor? = UIColor.by(.black2)
    
    var delegate: FiltersSelectionViewControllerDelegate? = nil
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: FiltersSelectionViewModel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        navigationController?.navigationBar.barTintColor = UIColor.by(.black2)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        delegate?.didSelect(filters: viewModel.selectedFilters)
        closeButtonHandler()
    }
    
    @IBAction func didTapResetButton(_ sender: Any) {
        viewModel.resetFilters()
        updateUI()
        delegate?.didSelect(filters: viewModel.selectedFilters)
        closeButtonHandler()
    }
    
    func set(filters: [TransactionableFilter]) {
        viewModel.set(filters: filters)
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
        updateSaveButtonUI()
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
        case is TransactionableFiltersSection:
            guard   let cell = dequeueCell(for: "SelectableFilterCollectionViewCell") as? SelectableFilterCollectionViewCell,
                let filtersSection = section as? TransactionableFiltersSection,
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
        case is TransactionableFiltersSection:
            return CGSize(width: collectionView.frame.size.width, height: 56.0)
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard   let filtersSection = viewModel.section(at: indexPath.section) as? TransactionableFiltersSection,
                let filter = filtersSection.filterViewModel(at: indexPath.row) else { return }
        
        filter.toggle()
        collectionView.reloadItems(at: [indexPath])
        updateSaveButtonUI()
    }
    
    func updateSaveButtonUI() {
        saveButton.setTitle(viewModel.saveButtonTitle, for: .normal)
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
