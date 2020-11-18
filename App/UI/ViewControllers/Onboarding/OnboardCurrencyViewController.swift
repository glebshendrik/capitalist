//
//  OnboardCurrencyViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 16.11.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import BEMCheckBox
import AttributedTextView

class OnboardCurrencyViewController : UIViewController, UIFactoryDependantProtocol, UIMessagePresenterManagerDependantProtocol, ApplicationRouterDependantProtocol {
    
    var router: ApplicationRouterProtocol!
    var factory: UIFactoryProtocol!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var viewModel: OnboardCurrencyViewModel!
        
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var currencySelectorView: UIView!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencySymbolLabel: UILabel!
    @IBOutlet weak var saveButton: HighlightButton!
    @IBOutlet weak var acceptRulesCheckBox: BEMCheckBox!
    @IBOutlet weak var rulesTextView: AttributedTextView!
    
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
        onboardUser()
    }
    
    @IBAction func didCheckRules(_ sender: Any) {
        update(areRulesChecked: acceptRulesCheckBox.on)
    }
    
    @IBAction func didTapCheckRulesButton(_ sender: Any) {
        acceptRulesCheckBox.setOn(!acceptRulesCheckBox.on, animated: true)
        update(areRulesChecked: acceptRulesCheckBox.on)
    }
    
    private func update(areRulesChecked: Bool) {
        viewModel.areRulesChecked = areRulesChecked
        updateUI()
    }
}

extension OnboardCurrencyViewController {
    func setupUI() {
        acceptRulesCheckBox.setOn(viewModel.areRulesChecked, animated: false)
        acceptRulesCheckBox.animationDuration = 0.2
        
        let agreeText = NSLocalizedString("Я согласен с ", comment: "")
        let termsOfUseText = NSLocalizedString("Пользовательским соглашением", comment: "")
        let andText = NSLocalizedString(" и ", comment: "")
        let policyText = NSLocalizedString("Политикой конфиденциальности", comment: "")
                
        rulesTextView.attributer =
            agreeText
            .append(string: termsOfUseText).makeInteract { _ in
                self.show(url: NSLocalizedString("terms of service url", comment: "terms of service url"))
            }
            .underline
            .append(andText)
            .append(policyText).makeInteract { _ in
                self.show(url: NSLocalizedString("privacy policy url", comment: "privacy policy url"))
            }
            .underline
            .all
            .font(UIFont(name: "Roboto-Light", size: 14))
            .color(UIColor.by(.white100))
            .setLinkColor(UIColor.by(.white64))
        
    }
}

extension OnboardCurrencyViewController {
    func updateUI() {
        updateTitlesUI()
        updateCurrencySelectorUI()
        updateSaveButtonUI()
    }
    
    func updateTitlesUI() {
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
                            self.currencySelectorHeightConstraint.constant = 88
                            self.view.layoutIfNeeded()
                        },
                        completion: nil)
    }
    
    func updateSaveButtonUI() {
        saveButton.setTitle(NSLocalizedString("Продолжить", comment: ""), for: .normal)
        saveButton.isEnabled = viewModel.saveButtonEnabled
        saveButton.backgroundColor = viewModel.saveButtonEnabled ? UIColor.by(.blue1) : UIColor.by(.gray1)
        saveButton.backgroundColorForNormal = viewModel.saveButtonEnabled ? UIColor.by(.blue1) : UIColor.by(.gray1)
    }
}

extension OnboardCurrencyViewController {
    func loadData() {
        showHUD()
        firstly {
            viewModel.loadData()
        }.catch { e in
            print(e)
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки данных", comment: "Ошибка загрузки данных"), theme: .error)
        }.finally {
            self.updateUI()
            self.dismissHUD()
        }
    }
    
    func onboardUser() {
        showHUD()
        firstly {
            viewModel.onboardUser()
        }.catch { e in
            print(e)
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Ошибка загрузки данных", comment: "Ошибка загрузки данных"), theme: .error)
        }.finally {
            self.updateUI()
            self.dismissHUD()
            _ = UIFlowManager.reach(point: .dataSetup)
            _ = UIFlowManager.reach(point: .agreedRules)
            self.router.route()
        }
    }
}

extension OnboardCurrencyViewController : CurrenciesViewControllerDelegate {
    func didSelectCurrency(currency: Currency) {
        update(currency: currency)
    }
    
    func update(currency: Currency) {
        dirtyUpdate(currency: currency)
        showHUD()
        firstly {
            viewModel.update(currencyCode: currency.code)
        }.catch { _ in
            self.messagePresenterManager.show(navBarMessage: NSLocalizedString("Возникла проблема при обновлении валюты", comment: "Возникла проблема при обновлении валюты"), theme: .error)
        }.finally {
            self.dismissHUD()
            self.updateCurrencySelectorUI()
        }
    }
    
    private func dirtyUpdate(currency: Currency) {
        currencyNameLabel.text = currency.translatedName
        currencySymbolLabel.text = currency.symbol
    }
}
