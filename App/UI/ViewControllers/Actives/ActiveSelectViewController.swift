//
//  ActiveSelectViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol ActiveSelectViewControllerDelegate {
    func didSelect(sourceActiveViewModel: ActiveViewModel)
    func didSelect(destinationActiveViewModel: ActiveViewModel)
}

class ActiveSelectViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var delegate: ActiveSelectViewControllerDelegate? = nil
    private var selectionType: TransactionPart = .destination
        
    var viewModel: ActivesViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadActives()
    }
    
    func set(delegate: ActiveSelectViewControllerDelegate,
             skipActiveId: Int?,
             selectionType: TransactionPart) {
        self.delegate = delegate
        self.viewModel.skipActiveId = skipActiveId
        self.selectionType = selectionType
    }
    
    private func loadActives() {
        set(loader, hidden: false, animated: false)
        firstly {
            viewModel.loadActives()
        }.done {
            self.updateUI()
        }
        .catch { e in
            self.messagePresenterManager.show(navBarMessage: "Ошибка загрузки активов", theme: .error)
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

extension ActiveSelectViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfActives
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveTableViewCell", for: indexPath) as? ActiveTableViewCell,
            let activeViewModel = viewModel.activeViewModel(at: indexPath) else {
                return UITableViewCell()
        }
        cell.viewModel = activeViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let activeViewModel = viewModel.activeViewModel(at: indexPath) else { return }
        switch selectionType {
        case .source:
            delegate?.didSelect(sourceActiveViewModel: activeViewModel)
        case .destination:
            delegate?.didSelect(destinationActiveViewModel: activeViewModel)
        }
        close()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
