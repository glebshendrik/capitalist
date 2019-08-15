//
//  ProvidersViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/06/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SnapKit

protocol ProvidersViewControllerDelegate {
    func didSelect(providerViewModel: ProviderViewModel)
}

class ProvidersViewController : UIViewController, UIMessagePresenterManagerDependantProtocol {
    
    var viewModel: ProvidersViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var delegate: ProvidersViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchClearButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        fetchProviders()
    }
    
    private func setupUI() {
        setupLoader()
        setupSearchBar()
    }
    
    private func setupLoader() {
        loader.showLoader()
        loader.isHidden = true
    }
    
    private func setupSearchBar() {
        searchField.attributedPlaceholder = NSAttributedString(string: "Поиск",
                                                               attributes: [NSAttributedString.Key.foregroundColor : UIColor.by(.text9EAACC)])
    }
    
    private func updateUI() {
        tableView.reloadData()
        updateSearchBar()
    }
    
    private func updateSearchBar() {
        searchClearButton.isHidden = !viewModel.hasSearchQuery
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
            self.updateUI()
        }
    }
    
    @IBAction func didTapClearSearch(_ sender: Any) {
        searchField.clear()
        searchField.resignFirstResponder()
        viewModel.searchQuery = nil
        updateUI()
    }
    
    @IBAction func didTapLoupe(_ sender: Any) {
        searchField.becomeFirstResponder()
    }
    
    @IBAction func didChangeSearchQuery(_ sender: Any) {
        viewModel.searchQuery = searchField.text?.trimmed
        updateUI()
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
        return 60
    }
}

extension ProvidersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let providerViewModel = viewModel.providerViewModel(at: indexPath) else { return }
        close()
        delegate?.didSelect(providerViewModel: providerViewModel)
    }
}
