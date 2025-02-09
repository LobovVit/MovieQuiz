//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Vitaly on 15/08/2024.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
