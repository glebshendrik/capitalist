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
    func didConnectTo(_ providerViewModel: ProviderViewModel, providerConnection: ProviderConnection)
}

class ProvidersViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, UIFactoryDependantProtocol {
    
    var viewModel: ProvidersViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var factory: UIFactoryProtocol!
    var delegate: ProvidersViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchClearButton: UIButton!    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchProviders()
    }
    
    private func setupUI() {
        setupLoader()
        setupSearchBar()
        setupNavigationBarUI()
    }
    
    private func setupLoader() {
        loader.showLoader()
        loader.isHidden = true
    }
    
    func setupNavigationBarUI() {
        setupNavigationBarAppearance()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "currency-icon") , style: .plain, target: self, action: #selector(didTapCountry(_:)))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.by(.blue1)
        updateTitleUI()
    }
    
    private func setupSearchBar() {
        searchField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Поиск", comment: "Поиск"),
                                                               attributes: [NSAttributedString.Key.foregroundColor : UIColor.by(.white64)])
    }
    
    private func updateUI() {
        tableView.reloadData()
        updateTitleUI()
        updateSearchBar()
    }
    
    private func updateTitleUI() {
        let topText = NSLocalizedString("Выберите банк", comment: "Выберите банк")
        let bottomText = viewModel.selectedCountryViewModel?.name ?? ""

        let titleParameters = [NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: 18)!,
                               NSAttributedString.Key.foregroundColor : UIColor.by(.white100)]
        let subtitleParameters = [NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: 13)!,
                                  NSAttributedString.Key.foregroundColor : UIColor.by(.white64)]

        let title = NSMutableAttributedString(string: topText, attributes: titleParameters)
        let subtitle = NSAttributedString(string: bottomText, attributes: subtitleParameters)

        title.append(NSAttributedString(string: "\n"))
        title.append(subtitle)

        let size = title.size()

        let width = size.width
        guard let height = navigationController?.navigationBar.frame.size.height else {return}

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        titleLabel.attributedText = title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        navigationItem.titleView = titleLabel
    }
    
    private func updateSearchBar() {
        searchClearButton.isHidden = !viewModel.hasSearchQuery
        searchField.isEnabled = !viewModel.loading
    }
    
    private func fetchProviders() {
        loader.isHidden = false
        messagePresenterManager.showHUD(with: NSLocalizedString("Загружаем список банков...", comment: "Загружаем список банков..."))
        viewModel.set(loading: true)
        updateUI()
        firstly {
            viewModel.loadProviders()
        }.catch { e in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка при загрузке банков", comment: "Ошибка при загрузке банков"), theme: .error)
            self.close()
        }.finally {
            self.loader.isHidden = true
            self.messagePresenterManager.dismissHUD()
            self.viewModel.set(loading: false)
            self.updateUI()
        }
    }
    
    @IBAction func didTapClearSearch(_ sender: Any) {
        guard !viewModel.loading else { return }
        searchField.clear()
        searchField.resignFirstResponder()
        viewModel.searchQuery = nil
        updateUI()
    }
    
    @IBAction func didTapLoupe(_ sender: Any) {
        guard !viewModel.loading else { return }
        searchField.becomeFirstResponder()
    }
    
    @IBAction func didTapCountry(_ sender: Any) {
        guard let countriesViewController = factory.countriesViewController(delegate: self) else { return }
        modal(UINavigationController(rootViewController: countriesViewController))
    }
    
    @IBAction func didChangeSearchQuery(_ sender: Any) {
        viewModel.searchQuery = searchField.text?.trimmed
        updateUI()
    }
    
    private func close() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension ProvidersViewController: CountriesViewControllerDelegate {
    func didSelectCountry(_ countryViewModel: CountryViewModel) {        
        searchField.clear()
        viewModel.clear()
        viewModel.selectedCountryViewModel = countryViewModel
        updateTitleUI()
        fetchProviders()
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
}

extension ProvidersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !viewModel.loading else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let providerViewModel = viewModel.providerViewModel(at: indexPath) else { return }
                
        setupProviderConnection(for: providerViewModel)
    }
}

extension ProvidersViewController : ProviderConnectionViewControllerDelegate {
    func setupProviderConnection(for providerViewModel: ProviderViewModel) {
        messagePresenterManager.showHUD(with: NSLocalizedString("Загрузка подключения к банку...", comment: "Загрузка подключения к банку..."))
        firstly {
            viewModel.loadProviderConnection(for: providerViewModel.id)
        }.ensure {
            self.messagePresenterManager.dismissHUD()
        }.get { providerConnection in
            self.close()
            self.delegate?.didConnectTo(providerViewModel, providerConnection: providerConnection)            
        }.catch { error in
            self.createSaltEdgeConnectSession(for: providerViewModel)
//            if case BankConnectionError.providerConnectionNotFound = error {
//                
//            } else {
//                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось загрузить подключение к банку", comment: "Не удалось загрузить подключение к банку"), theme: .error)
//            }
        }
    }
    
    func createSaltEdgeConnectSession(for providerViewModel: ProviderViewModel) {
        messagePresenterManager.showHUD(with: NSLocalizedString("Подготовка подключения к банку...", comment: "Подготовка подключения к банку..."))
        firstly {
            viewModel.createBankConnectionSession(for: providerViewModel)
        }.ensure {
            self.messagePresenterManager.dismissHUD()
        }.get { providerViewModel in
            self.showProviderConnectionViewController(for: providerViewModel)
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось создать подключение к банку", comment: "Не удалось создать подключение к банку"), theme: .error)
        }
    }
    
    func showProviderConnectionViewController(for providerViewModel: ProviderViewModel) {
        // navigationController?.
        guard let providerConnectionViewController = factory.providerConnectionViewController(delegate: self, providerViewModel: providerViewModel) else { return }
        modal(UINavigationController(rootViewController: providerConnectionViewController))
    }
    
    func didConnectTo(_ providerViewModel: ProviderViewModel, providerConnection: ProviderConnection) {
        delegate?.didConnectTo(providerViewModel, providerConnection: providerConnection)
    }
        
    func didNotConnect() {
        self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось подключиться к банку", comment: "Не удалось подключиться к банку"), theme: .error)
    }
    
    func didNotConnect(with: Error) {
        self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось подключиться к банку", comment: "Не удалось подключиться к банку"), theme: .error)
    }
}
