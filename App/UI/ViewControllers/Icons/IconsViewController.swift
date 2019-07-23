//
//  IconsViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol IconsViewControllerDelegate {
    func didSelectIcon(icon: Icon)
}

class IconsViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    @IBOutlet weak var iconsCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIView!
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    private var pagedCollectionViewLayout: PagedCollectionViewLayout? {
        return iconsCollectionView.collectionViewLayout as? PagedCollectionViewLayout
    }
    
    
    var viewModel: IconsViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    var delegate: IconsViewControllerDelegate?
    
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
            viewModel.loadIcons()
        }.done {
            self.updateUI()
        }
        .catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки иконок", theme: .error)
        }.finally {
            self.set(self.activityIndicator, hidden: true)
        }
    }
    
    private func updateUI() {
        updatePageControl()
        update(iconsCollectionView)
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
        if let layout = iconsCollectionView.collectionViewLayout as? PagedCollectionViewLayout {
            layout.itemSize = CGSize(width: 64, height: 85)
            layout.columns = 4
            layout.rows = Int(iconsCollectionView.bounds.size.height / layout.itemSize.height)
            layout.edgeInsets = UIEdgeInsets(horizontal: 30, vertical: 5)
        }
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
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
