//
//  DatePeriodSelectionTableController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 29.12.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol DatePeriodSelectionTableControllerDelegate {
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
    
    var delegate: DatePeriodSelectionTableControllerDelegate?
    
    override func setupUI() {
        super.setupUI()
        setupPeriodField()
        setupUseCustomPeriodField()
        setupFromField()
        setupToField()
    }
        
    private func setupPeriodField() {
        periodField.placeholder = "Период"
        periodField.imageName = "calendar-icon"
        periodField.didTap { [weak self] in
            self?.delegate?.didTapPeriod()
        }
    }
    
    func setupUseCustomPeriodField() {
        useCustomPeriodField.placeholder = "Выбрать между датами"
        useCustomPeriodField.imageName = "edit-info-icon"
        useCustomPeriodField.didSwitch { [weak self] useCustomPeriod in
            self?.delegate?.didChange(useCustomPeriod: useCustomPeriod)
        }
    }
    
    private func setupFromField() {
        fromField.placeholder = "Начало периода"
        fromField.imageName = "calendar-icon"
        fromField.didTap { [weak self] in
            self?.delegate?.didTapFrom()
        }
    }
    
    private func setupToField() {
        toField.placeholder = "Конец периода"
        toField.imageName = "calendar-icon"
        toField.didTap { [weak self] in
            self?.delegate?.didTapTo()
        }
    }
}
