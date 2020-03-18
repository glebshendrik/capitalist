//
//  SettingsTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import BiometricAuthentication

protocol SettingsTableControllerDelegate {
    func didAppear()
    func didTapCurrency()
    func didTapPeriod()
    func didChange(soundsOn: Bool)
    func didChange(verificationEnabled: Bool)
    func didTapLanguage()
    func didRefresh()
}

class SettingsTableController : FormFieldsTableViewController {
    
    @IBOutlet weak var currencyField: FormTapField!
    @IBOutlet weak var periodField: FormTapField!
    @IBOutlet weak var soundsSwitchField: FormSwitchValueField!
    @IBOutlet weak var verificationSwitchField: FormSwitchValueField!
    @IBOutlet weak var languageField: FormTapField!
    @IBOutlet weak var verificationSwitchCell: UITableViewCell!
    
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
        setupLanguageField()
        setupVerificationSwitchField()
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
        currencyField.placeholder = NSLocalizedString("Валюта", comment: "Валюта")
        currencyField.imageName = "currency-icon"
        currencyField.didTap { [weak self] in
            self?.delegate?.didTapCurrency()
        }
    }
    
    private func setupPeriodField() {
        periodField.placeholder = NSLocalizedString("Период", comment: "Период")
        periodField.imageName = "period-icon"
        periodField.didTap { [weak self] in
            self?.delegate?.didTapPeriod()
        }
    }
    
    private func setupSoundsSwitchField() {
        soundsSwitchField.placeholder = NSLocalizedString("Звуки создания транзакций", comment: "Звуки создания транзакций")
        soundsSwitchField.imageName = "sounds-icon"
        soundsSwitchField.didSwitch { [weak self] soundsOn in
            self?.delegate?.didChange(soundsOn: soundsOn)
        }
    }
    
    private func setupLanguageField() {
        languageField.placeholder = NSLocalizedString("Язык", comment: "Язык")
        languageField.imageName = "currency-icon"
        languageField.didTap { [weak self] in
            self?.delegate?.didTapLanguage()
        }
    }
    
    private func setupVerificationSwitchField() {
        verificationSwitchField.placeholder = String.localizedStringWithFormat(NSLocalizedString("Вход по %@", comment: "Вход по %@"), BioMetricAuthenticator.shared.isFaceIdDevice() ? "Face ID" : "Touch ID")
        verificationSwitchField.imageName = "password-icon"
        verificationSwitchField.didSwitch { [weak self] verificationEnabled in
            self?.delegate?.didChange(verificationEnabled: verificationEnabled)
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

