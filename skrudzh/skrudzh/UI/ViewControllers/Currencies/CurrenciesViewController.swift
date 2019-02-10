//
//  CurrenciesViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 10/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import PromiseKit

protocol CurrenciesViewControllerDelegate {
    func didSelectCurrency(currency: Currency)
}

protocol CurrenciesViewControllerInputProtocol {
    func set(delegate: CurrenciesViewControllerDelegate)
}

class CurrenciesViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    @IBOutlet weak var currenciesCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIView!
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    private var pagedCollectionViewLayout: PagedCollectionViewLayout? {
        return currenciesCollectionView.collectionViewLayout as? PagedCollectionViewLayout
    }
    
    
    var viewModel: CurrenciesViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    var delegate: CurrenciesViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.showLoader()
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutUI()
    }
    
    private func loadData() {
        set(activityIndicator, hidden: false)
        firstly {
            viewModel.loadCurrencies()
        }.done {
            self.updateUI()
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки валют", theme: .error)
        }.finally {
            self.set(self.activityIndicator, hidden: true)
        }
    }
    
    private func updateUI() {
        updatePageControl()
        update(currenciesCollectionView)
    }
    
    func updatePageControl() {
        guard let pagedCollectionViewLayout = pagedCollectionViewLayout else {
            pageControl.isHidden = true
            return
        }
        let pagesCount = pagedCollectionViewLayout.numberOfPages
        pageControl.numberOfPages = pagesCount
        pageControl.isHidden = pagesCount <= 1
    }
    
    private func layoutUI() {
        if let layout = currenciesCollectionView.collectionViewLayout as? PagedCollectionViewLayout {
            layout.itemSize = CGSize(width: 64, height: 85)
            layout.columns = 4
            layout.rows = Int(currenciesCollectionView.bounds.size.height / layout.itemSize.height)
            layout.edgeInsets = UIEdgeInsets(horizontal: 30, vertical: 5)
        }
    }
}

extension CurrenciesViewController : CurrenciesViewControllerInputProtocol {
    func set(delegate: CurrenciesViewControllerDelegate) {
        self.delegate = delegate
    }
}

extension CurrenciesViewController : UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCurrencies
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = currenciesCollectionView.dequeueReusableCell(withReuseIdentifier: "CurrencyCollectionViewCell",
                                                                 for: indexPath) as? CurrencyCollectionViewCell,
            let currencyViewModel = viewModel.currencyViewModel(at: indexPath) else {
                
                return UICollectionViewCell()
        }
        
        cell.viewModel = currencyViewModel
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if  let selectedCurrency = viewModel.currencyViewModel(at: indexPath)?.currency {
            
            delegate?.didSelectCurrency(currency: selectedCurrency)
            navigationController?.popViewController(animated: true)
        }
    }
}
