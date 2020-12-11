//
//  PrototypesLinkingViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 09.12.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import ESPullToRefresh

class PrototypesLinkingViewController : UIViewController,
                                        UIFactoryDependantProtocol,
                                        UIMessagePresenterManagerDependantProtocol,
                                        Away {
    weak var home: Home?
    var factory: UIFactoryProtocol!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: PrototypesLinkingViewModel!
    
    var id: String {
        return "\(Infrastructure.ViewController.PrototypesLinkingViewController.identifier)_\(viewModel.linkingType.rawValue)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        loadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        switch viewModel.linkingType {
            case .incomeSource:
                UIFlowManager.reach(.linkingIncomeSources)
            case .expenseSource:
                UIFlowManager.reach(.linkingExpenseSources)
            case .expenseCategory:
                UIFlowManager.reach(.linkingExpenseCategories)
            default:
                break
        }        
        home?.cameHome(from: .PrototypesLinkingViewController)
    }
}

extension PrototypesLinkingViewController {
    private func loadData() {
        showHUD()
        firstly {
            viewModel.loadData()
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки списка", comment: ""), theme: .error)
        }.finally {
            self.updateUI()
            self.dismissHUD()
        }
    }
    
    private func link(_ prototype: TransactionableExample?) {
        guard
            let linkingTransactionable = viewModel.linkingTransactionable
        else {
            return
        }
        showHUD()
        firstly {
            viewModel.link(linkingTransactionable, example: prototype)
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка связывания", comment: ""), theme: .error)
        }.finally {
            self.updateUI()
            self.dismissHUD()
        }
    }
}

extension PrototypesLinkingViewController {
    private func setupUI() {
        setupNavigationBarAppearance()
        setupTableView()
        setupPullToRefresh()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupPullToRefresh() {
        tableView.es.addPullToRefresh {
            [weak self] in
            self?.loadData()
        }
        tableView.setupPullToRefreshAppearance()
    }
}

extension PrototypesLinkingViewController {
    private func updateUI() {
        updateTitleUI()
        updateDescriptionUI()
        updateTableUI()
        stopPullToRefresh()
    }
    
    private func updateTitleUI() {
        titleLabel.text = viewModel.title
    }
    
    private func updateDescriptionUI() {
        descriptionLabel.text = viewModel.description
    }
    
    private func updateTableUI() {
        tableView.reloadData(with: .automatic)
    }
    
    private func stopPullToRefresh() {
        tableView.es.stopPullToRefresh()
        tableView.refreshControl?.endRefreshing()
    }
}

extension PrototypesLinkingViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfLinkingTransactionables
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let linkingTransactionable = viewModel.linkingTransactionable(by: indexPath)
        else {
            return UITableViewCell()
        }
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrototypeLinkTableViewCell", for: indexPath) as? PrototypeLinkTableViewCell
        else {
            return UITableViewCell()
        }
        cell.viewModel = linkingTransactionable
        cell.delegate = self
        return cell
    }
}

extension PrototypesLinkingViewController : PrototypeLinkTableViewCellDelegate {
    func didTapLinkingButton(linkingTransactionable: LinkingTransactionableViewModel) {
        viewModel.linkingTransactionable = linkingTransactionable
        if linkingTransactionable.isLinked {
            link(nil)
        }
        else {
            slideUp(factory.transactionableExamplesViewController(delegate: self,
                                                                  transactionableType: linkingTransactionable.transactionable.type,
                                                                  isUsed: false))
        }
    }
}

extension PrototypesLinkingViewController : TransactionableExamplesViewControllerDelegate {
    func didSelect(exampleViewModel: TransactionableExampleViewModel) {
        guard
            let example = exampleViewModel.example
        else {
            return
        }
        link(example)
    }
}
