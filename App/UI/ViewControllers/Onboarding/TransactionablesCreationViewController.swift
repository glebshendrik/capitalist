//
//  TransactionablesCreationViewController.swift
//  Capitalist
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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var examplesCollectionView: UICollectionView!
    @IBOutlet weak var saveButton: HighlightButton!
    @IBOutlet weak var examplesActivityIndicator: UIView!
    @IBOutlet weak var loader: UIImageView!
    @IBOutlet weak var saveButtonTitleLabel: UILabel!
    @IBOutlet weak var addIconView: IconView!
    @IBOutlet weak var addTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        loadData()
    }
    
    @IBAction func didTapAddButton(_ sender: Any) {
        showNewExpenseSource()
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        guard
            viewModel.canGoNext
        else {
            return
        }
        goNext()
    }
        
    func goNext() {
        _ = UIFlowManager.reach(point: .walletsSetup)
        router.route()
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
}

extension TransactionablesCreationViewController {
    func setupUI() {
        saveButtonTitleLabel.text = NSLocalizedString("Продолжить", comment: "")
        setupActivityIndicator()
        setupExamplesCollectionView()
    }
    
    func setupActivityIndicator() {
        loader.showLoader()
    }
    
    func setupExamplesCollectionView() {
        addIconView.backgroundViewColor = .clear
        addIconView.defaultIconName = "plus-icon"
        addTitleLabel.text = NSLocalizedString("Добавить свой кошелек", comment: "")
        examplesCollectionView.delegate = self
        examplesCollectionView.dataSource = self
        examplesCollectionView.fillLayout(columns: 4,
                                          itemHeight: 110,
                                          horizontalInset: 16,
                                          verticalInset: 0,
                                          fillVertically: false)
    }
}

extension TransactionablesCreationViewController {
    func updateUI() {
        updateTitlesUI()
        updateCollectionUI()
        updateNextButtonUI()
    }
    
    func updateTitlesUI() {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }
    
    func updateCollectionUI() {
        examplesCollectionView.reloadData()
    }
    
    func updateNextButtonUI() {
        saveButton.isEnabled = viewModel.nextButtonEnabled
        saveButton.backgroundColor = viewModel.nextButtonEnabled ? UIColor.by(.blue1) : UIColor.by(.gray1)
        saveButton.backgroundColorForNormal = viewModel.nextButtonEnabled ? UIColor.by(.blue1) : UIColor.by(.gray1)
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
        guard
            let cell = examplesCollectionView.dequeueReusableCell(withReuseIdentifier: "TransactionableExampleCollectionViewCell", for: indexPath) as? TransactionableExampleCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.viewModel = viewModel.exampleViewModel(by: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let example = viewModel.exampleViewModel(by: indexPath)
        else {
            return
        }
        guard
            let expenseSource = viewModel.transactionable(by: example) as? ExpenseSourceViewModel
        else {
            showNewExpenseSource(with: example)
            return
        }
        show(expenseSource)
    }
}

extension TransactionablesCreationViewController {
    func showNewExpenseSource() {
        modal(factory.expenseSourceEditViewController(delegate: self,
                                                      expenseSource: nil,
                                                      shouldSkipExamplesPrompt: true))
    }
    
    func showNewExpenseSource(with example: TransactionableExampleViewModel) {
        modal(factory.expenseSourceEditViewController(delegate: self,
                                                      example: example))
    }
    
    func show(_ expenseSource: ExpenseSourceViewModel) {
        modal(factory.expenseSourceInfoViewController(expenseSource: expenseSource))
    }
    
//    func edit(_ expenseSource: ExpenseSourceViewModel) {
//        modal(factory.expenseSourceEditViewController(delegate: self, expenseSource: expenseSource.expenseSource, shouldSkipExamplesPrompt: false))
//    }
}

extension TransactionablesCreationViewController : ExpenseSourceEditViewControllerDelegate {
    func didCreateExpenseSource() {
        loadData()
    }
    
    func didUpdateExpenseSource() {
        loadData()
    }
    
    func didRemoveExpenseSource() {
        loadData()
    }
}
