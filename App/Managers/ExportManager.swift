//
//  ExportManager.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 23/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import CSV

enum ExportError : Error {
    case canNotCreateFile
    case exportFailed
}

class ExportManager : ExportManagerProtocol {
    func export(transactions: [TransactionViewModel]) -> Promise<URL> {
        
        guard   let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                case let filename = "export\(Int(Date().timeIntervalSince1970)).csv",
                case let fileURL = dir.appendingPathComponent(filename),
                let stream = OutputStream(url: fileURL, append: false),
                let csv = try? CSVWriter(stream: stream) else {
                
                return Promise(error: ExportError.canNotCreateFile)
        }
        
        defer {
            csv.stream.close()
        }
        
        do {
            try csv.write(row: ["Date",
                                "Type",
                                "Source",
                                "Destination",
                                "Amount",
                                "Currency",
                                "Converted Amount",
                                "Converted Currency",
                                "Comment"])
            
            for transaction in transactions.sorted(by: { $0.gotAt <= $1.gotAt }) {
                let amount = transaction.amountCents.moneyDecimalString(with: transaction.currency) ?? "?"
                let convertedAmount = transaction.convertedAmountCents.moneyDecimalString(with: transaction.convertedCurrency) ?? "?"
                try csv.write(row: [transaction.gotAt.iso8601String,
                                    transaction.type.rawValue,
                                    transaction.sourceTitle,
                                    transaction.destinationTitle,
                                    amount,
                                    transaction.currency.code,
                                    convertedAmount,
                                    transaction.convertedCurrency.code,
                                    transaction.comment ?? ""],
                              quotedAtIndex: { _ in true })
            }
        
            return Promise.value(fileURL)
        }
        catch {
            return Promise(error: ExportError.exportFailed)
        }
    }
}
