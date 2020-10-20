//
//  CountriesViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 10.04.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SnapKit

protocol CountriesViewControllerDelegate : class {
    func didSelectCountry(_ countryViewModel: CountryViewModel)
}

class CountriesViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, UIFactoryDependantProtocol {
    
    var viewModel: CountriesViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    weak var delegate: CountriesViewControllerDelegate?
    var factory: UIFactoryProtocol!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchClearButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        loadData()
    }
    
    private func setupUI() {
        setupSearchBar()
        setupNavigationBarUI()
    }
        
    private func setupSearchBar() {
        searchField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Поиск", comment: "Поиск"),
                                                               attributes: [NSAttributedString.Key.foregroundColor : UIColor.by(.white64)])
    }
    
    func setupNavigationBarUI() {
        setupNavigationBarAppearance()
        navigationItem.title = NSLocalizedString("Выберите страну", comment: "Выберите страну")
    }
    
    private func loadData() {
        _ = firstly {
                viewModel.loadCountries()
            }.done {
                self.updateUI()
            }        
    }
    
    private func updateUI() {
        tableView.reloadData()
        updateSearchBar()
    }
    
    private func updateSearchBar() {
        searchClearButton.isHidden = !viewModel.hasSearchQuery
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

extension CountriesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCountries
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
        
        if let countryCell = cell as? CountryCell,
            let countryViewModel = viewModel.countryViewModel(at: indexPath) {
            countryCell.viewModel = countryViewModel
            return countryCell
        }
        
        return cell
    }
}

extension CountriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let countryViewModel = viewModel.countryViewModel(at: indexPath) else { return }
                
        delegate?.didSelectCountry(countryViewModel)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
