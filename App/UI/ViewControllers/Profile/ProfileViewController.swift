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

class ProfileViewController : StaticTableViewController, UIMessagePresenterManagerDependantProtocol, ProfileViewOutputProtocol, NavigationBarColorable, ApplicationRouterDependantProtocol {
    
    var navigationBarTintColor: UIColor? = UIColor.by(.black2)

    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: ProfileViewModel!
    var router: ApplicationRouterProtocol!
    
    @IBOutlet weak var firstnameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    @IBOutlet weak var loaderImageView: UIImageView!
    @IBOutlet weak var subscriptionCell: UITableViewCell!
    @IBOutlet weak var subscriptionStatusCell: UITableViewCell!
    @IBOutlet weak var subscriptionManageCell: UITableViewCell!
    @IBOutlet weak var getSubscriptionCell: UITableViewCell!
    @IBOutlet weak var subscriptionStatusLabel: UILabel!
    @IBOutlet weak var subscriptionLabel: UILabel!
    
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
    
    @IBAction func didTapManageSubscriptionButton(_ sender: Any) {
        guard   let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions"),
                UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:])
    }
    
    @IBAction func didTapGetSubscriptionButton(_ sender: Any) {
        push(router.viewController(.SubscriptionViewController))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "ShowProfileEditScreen",
            let destinationNavigationController = segue.destination as? UINavigationController,
            let destination = destinationNavigationController.topViewController as? ProfileEditViewController {
            
                destination.set(user: viewModel.user)
                destination.delegate = self
        }
    }
    
    // Re fetch data from the server
    @objc func refreshData() {
        showActivityIndicator()
        logoutButton.isEnabled = false
        
        firstly {
            viewModel.loadData()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Возникла проблема при загрузке данных профиля", comment: "Возникла проблема при загрузке данных профиля"), theme: .error)
            
        }.finally {            
            self.hideActivityIndicator()
            self.updateUI(animated: true)
            self.logoutButton.isEnabled = true
        }
    }
    
    private func updateUI(animated: Bool = false) {
        updateCommonInfoUI()
        updateSubscriptionUI()
        // Reloads data in the table view
        reloadData(animated: animated)
    }
    
    private func updateCommonInfoUI() {
        firstnameLabel.text = viewModel.currentUserFirstname
        emailLabel.text = viewModel.currentUserEmail
    }
    
    private func updateSubscriptionUI() {
        subscriptionLabel.text = viewModel.subscriptionTitle
        subscriptionStatusLabel.text = viewModel.subscriptionStatus
        set(cells: [subscriptionCell, subscriptionStatusCell, subscriptionManageCell], hidden: !viewModel.hasActiveSubscription)
        set(cells: getSubscriptionCell, hidden: viewModel.hasActiveSubscription)
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
        setupNavigationBar()
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
    
    func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: 18)!,
                          NSAttributedString.Key.foregroundColor : UIColor.by(.white100)]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationItem.title = formTitle
    }
}

extension ProfileViewController : ProfileEditViewControllerDelegate {
    func didUpdateProfile() {
        refreshData()
    }
}
