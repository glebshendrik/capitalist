//
//  AccountsViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 04/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol AccountsViewControllerDelegate {
    func didSelect(accountViewModel: AccountViewModel, providerConnection: ProviderConnection)
}

class AccountsViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    
    var viewModel: AccountsViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var delegate: AccountsViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loader: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchAccounts()
    }
    
    private func setupUI() {
        loader.showLoader()
        loader.isHidden = true
    }
    
    private func fetchAccounts() {
        loader.isHidden = false
        firstly {
            viewModel.loadAccounts()
        }.catch { e in
            if case BankConnectionError.allBankAccountsAlreadyUsed = e {
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Все доступные счета банка уже подключены", comment: "Все доступные счета банка уже подключены"), theme: .error)
            } else {
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка при загрузке счетов банка", comment: "Ошибка при загрузке счетов банка"), theme: .error)
            }
            
            self.close()
        }.finally {
            self.loader.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    private func close() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension AccountsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfAccounts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)
        
        if let accountCell = cell as? AccountCell,
            let accountViewModel = viewModel.accountViewModel(at: indexPath) {
            accountCell.viewModel = accountViewModel
            return accountCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}

extension AccountsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard   let accountViewModel = viewModel.accountViewModel(at: indexPath),
                let providerConnection = viewModel.providerConnection else { return }
        
        close()
        delegate?.didSelect(accountViewModel: accountViewModel, providerConnection: providerConnection)
    }
}
