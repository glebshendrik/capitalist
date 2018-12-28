//
//  IconsViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import PromiseKit

protocol IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon)
}

protocol IconsViewControllerInputProtocol {
    func set(iconCategory: IconCategory)
    func set(delegate: IconsViewControllerDelegate)
}

class IconsViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    @IBOutlet weak var iconsCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIView!
    @IBOutlet weak var loader: UIImageView!
    
    var viewModel: IconsViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    var delegate: IconsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.showLoader()
        loadData()
    }
    
    private func loadData() {
        set(activityIndicator, hidden: false)
        firstly {
            viewModel.loadIcons()
        }.done {
            self.update(self.iconsCollectionView)
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки иконок", theme: .error)
        }.finally {
            self.set(self.activityIndicator, hidden: true)
        }
    }
}

extension IconsViewController : IconsViewControllerInputProtocol {
    func set(delegate: IconsViewControllerDelegate) {
        self.delegate = delegate
    }
    
    func set(iconCategory: IconCategory) {
        viewModel.iconCategory = iconCategory
    }
}

extension IconsViewController : UICollectionViewDelegate, UICollectionViewDataSource {
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
            navigationController?.popViewController(animated: true)
        }
    }
}
