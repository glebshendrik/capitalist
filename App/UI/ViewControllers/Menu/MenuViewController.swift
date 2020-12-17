//
//  MenuViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 30/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import SideMenu
import StaticTableViewController
import PromiseKit

class MenuViewController : StaticTableViewController, UIMessagePresenterManagerDependantProtocol, UIFactoryDependantProtocol {
    
    var factory: UIFactoryProtocol!
    
    @IBOutlet weak var joinCell: UITableViewCell!
    @IBOutlet weak var profileCell: UITableViewCell!
    @IBOutlet weak var premiumCell: UITableViewCell!
    @IBOutlet weak var incomeProgress: ProgressView!
    @IBOutlet weak var expensesProgress: ProgressView!
    @IBOutlet weak var creditsCell: UITableViewCell!
    @IBOutlet weak var borrowsCell: UITableViewCell!
    
    private var loaderView: LoaderView!
    
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {        
        if !viewModel.premiumFeaturesAvailable && (identifier == "showBorrows" || identifier == "showCredits") {
            modal(factory.subscriptionNavigationViewController(requiredPlans: [.premium, .platinum]))
            return false
        }
        if !viewModel.requiredPlans.isEmpty && identifier == "showSubscription" {
            push(factory.subscriptionViewController(requiredPlans: viewModel.requiredPlans))
            return false
        }
        return true
    }
    
    func updateUI(animated: Bool = false) {
        updateIncomesProgressUI()
        updateExpensesProgressUI()
        updateProfileUI()
        updateSubscriptionUI()
        updateTableUI(animated: animated)
    }
    
    func updateIncomesProgressUI() {
        incomeProgress.progressText = viewModel.incomesAmount
        incomeProgress.limitText = viewModel.incomesAmountPlanned
        incomeProgress.progressWidth = incomeProgress.bounds.width * viewModel.incomesProgress
    }
    
    func updateExpensesProgressUI() {
        expensesProgress.progressText = viewModel.expensesAmount
        expensesProgress.limitText = viewModel.expensesAmountPlanned
        expensesProgress.progressWidth = expensesProgress.bounds.width * viewModel.expensesProgress
    }
    
    func updateProfileUI () {
        profileCell.textLabel?.text = viewModel.profileTitle
        profileCell.textLabel?.textColor = UIColor.by(viewModel.premiumFeaturesAvailable ? .yellow1 : .white100)
        profileCell.imageView?.image = UIImage(named: viewModel.premiumFeaturesAvailable ? "premium-icon" : "profile-menu-item-icon")
    }
    
    func updateSubscriptionUI() {
        premiumCell.textLabel?.text = viewModel.subscriptionItemTitle
    }
    
    func updateTableUI(animated: Bool = false) {
        set(cells: joinCell, hidden: viewModel.joinItemHidden)
        set(cells: profileCell, hidden: viewModel.profileItemHidden)
        set(cells: premiumCell, hidden: viewModel.subscriptionItemHidden)
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
            messagePresenterManager.show(navBarMessage: NSLocalizedString("Необходимо подтвердить регистрацию! Мы отправили вам письмо с инструкциями", comment: "Необходимо подтвердить регистрацию! Мы отправили вам письмо с инструкциями"), theme: .warning, duration: .normal)
        }
    }
    
    private func showActivityIndicator(animated: Bool = true) {
        refreshControl?.beginRefreshing(in: tableView, animated: animated)
    }
    
    private func hideActivityIndicator() {
        refreshControl?.endRefreshing()
    }
    
    private func setupUI() {
        setupMenu()
        setupProgressUI()
        setupRefreshControl()
        insertAnimation = .top
        deleteAnimation = .bottom
    }
    
    private func setupMenu() {
        if let menuLeftNavigationController = navigationController as? SideMenuNavigationController {
            menuLeftNavigationController.presentationStyle.backgroundColor = .clear
        }
    }
    
    func setupProgressUI() {
        incomeProgress.progressColor = UIColor.by(.blue1)
        incomeProgress.labelsColor = UIColor.by(.white100)
        incomeProgress.labelsFont = UIFont(name: "Roboto-Regular", size: 14)!
        expensesProgress.progressColor = UIColor.by(.brandExpense)
        expensesProgress.labelsColor = UIColor.by(.white100)
        expensesProgress.labelsFont = UIFont(name: "Roboto-Regular", size: 14)!
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
