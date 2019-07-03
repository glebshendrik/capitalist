//
//  ProvidersViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/06/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

protocol ProvidersViewControllerDelegate {
    func didSelect(providerViewModel: ProviderViewModel)
}

class ProvidersViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    
    var viewModel: ProvidersViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var delegate: ProvidersViewControllerDelegate?
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loader: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchProviders()
    }
    
    private func setupUI() {
        loader.showLoader()
        loader.isHidden = true
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
    }
    
    private func fetchProviders() {
        loader.isHidden = false
        firstly {
            viewModel.loadProviders()
        }.catch { e in
            self.messagePresenterManager.show(navBarMessage: "Ошибка при загрузке банков", theme: .error)
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

extension ProvidersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfProviders
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderCell", for: indexPath)
        
        if let providerCell = cell as? ProviderCell,
            let providerViewModel = viewModel.providerViewModel(at: indexPath) {
            providerCell.viewModel = providerViewModel
            return providerCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}

extension ProvidersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let providerViewModel = viewModel.providerViewModel(at: indexPath) else { return }
        
        searchController.dismiss(animated: false)
        close()
        delegate?.didSelect(providerViewModel: providerViewModel)
    }
}

extension ProvidersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {        
        viewModel.searchQuery = searchController.searchBar.text
        tableView.reloadData()
    }
}
