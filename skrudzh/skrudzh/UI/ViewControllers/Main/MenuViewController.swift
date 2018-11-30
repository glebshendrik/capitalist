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

class MenuViewController : StaticDataTableViewController {
    
    @IBOutlet weak var joinCell: UITableViewCell!
    @IBOutlet weak var profileCell: UITableViewCell!
    
    var viewModel: MenuViewModel!
    
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
        refreshControl?.beginRefreshing(in: tableView, animated: true)
        _ = viewModel.loadData().ensure {
            self.updateUI(animated: true)
            self.refreshControl?.endRefreshing()
        }
    }
    
    private func setupUI() {
        setupRefreshControl()
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
}
