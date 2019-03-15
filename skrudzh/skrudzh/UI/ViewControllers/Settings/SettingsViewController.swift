//
//  SettingsViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 07/02/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import PromiseKit
import StaticDataTableViewController

class SettingsViewController : StaticDataTableViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable {
    
    var navigationBarTintColor: UIColor? = UIColor.navBarColor
    
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: SettingsViewModel!
    
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var playSoundsSwitch: UISwitch!
    
    private var loaderView: LoaderView!
    
    var user: User? {
        return viewModel.user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        refreshData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "showCurrenciesScreen",
            let destination = segue.destination as? CurrenciesViewControllerInputProtocol {
            
            destination.set(delegate: self)
        }
    }
    
    @IBAction func didSwitchPlaySounds(_ sender: Any) {
        viewModel.setSounds(enabled: playSoundsSwitch.isOn)
    }
    
    // Re fetch data from the server
    @objc func refreshData() {
        showActivityIndicator()
        
        firstly {
            viewModel.loadData()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Возникла проблема при загрузке настроек", theme: .error)
            
        }.finally {
            self.hideActivityIndicator()
            self.updateUI(animated: true)
        }
    }
    
    private func updateUI(animated: Bool = false) {
        currencyLabel.text = viewModel.currency
        reloadData(animated: animated)
    }
    
    private func showActivityIndicator(animated: Bool = true) {
        refreshControl?.beginRefreshing(in: tableView, animated: animated)
    }
    
    private func hideActivityIndicator() {
        self.refreshControl?.endRefreshing()
    }
    
    private func setupUI() {
        setupRefreshControl()
        playSoundsSwitch.setOn(viewModel.soundsEnabled, animated: false)
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
}

extension SettingsViewController : CurrenciesViewControllerDelegate {
    func didSelectCurrency(currency: Currency) {
        update(currency: currency)
    }
    
    func update(currency: Currency) {
        dirtyUpdate(currency: currency)
        showActivityIndicator()
        
        firstly {
            viewModel.update(currency: currency)
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Возникла проблема при обновлении валюты", theme: .error)
            
        }.finally {
            self.hideActivityIndicator()
            self.updateUI(animated: true)
        }
    }
    
    private func dirtyUpdate(currency: Currency) {
        currencyLabel.text = currency.code
    }
}
