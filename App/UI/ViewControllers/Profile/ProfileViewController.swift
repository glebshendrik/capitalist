//
//  ProfileViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 04/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import StaticTableViewController

protocol ProfileViewOutputProtocol {
    var user: User? { get }
}

class ProfileViewController : StaticTableViewController, UIMessagePresenterManagerDependantProtocol, ProfileViewOutputProtocol, NavigationBarColorable {
        
    var navigationBarTintColor: UIColor? = UIColor.by(.dark333D5B)

    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: ProfileViewModel!
    
    @IBOutlet weak var firstnameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    @IBOutlet weak var loaderImageView: UIImageView!
    
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
        self.setActivityIndicator(hidden: true, animated: false)
    }
    
    @IBAction func didTapLogoutButton(_ sender: Any) {
        self.setActivityIndicator(hidden: false)
        logoutButton.isEnabled = false
        
        firstly {
            viewModel.logOut()
        }.catch { _ in
            
            
        }.finally {
            self.setActivityIndicator(hidden: true)
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
            self.hideActivityIndicator()
            self.updateUI(animated: true)
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
        self.refreshControl?.endRefreshing()
    }
    
    private func setActivityIndicator(hidden: Bool, animated: Bool = true) {
        set(cells: activityIndicatorCell, hidden: hidden)
        reloadData(animated: animated)
    }
    
    private func setupUI() {
        insertAnimation = .top
        deleteAnimation = .bottom
        setupRefreshControl()
        loaderImageView.showLoader()
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

