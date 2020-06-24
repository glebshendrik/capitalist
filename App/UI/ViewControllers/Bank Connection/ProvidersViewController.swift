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
import SwiftyBeaver
import SwiftDate

protocol ProvidersViewControllerDelegate : class {
    func didConnectTo(_ providerViewModel: ProviderViewModel?, connection: Connection)
}

class ProvidersViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, UIFactoryDependantProtocol {
    
    var viewModel: ProvidersViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var factory: UIFactoryProtocol!
    weak var delegate: ProvidersViewControllerDelegate?
    
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

extension ProvidersViewController : ConnectionViewControllerDelegate {
    func setupProviderConnection(for providerViewModel: ProviderViewModel) {
        messagePresenterManager.showHUD(with: NSLocalizedString("Загрузка подключения к банку...", comment: "Загрузка подключения к банку..."))
        firstly {
            viewModel.loadConnection(for: providerViewModel)
        }.ensure {
            self.messagePresenterManager.dismissHUD()
        }.get { connection in
            guard connection.lastStage == .finish else {
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось подключиться к банку", comment: "Не удалось подключиться к банку"), theme: .error)
                return
            }
            switch connection.status {
            case .active:
                guard   let nextRefreshPossibleAt = connection.nextRefreshPossibleAt,
                        let interactive = connection.interactive else {
                        self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось подключиться к банку", comment: "Не удалось подключиться к банку"), theme: .error)
                        return
                }
                if nextRefreshPossibleAt.isInPast,
                   interactive {                    
                    self.showConnectionSession(for: providerViewModel, connectionType: .refresh, connection: connection)
                }
                else {
                    self.close()
                    self.delegate?.didConnectTo(providerViewModel, connection: connection)
                }
            case .inactive:
                self.showConnectionSession(for: providerViewModel, connectionType: .reconnect, connection: connection)
            case .deleted:
                self.showConnectionSession(for: providerViewModel, connectionType: .create, connection: connection)
            }
        }.catch { error in
            if case BankConnectionError.connectionNotFound = error {
                self.showConnectionSession(for: providerViewModel, connectionType: .create)
            } else {
                self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось загрузить подключение к банку", comment: "Не удалось загрузить подключение к банку"), theme: .error)
            }
        }
    }
    
    func showConnectionSession(for providerViewModel: ProviderViewModel, connectionType: ProviderConnectionType, connection: Connection? = nil) {
        messagePresenterManager.showHUD(with: NSLocalizedString("Подготовка подключения к банку...", comment: "Подготовка подключения к банку..."))
        
        func sessionURL() -> Promise<URL> {
            switch connectionType {
            case .create:
                return viewModel.createConnectionSession(for: providerViewModel)
            case .refresh:
                return viewModel.createRefreshConnectionSession(for: providerViewModel, connection: connection)
            case .reconnect:
                return viewModel.createReconnectSession(for: providerViewModel, connection: connection)
            }
        }
        
        firstly {
            sessionURL()
        }.ensure {
            self.messagePresenterManager.dismissHUD()
        }.get { connectionURL in
            self.showConnectionViewController(for: providerViewModel,
                                              connectionURL: connectionURL,
                                              connectionType: connectionType,
                                              connection: connection)
        }.catch { e in
            print(e)
            SwiftyBeaver.error(e)
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось создать подключение к банку", comment: "Не удалось создать подключение к банку"), theme: .error)
        }
    }
    
    func showConnectionViewController(for providerViewModel: ProviderViewModel, connectionURL: URL, connectionType: ProviderConnectionType = .create, connection: Connection? = nil) {
        
        let connectionViewController = factory.connectionViewController(delegate: self,
                                                                              providerViewModel: providerViewModel,
                                                                              connectionType: connectionType,
                                                                              connectionURL: connectionURL,
                                                                              connection: connection)
        modal(connectionViewController)
    }
        
    func didConnectToConnection(_ providerViewModel: ProviderViewModel?, connection: Connection) {
        self.close()
        delegate?.didConnectTo(providerViewModel, connection: connection)
    }
        
    func didNotConnect() {
        self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось подключиться к банку", comment: "Не удалось подключиться к банку"), theme: .error)
    }
    
    func didNotConnect(error: Error) {        
        self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Не удалось подключиться к банку", comment: "Не удалось подключиться к банку"), theme: .error)
    }
}
