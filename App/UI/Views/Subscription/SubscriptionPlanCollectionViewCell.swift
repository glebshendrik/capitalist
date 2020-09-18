//
//  SubscriptionPlanCollectionViewCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 18.09.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

class SubscriptionPlanCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: SubscriptionPlanViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SubscriptionPlanCollectionViewCell : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfPlanItems ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let itemViewModel = viewModel?.planItemViewModel(by: indexPath) else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: itemViewModel.cellIdentifier, for: indexPath)
        
        switch itemViewModel {
        case let titleCell as SubscriptionPlanItemTitleCell:
            configure(titleCell, withViewModel: itemViewModel as? PlanTitleItemViewModel)
        case let descriptionCell as SubscriptionPlanItemDescriptionCell:
            configure(descriptionCell, withViewModel: itemViewModel as? PlanDescriptionItemViewModel)
        case let purchaseCell as SubscriptionPlanItemPurchaseCell:
            configure(purchaseCell, withViewModel: itemViewModel as? PlanPurchaseItemViewModel)
        case let freeCell as SubscriptionPlanItemFreeCell:
            configure(freeCell, withViewModel: itemViewModel as? PlanFreeItemViewModel)
        case let featureCell as SubscriptionPlanItemFeatureCell:
            configure(featureCell, withViewModel: itemViewModel as? PlanFeatureItemViewModel)
        default:
            return cell
        }
        
        return cell
    }
    
    func configure(_ cell: SubscriptionPlanItemTitleCell, withViewModel viewModel: PlanTitleItemViewModel?) {
        guard let viewModel = viewModel else { return }
        cell.viewModel = viewModel
    }
    
    func configure(_ cell: SubscriptionPlanItemDescriptionCell, withViewModel viewModel: PlanDescriptionItemViewModel?) {
        guard let viewModel = viewModel else { return }
        cell.viewModel = viewModel
    }
    
    func configure(_ cell: SubscriptionPlanItemPurchaseCell, withViewModel viewModel: PlanPurchaseItemViewModel?) {
        guard let viewModel = viewModel else { return }
        cell.viewModel = viewModel
        cell.delegate = self
    }
    
    func configure(_ cell: SubscriptionPlanItemFreeCell, withViewModel viewModel: PlanFreeItemViewModel?) {
        guard let viewModel = viewModel else { return }
        cell.viewModel = viewModel
        cell.delegate = self
    }
    
    func configure(_ cell: SubscriptionPlanItemFeatureCell, withViewModel viewModel: PlanFeatureItemViewModel?) {
        guard let viewModel = viewModel else { return }
        cell.viewModel = viewModel
    }
    
    func configure(_ cell: SubscriptionPlanItemInfoCell, withViewModel viewModel: PlanInfoItemViewModel?) {
        guard let viewModel = viewModel else { return }
        cell.viewModel = viewModel
        cell.delegate = self
    }
}
