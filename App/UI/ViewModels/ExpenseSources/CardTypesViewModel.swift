//
//  CardTypesViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 12.05.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

class CardTypeViewModel {
    let cardType: CardType
    
    var imageName: String {
        return cardType.imageName
    }
    
    init(cardType: CardType) {
        self.cardType = cardType
    }
}

class CardTypesViewModel {
    let cardTypeViewModels: [CardTypeViewModel] = CardType.all.map { CardTypeViewModel(cardType: $0) }
    
    var numberOfItems: Int {
        return cardTypeViewModels.count
    }
    
    func cardTypeViewModel(at indexPath: IndexPath) -> CardTypeViewModel? {
        return cardTypeViewModels[safe: indexPath.item]
    }
}
