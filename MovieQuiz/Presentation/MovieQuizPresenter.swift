//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Vitaly on 11/09/2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    private var statisticService: StatisticService = StatisticServiceImplementation()
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        
        self.currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Private methods
    
    private func didAnswer(isCorrectAnswer: Bool) {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = isCorrectAnswer
        if givenAnswer == currentQuestion.correctAnswer {correctAnswers += 1}
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            
            viewController?.show(quiz: QuizResultsViewModel(title: "Этот раунд окончен!",
                                                            text: makeResultsMessage(),
                                                            buttonText: "Сыграть ещё раз"))
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: self.questionsAmount)
        let congratulationText = correctAnswers == self.questionsAmount ?
        "Поздравляем, вы ответили на \(correctAnswers) из \(self.questionsAmount)!" :
        "Ваш результат: \(correctAnswers) из \(self.questionsAmount), попробуйте ещё раз!"
        let resultText = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let recordText = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total)(\(statisticService.bestGame.date.dateTimeString))"
        let accuracyText = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        return [congratulationText, resultText, recordText, accuracyText].joined(separator: "\n")
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer:isCorrect)
        viewController?.showLoadingIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.viewController?.hideLoadingIndicator()
            self.showNextQuestionOrResults()
        }
    }
    
    // MARK: - Internal methods
    
    func restartGame() {
        correctAnswers = 0
        currentQuestionIndex = 0
        questionFactory?.requestNextQuestion()
    }
    
    func noButtonClicked() {
        didAnswer(isCorrectAnswer: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isCorrectAnswer: true)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        .init(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
}
