//
//  StatisticsExportingExtension.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 23/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import PromiseKit

extension StatisticsViewController {
    func exportTransactions() {
        _ = firstly {
                viewModel.exportTransactions()
            }.get { fileURL in
                var filesToShare = [Any]()
                filesToShare.append(fileURL)

                let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
            }.catch { _ in
                self.messagePresenterManager.show(navBarMessage: "Ошибка экспорта данных", theme: .error)
            }
    }
}
