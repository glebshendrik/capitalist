//
//  WaitingDebtsViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 07/05/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

enum WaitingDebtsType {
    case debts, loans
    
    var listHeader: String {
        switch self {
        case .debts:
            return "Ваши займы"
        case .loans:
            return "Ваши долги"
        }
    }
}

protocol WaitingDebtsViewControllerDelegate : class {
    func didSelect(debtTransaction: FundsMoveViewModel,
                   expenseSourceStartable: ExpenseSourceViewModel,
                   expenseSourceCompletable: ExpenseSourceViewModel)
}

class WaitingDebtsViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    private weak var delegate: WaitingDebtsViewControllerDelegate? = nil
    private var waitingDebtsType: WaitingDebtsType = .debts
    
    var viewModel: WaitingDebtsViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    var expenseSourceStartable: ExpenseSourceViewModel? = nil
    var expenseSourceCompletable: ExpenseSourceViewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func set(delegate: WaitingDebtsViewControllerDelegate,
             expenseSourceStartable: ExpenseSourceViewModel,
             expenseSourceCompletable: ExpenseSourceViewModel,
             waitingDebts: [FundsMoveViewModel],
             waitingDebtsType: WaitingDebtsType) {
        self.delegate = delegate
        self.viewModel.set(fundsMoveViewModels: waitingDebts)
        self.expenseSourceStartable = expenseSourceStartable
        self.expenseSourceCompletable = expenseSourceCompletable
        self.waitingDebtsType = waitingDebtsType
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        headerTitleLabel.text = waitingDebtsType.listHeader
    }
    
    private func close() {
        presentingViewController?.dismiss(animated: true)
    }
}

extension WaitingDebtsViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DebtTableViewCell", for: indexPath) as? DebtTableViewCell,
            let fundsMoveViewModel = viewModel.fundsMoveViewModel(at: indexPath) else {
                return UITableViewCell()
        }
        cell.viewModel = fundsMoveViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let fundsMoveViewModel = viewModel.fundsMoveViewModel(at: indexPath) else { return }
        close()
        guard let expenseSourceStartable = expenseSourceStartable,
            let expenseSourceCompletable = expenseSourceCompletable else {
                return
        }
        delegate?.didSelect(debtTransaction: fundsMoveViewModel,
                            expenseSourceStartable: expenseSourceStartable,
                            expenseSourceCompletable: expenseSourceCompletable)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.0
    }
}
