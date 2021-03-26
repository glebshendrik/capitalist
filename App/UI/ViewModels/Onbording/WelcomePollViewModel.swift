//
//  WelcomePollViewModel.swift
//  Capitalist
//
//  Created by Gleb Shendrik on 23.03.2021.
//  Copyright © 2021 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class WelcomePollViewModel {
    
    enum PollCellType: String {
        case title = "WelcomeCollectionViewCell"
        case text = "TutorPollCollectionViewCell"
        case field = "QuestionPollCollectionViewCell"
    }
    
    private var questions: [QuestionViewModel] {
        return [
            QuestionViewModel(title: NSLocalizedString("Привет, я Ник,\nCEO приложения Capitalist", comment: ""), subtitle: NSLocalizedString("Рад, что тебя интересует тема финансового роста и уверен сто с нами ты сможешь больше.\n \nСмотри видео, где за минуту расскажу почему именно я знаю как тебе помочь.", comment: ""), type: .title),
            QuestionViewModel(title: NSLocalizedString("И чтоб не быть голословным, давай я тебя покажу на примере", comment: ""), subtitle: NSLocalizedString("Всего 3-и вопроса. И потом на примере будет лучше видна польза от приложения. \nГотов?", comment: ""), type: .text),
            QuestionViewModel(title: NSLocalizedString("Какую сумму пассивного дохода хочешь в месяц?", comment: ""), type: .field),
            QuestionViewModel(title: NSLocalizedString("Сколько зарабатываешь сейчас?", comment: ""), type: .field),
            QuestionViewModel(title: NSLocalizedString("Сколько остается после всех расходов?", comment: ""), type: .field),
        ]
    }
    
    
    var numberOfPollQuestions: Int {
        return questions.count
    }
    
    var currentIndex: Int = 0
    
    var nextIndexPath: IndexPath {
        currentIndex += 1
        return IndexPath(row: currentIndex, section: 0)
    }
    
    var backIndexPath: IndexPath {
        currentIndex -= currentIndex != 0 ? 1 : 0
        return IndexPath(row: currentIndex, section: 0)
    }
    
    var dataCell: QuestionViewModel {
        return questions[currentIndex]
    }
    
    var isLastPageShown: Bool {
        return currentIndex + 1 == questions.count ? true : false
    }
    
    init() {
        
    }
}
