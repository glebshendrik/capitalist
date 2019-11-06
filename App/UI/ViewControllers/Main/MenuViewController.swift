//
//  MenuViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 30/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import SideMenu
import StaticTableViewController
import PromiseKit

class MenuViewController : StaticTableViewController, UIMessagePresenterManagerDependantProtocol {
    
    @IBOutlet weak var joinCell: UITableViewCell!
    @IBOutlet weak var profileCell: UITableViewCell!
    @IBOutlet weak var incomeProgress: ProgressView!
    @IBOutlet weak var expensesProgress: ProgressView!
    
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
    
    func updateUI(animated: Bool = false) {
        updateIncomesProgressUI()
        updateExpensesProgressUI()
        updateProfileUI()
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
    }
    
    func updateTableUI(animated: Bool = false) {
        set(cells: joinCell, hidden: !viewModel.isCurrentUserLoaded || !viewModel.isCurrentUserGuest)
        set(cells: profileCell, hidden: !viewModel.isCurrentUserLoaded || viewModel.isCurrentUserGuest)
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
            messagePresenterManager.show(navBarMessage: "Необходимо подтвердить регистрацию! Мы отправили вам письмо с инструкциями", theme: .warning, duration: .normal)
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
        incomeProgress.progressColor = UIColor.by(.blue6B93FB)
        incomeProgress.labelsColor = UIColor.by(.textFFFFFF)
        expensesProgress.progressColor = UIColor.by(.blue6B93FB)
        expensesProgress.labelsColor = UIColor.by(.textFFFFFF)
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
