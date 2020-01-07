//
//  EntityInfoNavigationController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 20.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class EntityInfoNavigationController : UINavigationController, UIFactoryDependantProtocol, UIMessagePresenterManagerDependantProtocol, IconInfoTableViewCellDelegate, SwitchInfoTableViewCellDelegate, ButtonInfoTableViewCellDelegate, ReminderInfoTableViewCellDelegate {
    
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var factory: UIFactoryProtocol!
    
    var entityInfoViewModel: EntityInfoViewModel! {
        return nil
    }
    
    var entityInfoViewController: EntityInfoViewController? {
        return viewControllers.first as? EntityInfoViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entityInfoViewController?.viewModel = entityInfoViewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavBarUI()
    }
    
    func updateNavBarUI() {
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor.by(.black2)
    }
    
    func save() {
        entityInfoViewController?.saveData()
    }
    
    func refreshData() {
        entityInfoViewController?.postFinantialDataUpdated()
    }
        
    func showEditScreen() {
        
    }
    
    func didTapIcon(field: IconInfoField?) {
        
    }
    
    func didSwitch(field: SwitchInfoField?) {
        
    }
    
    func didTapInfoButton(field: ButtonInfoField?) {
        
    }
    
    func didTapReminderButton(field: ReminderInfoField?) {
        
    }
}
