//
//  SettingsTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol SettingsTableControllerDelegate {
    func didAppear()
    func didTapCurrency()
    func didTapPeriod()
    func didChange(soundsOn: Bool)
    func didRefresh()
}

class SettingsTableController : FormFieldsTableViewController {
    
    @IBOutlet weak var currencyField: FormTapField!
    @IBOutlet weak var periodField: FormTapField!
    @IBOutlet weak var soundsSwitchField: FormSwitchValueField!
    private var loaderView: LoaderView!
    
    var delegate: SettingsTableControllerDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        delegate?.didAppear()
    }
    
    override func setupUI() {
        super.setupUI()
        setupCurrencyField()
        setupPeriodField()
        setupSoundsSwitchField()
        setupRefreshControl()
    }
    
    override func showActivityIndicator() {
        refreshControl?.beginRefreshing(in: tableView, animated: true)
        tableView.isUserInteractionEnabled = false
    }
    
    override func hideActivityIndicator(animated: Bool = false, reload: Bool = true) {
        refreshControl?.endRefreshing()
        tableView.isUserInteractionEnabled = true
    }
    
    private func setupCurrencyField() {
        currencyField.placeholder = "Валюта"
        currencyField.imageName = "currency-icon"
        currencyField.didTap { [weak self] in
            self?.delegate?.didTapCurrency()
        }
    }
    
    private func setupPeriodField() {
        periodField.placeholder = "Период"
        periodField.imageName = "period-icon"
        periodField.didTap { [weak self] in
            self?.delegate?.didTapPeriod()
        }
    }
    
    private func setupSoundsSwitchField() {
        soundsSwitchField.placeholder = "Звуки создания транзакций"
        soundsSwitchField.imageName = "sounds-icon"
        soundsSwitchField.didSwitch { [weak self] soundsOn in
            self?.delegate?.didChange(soundsOn: soundsOn)
        }
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = .clear
        refreshControl?.tintColor = .clear
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        if let objOfRefreshView = Bundle.main.loadNibNamed("LoaderView",
                                                           owner: self,
                                                           options: nil)?.first as? LoaderView,
            let refreshControl = refreshControl {
            
            loaderView = objOfRefreshView
            loaderView.imageView.showLoader()
            loaderView.frame = refreshControl.frame
            refreshControl.removeSubviews()
            refreshControl.addSubview(loaderView)
        }
    }
    
    @objc func refreshData() {
        delegate?.didRefresh()
    }
}

