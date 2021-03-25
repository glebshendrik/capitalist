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
    
    var title: String {
        return NSLocalizedString("Привет, я Ник \nСЕО приложения Capitalist", comment: "")
    }
    
    var subtitle: String {
        return NSLocalizedString("Рад, что тебя интересует тема финансового роста и уверен сто с нами ты сможешь больше.\n \nСмотри видео, где за минуту расскажу почему именно я знаю как тебе помочь.", comment: "")
    }
    
    enum PollCellType: String {
        case TITLE = "WelcomeCollectionViewCell"
        case TEXT = "TutorPollCollectionViewCell"
        case FIELD = "QuestionPollCollectionViewCell"
    }
    
    typealias PollScreenData = (title: String, value: String, type: PollCellType)
    
    var questions: [PollScreenData] {
        get {
            return [
                (NSLocalizedString("Привет, я Ник,\nCEO приложения Capitalist", comment: ""), NSLocalizedString("Рад, что тебя интересует тема финансового роста и уверен сто с нами ты сможешь больше.\n \nСмотри видео, где за минуту расскажу почему именно я знаю как тебе помочь.", comment: ""), .TITLE),
                (NSLocalizedString("И чтоб не быть голословным, давай я тебя покажу на примере", comment: ""), NSLocalizedString("Всего 3-и вопроса. И потом на примере будет лучше видна польза от приложения. \nГотов?", comment: ""), .TEXT),
                (NSLocalizedString("Какую сумму пассивного дохода хочешь в месяц?", comment: ""), "", .FIELD),
                (NSLocalizedString("Сколько зарабатываешь сейчас?", comment: ""), "", .FIELD),
                (NSLocalizedString("Сколько остается после всех расходов?", comment: ""), "", .FIELD),
            ]
        }
    }
    
    
    var numberOfPollQuestions: Int {
        return questions.count
    }
    
    init() {
        
    }
}
