//
//  CustomRecurrenceViewController.swift
//  RecurrencePicker
//
//  Created by Xin Hong on 16/4/7.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import EventKit

internal protocol CustomRecurrenceViewControllerDelegate: class {
    func customRecurrenceViewController(_ controller: CustomRecurrenceViewController, didPickRecurrence recurrenceRule: RecurrenceRule)
}

internal class CustomRecurrenceViewController: UITableViewController {
    internal weak var delegate: CustomRecurrenceViewControllerDelegate?
    internal var occurrenceDate: Date!
    internal var tintColor: UIColor!
    internal var recurrenceRule: RecurrenceRule!
    internal var backgroundColor: UIColor?
    internal var separatorColor: UIColor?
    internal var supportedFrequencies = Constant.frequencies
    internal var maximumInterval = Constant.pickerMaxRowCount

    fileprivate var isShowingPickerView = false
    fileprivate var pickerViewStyle: PickerViewCellStyle = .frequency
    fileprivate var isShowingFrequencyPicker: Bool {
        return isShowingPickerView && pickerViewStyle == .frequency
    }
    fileprivate var isShowingIntervalPicker: Bool {
        return isShowingPickerView && pickerViewStyle == .interval
    }
    fileprivate var frequencyCell: UITableViewCell? {
        return tableView.cellForRow(at: IndexPath(row: 0, section: 0))
    }
    fileprivate var intervalCell: UITableViewCell? {
        return isShowingFrequencyPicker ? tableView.cellForRow(at: IndexPath(row: 2, section: 0)) : tableView.cellForRow(at: IndexPath(row: 1, section: 0))
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()        
    }

    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            // navigation is popped
            delegate?.customRecurrenceViewController(self, didPickRecurrence: recurrenceRule)
        }
    }
}

extension CustomRecurrenceViewController {
    // MARK: - Table view helper
    fileprivate func isPickerViewCell(at indexPath: IndexPath) -> Bool {
        guard indexPath.section == 0 && isShowingPickerView else {
            return false
        }
        return pickerViewStyle == .frequency ? indexPath.row == 1 : indexPath.row == 2
    }

    fileprivate func isSelectorViewCell(at indexPath: IndexPath) -> Bool {
        guard recurrenceRule.frequency == .monthly || recurrenceRule.frequency == .yearly else {
            return false
        }
        return indexPath == IndexPath(row: 0, section: 1)
    }

    fileprivate func unfoldPickerView() {
        switch pickerViewStyle {
        case .frequency:
            tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
        case .interval:
            tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
        }
    }

    fileprivate func foldPickerView() {
        switch pickerViewStyle {
        case .frequency:
            tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
        case .interval:
            tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
        }
    }

    fileprivate func updateSelectorSection(with newFrequency: RecurrenceFrequency) {
        tableView.beginUpdates()
        switch newFrequency {
        case .daily:
            if tableView.numberOfSections == 2 {
                tableView.deleteSections(IndexSet(integer: 1), with: .fade)
            }
        case .weekly, .monthly, .yearly:
            if tableView.numberOfSections == 1 {
                tableView.insertSections(IndexSet(integer: 1), with: .fade)
            } else {
                tableView.reloadSections(IndexSet(integer: 1), with: .fade)
            }
        default:
            break
        }
        tableView.endUpdates()
    }

    fileprivate func unitStringForIntervalCell() -> String {
        if recurrenceRule.interval == 1 {
            return Constant.unitStrings()[recurrenceRule.frequency.number]
        }
        let pluralUnit = Constant.pluralUnitStrings(interval: recurrenceRule.interval)[recurrenceRule.frequency.number]
        if InternationalControl.shared.language == .russian {
            return String(format: pluralUnit, recurrenceRule.interval.description)
        }        
        return String(recurrenceRule.interval) + " " + Constant.pluralUnitStrings(interval: recurrenceRule.interval)[recurrenceRule.frequency.number]
    }

    fileprivate func updateDetailTextColor() {
        frequencyCell?.detailTextLabel?.textColor = isShowingFrequencyPicker ? tintColor : Constant.detailTextColor
        intervalCell?.detailTextLabel?.textColor = isShowingIntervalPicker ? tintColor : Constant.detailTextColor
    }

    fileprivate func updateFrequencyCellText() {
        frequencyCell?.detailTextLabel?.text = Constant.frequencyStrings()[recurrenceRule.frequency.number]
    }

    fileprivate func updateIntervalCellText() {
        intervalCell?.detailTextLabel?.text = unitStringForIntervalCell()
    }

    fileprivate func updateRecurrenceRuleText() {
        let footerView = tableView.footerView(forSection: 0)

        tableView.beginUpdates()
        footerView?.textLabel?.text = recurrenceRule.toText(occurrenceDate: occurrenceDate)
        tableView.endUpdates()
        footerView?.setNeedsLayout()
    }
}

extension CustomRecurrenceViewController {
    // MARK: - Table view data source and delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        if recurrenceRule.frequency == .daily {
            return 1
        }
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return isShowingPickerView ? 3 : 2
        } else {
            switch recurrenceRule.frequency {
            case .weekly: return Constant.weekdaySymbols().count
            case .monthly, .yearly: return 1
            default: return 0
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isPickerViewCell(at: indexPath) {
            return Constant.pickerViewCellHeight
        } else if isSelectorViewCell(at: indexPath) {
            let style: MonthOrDaySelectorStyle = recurrenceRule.frequency == .monthly ? .day : .month
            let itemHeight = GridSelectorLayout.itemSize(with: style, selectorViewWidth: tableView.frame.width).height
            let itemCount: CGFloat = style == .day ? 5 : 3
            return ceil(itemHeight * itemCount) + Constant.selectorVerticalPadding * CGFloat(2)
        }
        return Constant.defaultRowHeight
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return recurrenceRule.toText(occurrenceDate: occurrenceDate)
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isPickerViewCell(at: indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellID.pickerViewCell, for: indexPath) as! PickerViewCell
            cell.delegate = self

            cell.style = pickerViewStyle
            cell.frequency = recurrenceRule.frequency
            cell.interval = recurrenceRule.interval
            let supportedFrequencies: [RecurrenceFrequency] = {
                let frequencies = self.supportedFrequencies.filter { Constant.frequencies.contains($0) }.sorted { $0.number < $1.number }
                return frequencies.isEmpty ? Constant.frequencies : frequencies
            }()
            cell.supportedFrequencies = supportedFrequencies
            cell.maximumInterval = max(maximumInterval, 1)

            return cell
        } else if isSelectorViewCell(at: indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellID.monthOrDaySelectorCell, for: indexPath) as! MonthOrDaySelectorCell
            cell.delegate = self

            cell.tintColor = tintColor
            cell.style = recurrenceRule.frequency == .monthly ? .day : .month
            cell.bymonthday = recurrenceRule.bymonthday
            cell.bymonth = recurrenceRule.bymonth

            return cell
        } else if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: CellID.customRecurrenceViewCell)
            if cell == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: CellID.customRecurrenceViewCell)
            }
            cell?.accessoryType = .none

            if indexPath.row == 0 {
                cell?.textLabel?.text = LocalizedString("CustomRecurrenceViewController.textLabel.frequency")
                cell?.detailTextLabel?.text = Constant.frequencyStrings()[recurrenceRule.frequency.number]
                cell?.detailTextLabel?.textColor = isShowingFrequencyPicker ? tintColor : Constant.detailTextColor
            } else {
                cell?.textLabel?.text = LocalizedString("CustomRecurrenceViewController.textLabel.interval")
                cell?.detailTextLabel?.text = unitStringForIntervalCell()
                cell?.detailTextLabel?.textColor = isShowingIntervalPicker ? tintColor : Constant.detailTextColor
            }

            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: CellID.commonCell)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: CellID.commonCell)
            }

            cell?.textLabel?.text = Constant.weekdaySymbols()[indexPath.row]
            if recurrenceRule.byweekday.contains(Constant.weekdays[indexPath.row]) {
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }

            return cell!
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isPickerViewCell(at: indexPath) else {
            return
        }
        guard !isSelectorViewCell(at: indexPath) else {
            return
        }

        tableView.deselectRow(at: indexPath, animated: true)

        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if isShowingFrequencyPicker {
                    tableView.beginUpdates()
                    isShowingPickerView = false
                    foldPickerView()
                    tableView.endUpdates()
                } else {
                    tableView.beginUpdates()
                    if isShowingIntervalPicker {
                        foldPickerView()
                    }
                    isShowingPickerView = true
                    pickerViewStyle = .frequency
                    unfoldPickerView()
                    tableView.endUpdates()
                }
                updateDetailTextColor()
            } else {
                if isShowingIntervalPicker {
                    tableView.beginUpdates()
                    isShowingPickerView = false
                    foldPickerView()
                    tableView.endUpdates()
                } else {
                    tableView.beginUpdates()
                    if isShowingFrequencyPicker {
                        foldPickerView()
                    }
                    isShowingPickerView = true
                    pickerViewStyle = .interval
                    unfoldPickerView()
                    tableView.endUpdates()
                }
                updateDetailTextColor()
            }
        } else if indexPath.section == 1 {
            if isShowingPickerView {
                tableView.beginUpdates()
                isShowingPickerView = false
                foldPickerView()
                tableView.endUpdates()
                updateDetailTextColor()
            }

            let weekday = Constant.weekdays[indexPath.row]
            if recurrenceRule.byweekday.contains(weekday) {
                if recurrenceRule.byweekday == [weekday] {
                    return
                }
                let index = recurrenceRule.byweekday.firstIndex(of: weekday)!
                recurrenceRule.byweekday.remove(at: index)
                cell?.accessoryType = .none
                updateRecurrenceRuleText()
            } else {
                recurrenceRule.byweekday.append(weekday)
                cell?.accessoryType = .checkmark
                updateRecurrenceRuleText()
            }
        }
    }
}

extension CustomRecurrenceViewController {
    // MARK: - Helper
    fileprivate func commonInit() {
        navigationItem.title = LocalizedString("RecurrencePicker.textLabel.custom")
        navigationController?.navigationBar.tintColor = tintColor
        navigationItem.backBarButtonItem?.title = " "
        tableView.tintColor = tintColor
        if let backgroundColor = backgroundColor {
            tableView.backgroundColor = backgroundColor
        }
        if let separatorColor = separatorColor {
            tableView.separatorColor = separatorColor
        }

        let bundle = Bundle(for: RecurrencePicker.self)
        tableView.register(UINib(nibName: "PickerViewCell", bundle: bundle), forCellReuseIdentifier: CellID.pickerViewCell)
        tableView.register(UINib(nibName: "MonthOrDaySelectorCell", bundle: bundle), forCellReuseIdentifier: CellID.monthOrDaySelectorCell)
    }
}

extension CustomRecurrenceViewController: PickerViewCellDelegate {
    func pickerViewCell(_ cell: PickerViewCell, didSelectFrequency frequency: RecurrenceFrequency) {
        recurrenceRule.frequency = frequency

        updateFrequencyCellText()
        updateIntervalCellText()
        updateSelectorSection(with: frequency)
        updateRecurrenceRuleText()
    }

    func pickerViewCell(_ cell: PickerViewCell, didSelectInterval interval: Int) {
        recurrenceRule.interval = interval

        updateIntervalCellText()
        updateRecurrenceRuleText()
    }
}

extension CustomRecurrenceViewController: MonthOrDaySelectorCellDelegate {
    func monthOrDaySelectorCell(_ cell: MonthOrDaySelectorCell, didSelectMonthday monthday: Int) {
        if isShowingPickerView {
            tableView.beginUpdates()
            isShowingPickerView = false
            foldPickerView()
            tableView.endUpdates()
            updateDetailTextColor()
        }
        recurrenceRule.bymonthday.append(monthday)
        updateRecurrenceRuleText()
    }

    func monthOrDaySelectorCell(_ cell: MonthOrDaySelectorCell, didDeselectMonthday monthday: Int) {
        if isShowingPickerView {
            tableView.beginUpdates()
            isShowingPickerView = false
            foldPickerView()
            tableView.endUpdates()
            updateDetailTextColor()
        }
        if let index = recurrenceRule.bymonthday.firstIndex(of: monthday) {
            recurrenceRule.bymonthday.remove(at: index)
            updateRecurrenceRuleText()
        }
    }

    func monthOrDaySelectorCell(_ cell: MonthOrDaySelectorCell, shouldDeselectMonthday monthday: Int) -> Bool {
        return recurrenceRule.bymonthday.count > 1
    }

    func monthOrDaySelectorCell(_ cell: MonthOrDaySelectorCell, didSelectMonth month: Int) {
        if isShowingPickerView {
            tableView.beginUpdates()
            isShowingPickerView = false
            foldPickerView()
            tableView.endUpdates()
            updateDetailTextColor()
        }
        recurrenceRule.bymonth.append(month)
        updateRecurrenceRuleText()
    }

    func monthOrDaySelectorCell(_ cell: MonthOrDaySelectorCell, didDeselectMonth month: Int) {
        if isShowingPickerView {
            tableView.beginUpdates()
            isShowingPickerView = false
            foldPickerView()
            tableView.endUpdates()
            updateDetailTextColor()
        }
        if let index = recurrenceRule.bymonth.firstIndex(of: month) {
            recurrenceRule.bymonth.remove(at: index)
            updateRecurrenceRuleText()
        }
    }

    func monthOrDaySelectorCell(_ cell: MonthOrDaySelectorCell, shouldDeselectMonth month: Int) -> Bool {
        return recurrenceRule.bymonth.count > 1
    }
}

extension CustomRecurrenceViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (_) in

            }) { (_) in
                let frequency = self.recurrenceRule.frequency
                if frequency == .monthly || frequency == .yearly {
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? MonthOrDaySelectorCell {
                        cell.style = frequency == .monthly ? .day : .month
                    }
                }
        }
    }
}
