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
import PromiseKit
import SafariServices

class FeatureDescriptionCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
}

typealias ProductViewContainer = (background: UIView, sign: UIImageView, title: UILabel, subtitle: UILabel, cell: UITableViewCell)

class SubscriptionViewController : FormFieldsTableViewController, ApplicationRouterDependantProtocol, UIMessagePresenterManagerDependantProtocol, UIFactoryDependantProtocol {
    
    var router: ApplicationRouterProtocol!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var factory: UIFactoryProtocol!
    var viewModel: SubscriptionViewModel!
    
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
        setupNavigationBarAppearance()
        setupFeaturesUI()
        setupProductsUI()
        setupNotifications()
        loadData()
    }
    
    @IBAction func didTapFirstProduct(_ sender: Any) {
        viewModel.selectedProductId = .first
        updateUI()
    }
    
    @IBAction func didTapSecondProduct(_ sender: Any) {
        viewModel.selectedProductId = .second
        updateUI()
    }
    
    @IBAction func didTapThirdProduct(_ sender: Any) {
        viewModel.selectedProductId = .third
        updateUI()
    }
    
    @IBAction func didTapContinueButton(_ sender: Any) {
        purchase()
    }
    
    @IBAction func didTapRestoreButton(_ sender: Any) {
        restore()
    }
    
    @IBAction func didTapTermsButton(_ sender: Any) {
        show("http://threebaskets.net/policy.html")
    }
    
    @IBAction func didTapPrivacyButton(_ sender: Any) {
        show("http://threebaskets.net/policy.html")
    }
    
    @objc private func loadData() {
        viewModel.updateProducts()
        updateUI(reload: false)
        showActivityIndicator()
        _ = firstly {
                viewModel.checkIntroductoryEligibility()
            }.ensure {
                self.updateUI(reload: false)
                self.hideActivityIndicator()
            }
    }
    
    private func purchase() {
        showActivityIndicator()
        _ = firstly {
                viewModel.purchase()
            }.done {
                if self.isModal {
                    self.closeButtonHandler()
                }
                else {
                    self.navigationController?.popViewController()
                }
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Подписка оформлена! Теперь у вас неограниченный доступ!", comment: ""), theme: .success, duration: .normal)
            }.catch { error in
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Невозможно оформить подписку", comment: ""), theme: .error, duration: .short)
            }.finally {
                self.hideActivityIndicator()
            }
    }
    
    private func restore() {
        showActivityIndicator()
        _ = firstly {
                viewModel.restore()
            }.done {
                if self.isModal {
                    self.closeButtonHandler()
                }
                else {
                    self.navigationController?.popViewController()
                }
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Подписка восстановлена! Теперь у вас снова неограниченный доступ!", comment: ""), theme: .success, duration: .normal)
            }.catch { error in
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Невозможно восстановить подписку", comment: ""), theme: .error, duration: .short)
            }.finally {
                self.hideActivityIndicator()
            }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: Apphud.didFetchProductsNotification(), object: nil)
    }
    
    private func setupFeaturesUI() {
        featuresCollectionView.delegate = self
        featuresCollectionView.dataSource = self
        featuresCollectionView.isItemPagingEnabled = true
        featuresPageControl.numberOfPages = viewModel.numberOfFeatureDescriptions
        scheduledCarouselTimerWithTimeInterval()
    }
    
    private func scheduledCarouselTimerWithTimeInterval() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            self?.showNextFeatureDescription()
        }
    }
    
    @objc private func showNextFeatureDescription() {
        
        guard var currentPage = featuresCollectionView.centeredIndexPath?.row else { return }
        if currentPage > featuresCollectionView.numberOfItems(inSection: 0) - 2 {
           currentPage = 0
        } else {
           currentPage = currentPage + 1
        }
        featuresCollectionView.scrollToItem(at: IndexPath(item: currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    private func setupProductsUI() {
        productContainers = [.first : (background: firstProductBackground,
                                       sign: firstProductSelectedSign,
                                       title: firstProductTitleLabel,
                                       subtitle: firstProductSubtitleLabel,
                                       cell: firstProductCell),
                             .second : (background: secondProductBackground,
                                        sign: secondProductSelectedSign,
                                        title: secondProductTitleLabel,
                                        subtitle: secondProductSubtitleLabel,
                                        cell: secondProductCell),
                             .third : (background: thirdProductBackground,
                                       sign: thirdProductSelectedSign,
                                       title: thirdProductTitleLabel,
                                       subtitle: thirdProductSubtitleLabel,
                                       cell: thirdProductCell)]
    }
    
    private func updateUI(reload: Bool = true) {
        updateProductUI(by: .first)
        updateProductUI(by: .second)
        updateProductUI(by: .third)
        if reload {
            updateTable()
        }
    }
    
    private func updateProductUI(by id: SubscriptionProductId) {
        guard let productContainer = productContainers[id] else { return }
        guard let productViewModel = viewModel.productViewModel(by: id) else {
            set(cell: productContainer.cell, hidden: true, animated: false, reload: false)
            return
        }
        set(cell: productContainer.cell, hidden: false, animated: false, reload: false)
        setProductBy(id, selected: productViewModel.isSelected)
        updateProductBy(id, title: productViewModel.title, subtitle: productViewModel.subtitle)
    }
    
    private func setProductBy(_ id: SubscriptionProductId, selected: Bool) {
        productContainers[id]?.background.backgroundColor = selected ? UIColor.by(.blue1) : UIColor.by(.white12)
        productContainers[id]?.sign.isHidden = !selected
    }
    
    private func updateProductBy(_ id: SubscriptionProductId, title: String, subtitle: String) {
        productContainers[id]?.title.text = title
        productContainers[id]?.subtitle.text = subtitle
    }
    
    private func show(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let browser = SFSafariViewController(url: url)
        browser.modalPresentationStyle = .popover
        modal(browser)
    }
}

extension SubscriptionViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfFeatureDescriptions
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeatureDescriptionCollectionViewCell", for: featuresCollectionView.indexPath(from: indexPath)) as? FeatureDescriptionCollectionViewCell,
                let featureDescription = viewModel.featureDescription(by: featuresCollectionView.indexPath(from: indexPath)) else { return UICollectionViewCell() }
        
        cell.descriptionLabel.text = featureDescription
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        featuresPageControl.currentPage = featuresCollectionView.indexPath(from: indexPath).item
    }
}
