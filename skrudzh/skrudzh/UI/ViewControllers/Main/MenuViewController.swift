//
//  MenuViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 30/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import SideMenu
import StaticDataTableViewController
import PromiseKit

class MenuViewController : StaticDataTableViewController, UIMessagePresenterManagerDependantProtocol {
    
    @IBOutlet weak var joinCell: UITableViewCell!
    @IBOutlet weak var profileCell: UITableViewCell!
    
    var viewModel: MenuViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
        refreshData()
    }
    
    func updateUI(animated: Bool = false) {
        cell(joinCell, setHidden: !viewModel.isCurrentUserLoaded || !viewModel.isCurrentUserGuest)
        cell(profileCell, setHidden: !viewModel.isCurrentUserLoaded || viewModel.isCurrentUserGuest)
        reloadData(animated: animated)
    }
    
    @objc func refreshData() {
        showActivityIndicator()
        
        firstly {
            viewModel.loadData()
        }.catch { _ in
            
            
        }.finally {
            self.notifyIfRegistrationNotConfirmed()
            self.updateUI(animated: true)
            self.hideActivityIndicator()
        }
    }
    
    private func notifyIfRegistrationNotConfirmed() {
        if viewModel.shouldNotifyAboutRegistrationConfirmation {
            messagePresenterManager.show(navBarMessage: "Необходимо подтвердить регистрацию! Мы отправили вам письмо с инструкциями", theme: .warning)
        }
    }
    
    private func showActivityIndicator(animated: Bool = true) {
        refreshControl?.beginRefreshing(in: tableView, animated: animated)
    }
    
    private func hideActivityIndicator() {
        refreshControl?.endRefreshing()
    }
    
    private func setupUI() {
        setupRefreshControl()
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
}
