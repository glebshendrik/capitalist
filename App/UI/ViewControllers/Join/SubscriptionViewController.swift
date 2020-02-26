//
//  SubscriptionViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26.02.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import InfiniteLayout
import ApphudSDK

class FeatureDescriptionCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    
}

typealias ProductViewContainer = (background: UIView, sign: UIImageView, title: UILabel, subtitle: UILabel)

class SubscriptionViewController : FormFieldsTableViewController {
    
    @IBOutlet weak var featuresCollectionView: InfiniteCollectionView!
    @IBOutlet weak var featuresPageControl: UIPageControl!
    
    @IBOutlet weak var firstProductBackground: UIView!
    @IBOutlet weak var firstProductSelectedSign: UIImageView!
    @IBOutlet weak var firstProductTitleLabel: UILabel!
    @IBOutlet weak var firstProductSubtitleLabel: UILabel!
    
    @IBOutlet weak var secondProductBackground: UIView!
    @IBOutlet weak var secondProductSelectedSign: UIImageView!
    @IBOutlet weak var secondProductTitleLabel: UILabel!
    @IBOutlet weak var secondProductSubtitleLabel: UILabel!
    
    @IBOutlet weak var thirdProductBackground: UIView!
    @IBOutlet weak var thirdProductSelectedSign: UIImageView!
    @IBOutlet weak var thirdProductTitleLabel: UILabel!
    @IBOutlet weak var thirdProductSubtitleLabel: UILabel!
    
    @IBOutlet weak var firstProductCell: UITableViewCell!
    @IBOutlet weak var secondProductCell: UITableViewCell!
    @IBOutlet weak var thirdProductCell: UITableViewCell!
    
    private var productContainers: [SubscriptionProductId : ProductViewContainer] = [:]
    
    override func setupUI() {
        super.setupUI()
        setupFeaturesUI()
        setupProductsUI()
        Apphud.didFetchProductsNotification()
    }
    
    private func setupFeaturesUI() {
        featuresCollectionView.delegate = self
        featuresCollectionView.dataSource = self
    }
    
    private func setupProductsUI() {
        productContainers = [.first : (background: firstProductBackground,
                                       sign: firstProductSelectedSign,
                                       title: firstProductTitleLabel,
                                       subtitle: firstProductSubtitleLabel),
                             .second : (background: secondProductBackground,
                                        sign: secondProductSelectedSign,
                                        title: secondProductTitleLabel,
                                        subtitle: secondProductSubtitleLabel),
                             .third : (background: thirdProductBackground,
                                       sign: thirdProductSelectedSign,
                                       title: thirdProductTitleLabel,
                                       subtitle: thirdProductSubtitleLabel)]
    }
    
    private func setProductBy(_ id: SubscriptionProductId, selected: Bool) {
        productContainers[id]?.background.backgroundColor = selected ? UIColor.by(.blue1) : UIColor.by(.white12)
        productContainers[id]?.sign.isHidden = !selected
    }
    
    private func updateProductBy(_ id: SubscriptionProductId, title: String, subtitle: String) {
        productContainers[id]?.title.text = title
        productContainers[id]?.subtitle.text = subtitle
    }
    
    @IBAction func didTapFirstProduct(_ sender: Any) {
        setProductBy(.first, selected: true)
        setProductBy(.second, selected: false)
        setProductBy(.third, selected: false)
    }
    
    @IBAction func didTapSecondProduct(_ sender: Any) {
        setProductBy(.first, selected: false)
        setProductBy(.second, selected: true)
        setProductBy(.third, selected: false)
    }
    
    @IBAction func didTapThirdProduct(_ sender: Any) {
        setProductBy(.first, selected: false)
        setProductBy(.second, selected: false)
        setProductBy(.third, selected: true)
    }
    
    @IBAction func didTapContinueButton(_ sender: Any) {
    }
    
    @IBAction func didTapRestoreButton(_ sender: Any) {
    }
    
    @IBAction func didTapTermsButton(_ sender: Any) {
    }
    
    @IBAction func didTapPrivacyButton(_ sender: Any) {
    }
}

extension SubscriptionViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
//        guard let section = viewModel.section(at: indexPath.section) else { return UICollectionViewCell() }
//        
//        func dequeueCell(for identifier: String) -> UICollectionViewCell {
//            return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
//        }
//        
//        switch section {
//        case is TransactionableFiltersSection:
//            guard   let cell = dequeueCell(for: "SelectableFilterCollectionViewCell") as? SelectableFilterCollectionViewCell,
//                let filtersSection = section as? TransactionableFiltersSection,
//                let filterViewModel = filtersSection.filterViewModel(at: indexPath.row) else { return UICollectionViewCell() }
//            
//            cell.viewModel = filterViewModel
//            
//            return cell
//        default:
//            return UICollectionViewCell()
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: 56.0)
    }
    
}
