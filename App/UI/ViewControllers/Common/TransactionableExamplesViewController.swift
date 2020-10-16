//
//  TransactionableExamplesViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 15.10.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol TransactionableExamplesViewControllerDelegate : class {
    func didSelect(exampleViewModel: TransactionableExampleViewModel)
}

class TransactionableExamplesViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {

    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: TransactionableExamplesViewModel!
    
    weak var delegate: TransactionableExamplesViewControllerDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var examplesCollectionView: UICollectionView!
    @IBOutlet weak var examplesActivityIndicator: UIView!
    @IBOutlet weak var loader: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        loadData()
    }
    
    func setupUI() {
        setupActivityIndicator()
        setupExamplesCollectionView()
    }
    
    func setupActivityIndicator() {
        loader.showLoader()
    }
    
    func setupExamplesCollectionView() {
        examplesCollectionView.delegate = self
        examplesCollectionView.dataSource = self
        examplesCollectionView.fillLayout(columns: 4,
                                          itemHeight: 110,
                                          horizontalInset: 16,
                                          verticalInset: 0,
                                          fillVertically: false)
    }
    
    func updateUI() {
        updateCollectionUI()
    }
        
    func updateCollectionUI() {
        examplesCollectionView.reloadData()
    }
    
    func loadData() {
        set(examplesActivityIndicator, hidden: false)
        firstly {
            viewModel.loadData()
        }.catch { e in
            print(e)
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки данных", comment: "Ошибка загрузки данных"), theme: .error)
        }.finally {
            self.updateUI()
            self.set(self.examplesActivityIndicator, hidden: true)
        }
    }
}

extension TransactionableExamplesViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfExamples
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = examplesCollectionView.dequeueReusableCell(withReuseIdentifier: "TransactionableExampleCollectionViewCell",
                                                                  for: indexPath) as? TransactionableExampleCollectionViewCell
        else {            
            return UICollectionViewCell()
        }
        cell.viewModel = viewModel.exampleViewModel(by: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let exampleViewModel = viewModel.exampleViewModel(by: indexPath)
        else {
            return
        }
        delegate?.didSelect(exampleViewModel: exampleViewModel)
        dismiss(animated: true, completion: nil)
    }
}
