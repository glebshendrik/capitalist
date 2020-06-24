//
//  TransactionEditCalculatorExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 24.06.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

extension TransactionEditViewModel {
    func handleAmount(operation: OperationType) {
        guard let amountCents = amountCents else { return }
        let newAmountCents = operate(previousOperation, base: accumulator, operand: amountCents)
        amount = newAmountCents?.moneyDecimalString(with: sourceCurrency)
        updateCalculator(operation: operation, value: newAmountCents)
    }
    
    func handleConvertedAmount(operation: OperationType) {
        guard let convertedAmountCents = convertedAmountCents else { return }
        let newConvertedAmountCents = operate(previousOperation, base: accumulator, operand: convertedAmountCents)
        convertedAmount = newConvertedAmountCents?.moneyDecimalString(with: destinationCurrency)
        updateCalculator(operation: operation, value: newConvertedAmountCents)
    }
    
    func resetCalculator() {
        accumulator = nil
        previousOperation = nil
    }
    
    private func operate(_ operation: OperationType?, base: Int?, operand: Int) -> Int? {
        guard let base = base, let operation = operation else {
            return operand
        }
        switch operation {
        case .plus:
            return base + operand
        case .minus:
            return base - operand
        case .equal:
            return base
        }
    }
    
    private func updateCalculator(operation: OperationType, value: Int?) {
        accumulator = value
        previousOperation = operation
        
        if operation == .equal {
            resetCalculator()
        }
    }
}
