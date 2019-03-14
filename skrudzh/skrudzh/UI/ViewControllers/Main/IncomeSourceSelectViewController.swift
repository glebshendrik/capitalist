//
//  IncomeSourceSelectViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import PromiseKit

protocol IncomeSourceSelectViewControllerDelegate {
    func didSelect(incomeSourceViewModel: IncomeSourceViewModel)
}

class IncomeSourceSelectViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var delegate: IncomeSourceSelectViewControllerDelegate? = nil
    
    var viewModel: IncomeSourcesViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadIncomeSources()
    }
    
    func set(delegate: IncomeSourceSelectViewControllerDelegate) {
        self.delegate = delegate
    }
    
    private func loadIncomeSources() {
        set(loader, hidden: false, animated: false)
        firstly {
            viewModel.loadIncomeSources()
        }.done {
            self.updateUI()
        }
        .catch { e in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки источников доходов", theme: .error)
            self.close()
        }.finally {
            self.set(self.loader, hidden: true)
        }
    }
    
    private func close() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func updateUI() {
        tableView.reloadData(with: .automatic)
    }
    
    private func setupUI() {
        loader.showLoader()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension IncomeSourceSelectViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfIncomeSources
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IncomeSourceTableViewCell", for: indexPath) as? IncomeSourceTableViewCell,
            let incomeSourceViewModel = viewModel.incomeSourceViewModel(at: indexPath) else {
                return UITableViewCell()
        }
        cell.viewModel = incomeSourceViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let incomeSourceViewModel = viewModel.incomeSourceViewModel(at: indexPath) else { return }
        delegate?.didSelect(incomeSourceViewModel: incomeSourceViewModel)
        close()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
