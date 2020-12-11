//
//  ProfileViewController.swift
//  Capitalist
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

class ProfileViewController : StaticTableViewController, UIMessagePresenterManagerDependantProtocol, ProfileViewOutputProtocol, NavigationBarColorable, ApplicationRouterDependantProtocol, UIFactoryDependantProtocol {

    var navigationBarTintColor: UIColor? = UIColor.by(.black2)

    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: ProfileViewModel!
    var router: ApplicationRouterProtocol!
    var factory: UIFactoryProtocol!
    
    @IBOutlet weak var firstnameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    @IBOutlet weak var loaderImageView: UIImageView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var confirmCell: UITableViewCell!
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
    
    @IBAction func didTapConfirmButton(_ sender: Any) {
        self.setActivityIndicator(hidden: false)
        logoutButton.isEnabled = false
        
        firstly {
            viewModel.sendConfirmation()
        }.done {
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Мы отправили вам письмо с инструкцией для подтверждения вашей учетной записи", comment: ""), theme: .success)
        }
        .catch { _ in
            
            
        }.finally {
            self.setActivityIndicator(hidden: true)
            self.logoutButton.isEnabled = true
        }
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
    
    @IBAction func didTapDestroyDataButton(_ sender: Any) {
        let destroyDataAction = UIAlertAction(title: NSLocalizedString("Удалить", comment: "Удалить"),
                                              style: .destructive,
                                              handler: { _ in
                                                    self.destroyUserData()
                                                })
        
        sheet(title: NSLocalizedString("Удалить данные о финансах?", comment: ""),
              actions: [destroyDataAction],
              message: NSLocalizedString("Вы собираетесь удалить все ваши данные о финансах. Будут удалены: источники доходов, кошельки, категории трат, активы, долги, кредиты и все транзакции.", comment: ""),
              preferredStyle: .alert)
    }
    
    func destroyUserData() {
        self.setActivityIndicator(hidden: false)
        logoutButton.isEnabled = false
        
        firstly {
            viewModel.destroyUserData()
        }.catch { error in
            print(error)
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось удалить финансовые данные", comment: ""), theme: .error)
            
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
        push(factory.subscriptionViewController(requiredPlans: [.premium, .platinum]))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "ShowProfileEditScreen":
                prepareProfileEdit(segue)
            case "showLinkingIncomeSources":
                prepareLinking(.incomeSource, segue: segue)
            case "showLinkingExpenseSource":
                prepareLinking(.expenseSource, segue: segue)
            case "showLinkingExpenseCategory":
                prepareLinking(.expenseCategory, segue: segue)
            default:
                return
        }
    }
    
    private func prepareProfileEdit(_ segue: UIStoryboardSegue) {
        if  let destinationNavigationController = segue.destination as? UINavigationController,
            let destination = destinationNavigationController.topViewController as? ProfileEditViewController {
            
            destination.set(user: viewModel.user)
            destination.delegate = self
        }
    }
    
    private func prepareLinking(_ type: TransactionableType, segue: UIStoryboardSegue) {
        if  let destination = segue.destination as? PrototypesLinkingViewController {
            destination.viewModel.linkingType = type
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
        confirmButton.setTitle(NSLocalizedString("Отправить подтверждение", comment: ""), for: .normal)
        set(cells: confirmCell, hidden: viewModel.confirmButtonHidden)
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
