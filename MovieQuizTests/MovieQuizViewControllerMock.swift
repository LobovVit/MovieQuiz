//
//  MovieQuizViewControllerMock.swift
//  MovieQuizTests
//
//  Created by Vitaly on 13/09/2024.
//

import Foundation
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {}
    func show(quiz result: QuizResultsViewModel) {}
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func showNetworkError(message: String) {}
}
