//
//  StatisticsExportingExtension.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 23/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

extension StatisticsViewController {
    func exportTransactions() {
        self.messagePresenterManager.showHUD(with: "Подготовка статистики к экспорту")
        
        _ = Promise { seal in
                DispatchQueue.global(qos: .background).async {
                    self.viewModel.exportTransactions().pipe(to: seal.resolve)
                }
            }.get { fileURL in
                self.share(fileURL)
            }.catch { _ in
                self.messagePresenterManager.show(navBarMessage: "Ошибка экспорта данных", theme: .error)
            }.finally {
                self.messagePresenterManager.dismissHUD()
            }
    }
    
    private func share(_ fileURL: URL) {
        var filesToShare = [Any]()
        filesToShare.append(fileURL)
        
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
}
