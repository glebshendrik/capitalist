//
//  QuestionViewModel.swift
//  Capitalist
//
//  Created by Gleb Shendrik on 26.03.2021.
//  Copyright © 2021 Real Tranzit. All rights reserved.
//

import Foundation

class QuestionViewModel {
    
    var title: String
    
    var subtitle: String?
    
    var answer: String?
    
    var type: PollCellType
    
    enum PollCellType: String {
        case title = "WelcomeCollectionViewCell"
        case text = "TutorPollCollectionViewCell"
        case field = "QuestionPollCollectionViewCell"
    }
    
    internal init(title: String, subtitle: String? = nil, answer: String? = nil, type: QuestionViewModel.PollCellType) {
        self.title = title
        self.subtitle = subtitle
        self.answer = answer
        self.type = type
    }
}
