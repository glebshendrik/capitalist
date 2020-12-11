//
//  PrototypeLinkTableViewCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 09.12.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

protocol PrototypeLinkTableViewCellDelegate : class {
    func didTapLinkingButton(linkingTransactionable: LinkingTransactionableViewModel)
}

class PrototypeLinkTableViewCell : UITableViewCell {
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var linkButton: HighlightButton!
    
    weak var delegate: PrototypeLinkTableViewCellDelegate?
    
    var viewModel: LinkingTransactionableViewModel? {
        didSet {
            updateUI()
        }
    }
    
    @IBAction func didTapLinkingButton(_ sender: Any) {
        guard
            let viewModel = viewModel
        else {
            return
        }
        delegate?.didTapLinkingButton(linkingTransactionable: viewModel)
    }
}

extension PrototypeLinkTableViewCell {
    private func updateUI() {
        guard
            let viewModel = viewModel
        else {
            return
        }
        updateTitleUI(viewModel)
        updateIconUI(viewModel)
        updateLinkButtonUI(viewModel)
    }
    
    private func updateTitleUI(_ viewModel: LinkingTransactionableViewModel) {
        titleLabel.text = viewModel.title
    }
    
    private func updateIconUI(_ viewModel: LinkingTransactionableViewModel) {
        iconView.iconURL = viewModel.iconURL
        iconView.defaultIconName = viewModel.defaultIconName
    }
    
    private func updateLinkButtonUI(_ viewModel: LinkingTransactionableViewModel) {
        linkButton.setTitle(viewModel.linkButtonTitle, for: .normal)
        linkButton.backgroundColorForNormal = UIColor.by(viewModel.linkButtonColorAsset)
    }
}
