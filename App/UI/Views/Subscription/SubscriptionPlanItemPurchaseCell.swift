//
//  SubscriptionPlanItemPurchaseCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 18.09.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

typealias ProductViewContainer = (background: UIView, title: UILabel, subtitle: UILabel, titleContainer: UIView, subtitleContainer: UIView, delimiter: UIView, discountButton: UIButton)

protocol SubscriptionPlanItemPurchaseCellDelegate : class {
    func didTapPurchaseButton(product: ProductViewModel)
    func didChangeContent()
}

class SubscriptionPlanItemPurchaseCell : UITableViewCell {
    @IBOutlet weak var firstProductBackground: UIView!
    @IBOutlet weak var firstProductDiscountButton: UIButton!
    @IBOutlet weak var firstProductTitleLabel: UILabel!
    @IBOutlet weak var firstProductSubtitleLabel: UILabel!
    @IBOutlet weak var firstProductDelimeter: UIView!
    @IBOutlet weak var firstProductSubtitleContainer: UIView!
    @IBOutlet weak var firstProductTitleContainer: UIView!
    
    @IBOutlet weak var secondProductBackground: UIView!
    @IBOutlet weak var secondProductDiscountButton: UIButton!
    @IBOutlet weak var secondProductTitleLabel: UILabel!
    @IBOutlet weak var secondProductSubtitleLabel: UILabel!
    @IBOutlet weak var secondProductDelimeter: UIView!
    @IBOutlet weak var secondProductSubtitleContainer: UIView!
    @IBOutlet weak var secondProductTitleContainer: UIView!
    
    @IBOutlet weak var purchaseTitleLabel: UILabel!
    @IBOutlet weak var purchaseSubtitleLabel: UILabel!
    @IBOutlet weak var discountDescriptionLabel: UILabel!
    
    
    weak var delegate: SubscriptionPlanItemPurchaseCellDelegate?
    
    private var productContainers: [SubscriptionProduct : ProductViewContainer] = [:]

    
    var viewModel: PlanPurchaseItemViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    @IBAction func didTapFirstProduct(_ sender: Any) {
        viewModel?.selectedProduct = viewModel?.firstProduct
        updateUI()
        delegate?.didChangeContent()
    }
    
    @IBAction func didTapSecondProduct(_ sender: Any) {
        viewModel?.selectedProduct = viewModel?.secondProduct
        updateUI()
        delegate?.didChangeContent()
    }
        
    @IBAction func didTapContinueButton(_ sender: Any) {
        guard let product = viewModel?.selectedProductViewModel else { return }
        delegate?.didTapPurchaseButton(product: product)
    }
    
    func updateUI() {        
        updatePurchaseUI()
        updateDiscountDescriptionUI()
        updateProductsUI()
    }
    
    private func updatePurchaseUI() {
        purchaseTitleLabel.text = NSLocalizedString("Продолжить", comment: "")
        purchaseSubtitleLabel.text = viewModel?.selectedProductViewModel?.purchaseTitle
    }
    
    private func updateDiscountDescriptionUI() {
        discountDescriptionLabel.text = viewModel?.selectedProductViewModel?.discountDescription
    }
    
    private func updateProductsUI() {
        guard   let firstProduct = viewModel?.firstProduct,
                let secondProduct = viewModel?.secondProduct else { return }
        productContainers = [firstProduct : (background: firstProductBackground,
                                             title: firstProductTitleLabel,
                                             subtitle: firstProductSubtitleLabel,
                                             titleContainer: firstProductTitleContainer,
                                             subtitleContainer: firstProductSubtitleContainer,
                                             delimiter: firstProductDelimeter,
                                             discountButton: firstProductDiscountButton),
                             secondProduct : (background: secondProductBackground,
                                              title: secondProductTitleLabel,
                                              subtitle: secondProductSubtitleLabel,
                                              titleContainer: secondProductTitleContainer,
                                              subtitleContainer: secondProductSubtitleContainer,
                                              delimiter: secondProductDelimeter,
                                              discountButton: secondProductDiscountButton)]
        updateUI(product: firstProduct)
        updateUI(product: secondProduct)
    }
    
    private func updateUI(product: SubscriptionProduct) {
        guard let productViewModel = viewModel?.productViewModel(by: product) else {
            return
        }
        productContainers[product]?.background.borderColor = UIColor.by(.blue1)
        productContainers[product]?.background.borderWidth = productViewModel.isSelected ? 3.0 : 0.0
        productContainers[product]?.title.text = productViewModel.pricePerPeriod
        productContainers[product]?.subtitle.text = productViewModel.trialTitle
        productContainers[product]?.subtitleContainer.isHidden = !productViewModel.hasTrial
        productContainers[product]?.delimiter.isHidden = !productViewModel.hasTrial
        productContainers[product]?.discountButton.isHidden = !productViewModel.hasDiscount
        productContainers[product]?.discountButton.setTitle(productViewModel.discountTitle, for: .normal)
    }
    
}
