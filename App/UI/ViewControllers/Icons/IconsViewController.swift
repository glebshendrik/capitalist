//
//  IconsViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol IconsViewControllerDelegate : class {
    func didSelectIcon(icon: Icon)
}

class IconsViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    @IBOutlet weak var iconsCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIView!
    @IBOutlet weak var loader: UIImageView!
    
    
    var viewModel: IconsViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    weak var delegate: IconsViewControllerDelegate?
    
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
        navigationItem.title = NSLocalizedString("Выберите иконку", comment: "Выберите иконку")
    }
        
    private func loadData() {
        set(activityIndicator, hidden: false)
        firstly {
            viewModel.loadIcons()
        }.done {
            self.updateUI()
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки иконок", comment: "Ошибка загрузки иконок"), theme: .error)
        }.finally {
            self.set(self.activityIndicator, hidden: true)
        }
    }
    
    private func updateUI() {
        update(iconsCollectionView)
    }
        
    private func layoutUI() {
        iconsCollectionView.fillLayout(columns: 4, itemHeight: 85, horizontalInset: 30, verticalInset: 5, fillVertically: false)
    }
}

extension IconsViewController {
    func set(delegate: IconsViewControllerDelegate) {
        self.delegate = delegate
    }
    
    func set(iconCategory: IconCategory) {
        viewModel.iconCategory = iconCategory
    }
}

extension IconsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfIcons
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = iconsCollectionView.dequeueReusableCell(withReuseIdentifier: "IconCollectionViewCell",
                                                                         for: indexPath) as? IconCollectionViewCell,
            let iconViewModel = viewModel.iconViewModel(at: indexPath) else {
                
                return UICollectionViewCell()
        }
        
        cell.viewModel = iconViewModel
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if  let selectedIcon = viewModel.iconViewModel(at: indexPath)?.icon {
            
            delegate?.didSelectIcon(icon: selectedIcon)
            closeButtonHandler()
        }
    }
}
