//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Vitaly on 15/08/2024.
//

import Foundation

class StatisticService: StatisticServiceProtocol {
    
    private enum Keys: String {
        case correct
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
    }
    
    private let storage: UserDefaults = .standard
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correct.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var totalAccuracy: Double {
        get {
            if gamesCount != 0 {
                return Double(correctAnswers) / (Double(gamesCount) * 10) * 100
            } else {
                return Double(correctAnswers) / 10 * 100
            }
        }
    }
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
            }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        correctAnswers += count
        gamesCount += 1
        let currentGame: GameResult = GameResult(correct: count,total: amount,date: Date())
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
}
