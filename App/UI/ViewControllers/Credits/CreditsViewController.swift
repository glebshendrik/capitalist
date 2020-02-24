//
//  CreditsViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class CreditsViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable, UIFactoryDependantProtocol {
    
    var navigationBarTintColor: UIColor? = UIColor.by(.black2)
    var factory: UIFactoryProtocol!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: CreditsViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    private var loader: LoaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.by(.black2)
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
        showNewCredit()
    }
}

extension CreditsViewController {
        
    func setupUI() {
        setupTable()
        setupRefreshControl()        
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
    
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    private func setupRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.backgroundColor = .clear
        tableView.refreshControl?.tintColor = .clear
        tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        if let objOfRefreshView = Bundle.main.loadNibNamed("LoaderView",
                                                           owner: self,
                                                           options: nil)?.first as? LoaderView,
            let refreshControl = tableView.refreshControl {
            
            loader = objOfRefreshView
            loader.imageView.showLoader()
            loader.frame = refreshControl.frame
            refreshControl.removeSubviews()
            refreshControl.addSubview(loader)
        }
    }
    
    @objc func refreshData() {
        loadData()
    }
        
    func updateUI() {
        tableView.reloadData(with: .automatic)
    }
}

extension CreditsViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCredits
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreditTableViewCell", for: indexPath) as? CreditTableViewCell,
            let creditViewModel = viewModel.creditViewModel(at: indexPath) else {
                return UITableViewCell()
        }
        cell.viewModel = creditViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let creditViewModel = viewModel.creditViewModel(at: indexPath) else { return }
        showCredit(creditViewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106.0
    }
}

extension CreditsViewController : CreditEditViewControllerDelegate {
    func didCreateCredit() {
        loadCredits(finantialDataInvalidated: true)
    }

    func didUpdateCredit() {
        loadCredits(finantialDataInvalidated: true)
    }

    func didRemoveCredit() {
        loadCredits(finantialDataInvalidated: true)
    }

    func showCredit(_ credit: CreditViewModel) {        
        modal(factory.creditInfoViewController(creditId: credit.id, credit: credit))
    }

    func showNewCredit() {
        modal(factory.creditEditViewController(delegate: self, creditId: nil, destination: nil))
    }
}

extension CreditsViewController {
    
    @objc func loadData() {
        loadCredits()
    }
        
    private func loadCredits(finantialDataInvalidated: Bool = false) {
        if finantialDataInvalidated {
            postFinantialDataUpdated()
        }
        showActivityIndicator()
        firstly {
            viewModel.loadCredits()
        }.catch { e in
            print(e)
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки кредитов", comment: "Ошибка загрузки кредитов"), theme: .error)
        }.finally {
            self.hideActivityIndicator()
            self.updateUI()
        }
    }
    
    func showActivityIndicator() {
        tableView.refreshControl?.beginRefreshing(in: tableView, animated: true)
        tableView.isUserInteractionEnabled = false
    }
    
    func hideActivityIndicator() {
        tableView.refreshControl?.endRefreshing()
        tableView.isUserInteractionEnabled = true
    }
    
    private func postFinantialDataUpdated() {
        NotificationCenter.default.post(name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
}
