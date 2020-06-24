//
//  CurrenciesViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol CurrenciesViewControllerDelegate : class {
    func didSelectCurrency(currency: Currency)
}

class CurrenciesViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    @IBOutlet weak var currenciesCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIView!
    @IBOutlet weak var loader: UIImageView!
    
    var viewModel: CurrenciesViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    weak var delegate: CurrenciesViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutUI()
    }
    
    func setupUI() {
        setupLoaderUI()
        setupNavigationBarUI()
    }
    
    func setupLoaderUI() {
        loader.showLoader()
    }
    
    func setupNavigationBarUI() {
        setupNavigationBarAppearance()        
        navigationItem.title = NSLocalizedString("Выберите валюту", comment: "Выберите валюту")
    }
        
    private func loadData() {
        set(activityIndicator, hidden: false)
        firstly {
            viewModel.loadCurrencies()
        }.done {
            self.updateUI()
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки валют", comment: "Ошибка загрузки валют"), theme: .error)
        }.finally {
            self.set(self.activityIndicator, hidden: true)
        }
    }
    
    private func updateUI() {
        update(currenciesCollectionView)
    }
        
    private func layoutUI() {
        currenciesCollectionView.fillLayout(columns: 1, itemHeight: 56, horizontalInset: 0, verticalInset: 0, fillVertically: false)
    }
}

extension CurrenciesViewController {
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
            closeButtonHandler()
        }
    }
}
