//
//  TransactionablesCreationViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21.01.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

class TransactionablesCreationViewController : UIViewController, UIFactoryDependantProtocol, UIMessagePresenterManagerDependantProtocol, ApplicationRouterDependantProtocol {
    var router: ApplicationRouterProtocol!
    
    var factory: UIFactoryProtocol!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: TransactionablesCreationViewModel!
    
    @IBOutlet weak var stepTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var currencySelectorView: UIView!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencySymbolLabel: UILabel!
    @IBOutlet weak var examplesCollectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var examplesActivityIndicator: UIView!
    @IBOutlet weak var loader: UIImageView!
    
    @IBOutlet weak var currencySelectorHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        loadData()
    }
    
    @IBAction func didTapCurrencyButton(_ sender: Any) {
        modal(factory.currenciesViewController(delegate: self))
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        goNext()
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        goBack()
    }
    
    func goBack() {
        guard let previousTransactionableType = viewModel.previousStepTransactionableType() else {
            return
        }
        viewModel.set(transactionableType: previousTransactionableType)
        updateBackButtonUI()
        loadData()
    }
    
    func goNext() {
        guard let nextTransactionableType = viewModel.nextStepTransactionableType() else {
            _ = UIFlowManager.reach(point: .dataSetup)
            router.route()
            return
        }
        viewModel.set(transactionableType: nextTransactionableType)
        updateBackButtonUI()
        loadData()
    }
    
    func setupUI() {
        setupActivityIndicator()
        setupExamplesCollectionView()
    }
    
    func setupActivityIndicator() {
        loader.showLoader()
    }
    
    func setupExamplesCollectionView() {
        examplesCollectionView.delegate = self
        examplesCollectionView.dataSource = self
        examplesCollectionView.fillLayout(columns: 4,
                                          itemHeight: 110,
                                          horizontalInset: 16,
                                          verticalInset: 0,
                                          fillVertically: false)        
    }
    
    func updateUI() {
        updateTitlesUI()
        updateCurrencySelectorUI()
        updateCollectionUI()
        updateBackButtonUI()
    }
    
    func updateBackButtonUI() {
        backButton.isHidden = viewModel.backButtonHidden
    }
    
    func updateCollectionUI() {
        examplesCollectionView.reloadData()
    }
    
    func loadData() {
        set(examplesActivityIndicator, hidden: false)
        firstly {
            viewModel.loadData()
        }.catch { e in
            print(e)
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки данных", comment: "Ошибка загрузки данных"), theme: .error)
        }.finally {
            self.updateUI()
            self.set(self.examplesActivityIndicator, hidden: true)
        }
    }
    
    func loadCollectionData() {
        set(examplesActivityIndicator, hidden: false)
        firstly {
            viewModel.loadCollectionsData()
        }.catch { e in
            print(e)
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки данных", comment: "Ошибка загрузки данных"), theme: .error)
        }.finally {
            self.updateCollectionUI()
            self.updateBackButtonUI()
            self.set(self.examplesActivityIndicator, hidden: true)
        }
    }
    
    func updateTitlesUI() {
        stepTitleLabel.text = viewModel.stepTitle
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }
    
    func updateCurrencySelectorUI() {
        currencyNameLabel.text = viewModel.currencyName
        currencySymbolLabel.text = viewModel.currencySymbol
        
        UIView.animate( withDuration: 0.3,
                        delay: 0.0,
                        options: [.curveEaseInOut],
                        animations: {
                            self.currencySelectorHeightConstraint.constant = self.viewModel.currencySelectorHidden ? 0 : 88
                            self.view.layoutIfNeeded()
                        },
                        completion: nil)        
    }
}

extension TransactionablesCreationViewController : CurrenciesViewControllerDelegate {
    func didSelectCurrency(currency: Currency) {
        update(currency: currency)
    }
    
    func update(currency: Currency) {
        dirtyUpdate(currency: currency)
        set(examplesActivityIndicator, hidden: false)
        
        firstly {
            viewModel.update(currency: currency)
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Возникла проблема при обновлении валюты", comment: "Возникла проблема при обновлении валюты"), theme: .error)
        }.finally {
            self.set(self.examplesActivityIndicator, hidden: true)
            self.updateCurrencySelectorUI()
        }
    }
    
    private func dirtyUpdate(currency: Currency) {
        currencyNameLabel.text = currency.translatedName
        currencySymbolLabel.text = currency.symbol
    }
}

extension TransactionablesCreationViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfExamples
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard   let cell = examplesCollectionView.dequeueReusableCell(withReuseIdentifier: "TransactionableExampleCollectionViewCell", for: indexPath) as? TransactionableExampleCollectionViewCell else {
                
                return UICollectionViewCell()
        }
        cell.viewModel = viewModel.exampleViewModel(by: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let exampleViewModel = viewModel.exampleViewModel(by: indexPath) else { return }
        
        guard let transactionable = viewModel.transactionable(by: exampleViewModel.name) else {
            showNewTransactionable(with: exampleViewModel)
            return
        }
        showEdit(transactionable)
    }
    
    func showNewTransactionable(with example: TransactionableExampleViewModel) {
        switch viewModel.transactionableType {
        case .incomeSource:
            showNewIncomeSourceScreen(with: example)
        case .expenseSource:
            showNewExpenseSourceScreen(with: example)
        case .expenseCategory:
            showNewExpenseCategoryScreen(with: example, basketType: .joy)
        default:
            return
        }
    }
    
    func showEdit(_ transactionable: Transactionable) {
        switch transactionable {
        case let incomeSourceViewModel as IncomeSourceViewModel:
            showEditScreen(incomeSource: incomeSourceViewModel.incomeSource)
        case let expenseSourceViewModel as ExpenseSourceViewModel:
            showEditScreen(expenseSource: expenseSourceViewModel.expenseSource)
        case let expenseCategoryViewModel as ExpenseCategoryViewModel:
            showEditScreen(expenseCategory: expenseCategoryViewModel.expenseCategory, basketType: .joy)
        default:
            return
        }
    }
}

extension TransactionablesCreationViewController {
    func showNewIncomeSourceScreen(with example: TransactionableExampleViewModel) {
        modal(factory.incomeSourceEditViewController(delegate: self, example: example))
    }
    
    func showEditScreen(incomeSource: IncomeSource?) {
        modal(factory.incomeSourceEditViewController(delegate: self, incomeSource: incomeSource))
    }
}

extension TransactionablesCreationViewController {
    func showNewExpenseSourceScreen(with example: TransactionableExampleViewModel) {
        modal(factory.expenseSourceEditViewController(delegate: self, example: example))
    }
    
    func showEditScreen(expenseSource: ExpenseSource?) {
        modal(factory.expenseSourceEditViewController(delegate: self, expenseSource: expenseSource))
    }
}

extension TransactionablesCreationViewController {
    func showNewExpenseCategoryScreen(with example: TransactionableExampleViewModel, basketType: BasketType) {
        modal(factory.expenseCategoryEditViewController(delegate: self, example: example, basketType: basketType))
    }
        
    func showEditScreen(expenseCategory: ExpenseCategory?, basketType: BasketType) {
        modal(factory.expenseCategoryEditViewController(delegate: self, expenseCategory: expenseCategory, basketType: basketType))
    }
}

extension TransactionablesCreationViewController : IncomeSourceEditViewControllerDelegate {
    func didCreateIncomeSource() {
        loadCollectionData()
    }
    
    func didUpdateIncomeSource() {
        loadCollectionData()
    }
    
    func didRemoveIncomeSource() {
        loadCollectionData()
    }
}

extension TransactionablesCreationViewController : ExpenseSourceEditViewControllerDelegate {
    func didCreateExpenseSource() {
        loadCollectionData()
    }
    
    func didUpdateExpenseSource() {
        loadCollectionData()
    }
    
    func didRemoveExpenseSource() {
        loadCollectionData()
    }
}

extension TransactionablesCreationViewController : ExpenseCategoryEditViewControllerDelegate {
    func didCreateExpenseCategory(with basketType: BasketType, name: String) {
        loadCollectionData()
    }
    
    func didUpdateExpenseCategory(with basketType: BasketType) {
        loadCollectionData()
    }
    
    func didRemoveExpenseCategory(with basketType: BasketType) {
        loadCollectionData()
    }
}
