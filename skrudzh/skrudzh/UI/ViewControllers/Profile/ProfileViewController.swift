//
//  ProfileViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 04/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import PromiseKit
import StaticDataTableViewController

protocol ProfileViewOutputProtocol {
    var user: User? { get }
}

class ProfileViewController : StaticDataTableViewController, UIMessagePresenterManagerDependantProtocol, ProfileViewOutputProtocol {
    
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: ProfileViewModel!
    
    @IBOutlet weak var firstnameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    var user: User? {
        return viewModel.user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
        refreshData()
    }
    
    @IBAction func didTapLogoutButton(_ sender: Any) {
        messagePresenterManager.showHUD(with: "Выход...")
        logoutButton.isEnabled = false
        
        firstly {
            viewModel.logOut()
        }.catch { _ in
            
            
        }.finally {
            self.messagePresenterManager.dismissHUD()
            self.logoutButton.isEnabled = true
        }
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
        logoutButton.isEnabled = false
        
        firstly {
            viewModel.loadData()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: "Возникла проблема при загрузке данных профиля", theme: .error)
            
        }.finally {            
            self.updateUI(animated: true)
            self.hideActivityIndicator()
            self.logoutButton.isEnabled = true
        }
    }
    
    private func updateUI(animated: Bool = false) {
        firstnameLabel.text = viewModel.currentUserFirstname
        emailLabel.text = viewModel.currentUserEmail
        // Reloads data in the table view
        reloadData(animated: animated)
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

