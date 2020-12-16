//
//  CardTypesViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12.05.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

protocol CardTypesViewControllerDelegate : class {
    func didSelect(cardType: CardType?)
}

class CardTypesViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deselectButton: UIButton!
    
    var viewModel: CardTypesViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    weak var delegate: CardTypesViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutUI()
    }
    
    @IBAction func didTapDeselectButton(_ sender: Any) {
        delegate?.didSelect(cardType: nil)
        closeButtonHandler()
    }
    
    func setupUI() {
        setupNavigationBarUI()
        setupDeselectButtonUI()
    }

    func setupNavigationBarUI() {
        setupNavigationBarAppearance()
        navigationItem.title = NSLocalizedString("Выберите тип карты", comment: "")
    }
    
    func setupDeselectButtonUI() {
        deselectButton.setTitle(NSLocalizedString("Снять выбор", comment: ""), for: .normal)
    }
    
    private func updateUI() {
        update(collectionView)
    }
        
    private func layoutUI() {
        collectionView.fillLayout(columns: 4, itemHeight: 85, horizontalInset: 30, verticalInset: 5, fillVertically: false)
    }
}

extension CardTypesViewController {
    func set(delegate: CardTypesViewControllerDelegate) {
        self.delegate = delegate
    }
}

extension CardTypesViewController : UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardTypeCollectionViewCell",
                                                                         for: indexPath) as? CardTypeCollectionViewCell,
                let cardTypeViewModel = viewModel.cardTypeViewModel(at: indexPath) else {
                
                return UICollectionViewCell()
        }
        
        cell.viewModel = cardTypeViewModel
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if  let selectedCardType = viewModel.cardTypeViewModel(at: indexPath)?.cardType {
            delegate?.didSelect(cardType: selectedCardType)
            closeButtonHandler()
        }
    }
}
