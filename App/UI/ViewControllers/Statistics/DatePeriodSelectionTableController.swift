//
//  DatePeriodSelectionTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 29.12.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol DatePeriodSelectionTableControllerDelegate : class {
    func didTapPeriod()
    func didChange(useCustomPeriod: Bool)
    func didTapFrom()
    func didTapTo()
}

class DatePeriodSelectionTableController : FormFieldsTableViewController {
    @IBOutlet weak var periodField: FormTapField!
    @IBOutlet weak var useCustomPeriodField: FormSwitchValueField!
    @IBOutlet weak var fromField: FormTapField!
    @IBOutlet weak var toField: FormTapField!
    
    weak var delegate: DatePeriodSelectionTableControllerDelegate?
    
    override func setupUI() {
        super.setupUI()
        setupPeriodField()
        setupUseCustomPeriodField()
        setupFromField()
        setupToField()
    }
        
    private func setupPeriodField() {
        periodField.placeholder = NSLocalizedString("Период", comment: "Период")
        periodField.imageName = "calendar-icon"
        periodField.didTap { [weak self] in
            self?.delegate?.didTapPeriod()
        }
    }
    
    func setupUseCustomPeriodField() {
        useCustomPeriodField.placeholder = NSLocalizedString("Выбрать между датами", comment: "Выбрать между датами")
        useCustomPeriodField.imageName = "edit-info-icon"
        useCustomPeriodField.didSwitch { [weak self] useCustomPeriod in
            self?.delegate?.didChange(useCustomPeriod: useCustomPeriod)
        }
    }
    
    private func setupFromField() {
        fromField.placeholder = NSLocalizedString("Начало периода", comment: "Начало периода")
        fromField.imageName = "calendar-icon"
        fromField.didTap { [weak self] in
            self?.delegate?.didTapFrom()
        }
    }
    
    private func setupToField() {
        toField.placeholder = NSLocalizedString("Конец периода", comment: "Конец периода")
        toField.imageName = "calendar-icon"
        toField.didTap { [weak self] in
            self?.delegate?.didTapTo()
        }
    }
}
