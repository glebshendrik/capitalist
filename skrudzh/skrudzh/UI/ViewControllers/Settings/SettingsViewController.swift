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
        if  segue.identifier == "ShowProfileEditScreen",
            let destinationNavigationController = segue.destination as? UINavigationController,
            let destination = destinationNavigationController.topViewController as? ProfileEditViewController {
            
            destination.set(user: viewModel.user)
        }
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
