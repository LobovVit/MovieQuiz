//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Vitaly on 11/09/2024.
//

import UIKit

class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers = 0
    private var statisticService:StatisticService = StatisticServiceImplementation()
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    
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
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        self.currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // MARK: - private functions
    
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
            guard let self = self else { return }
            self.viewController?.hideLoadingIndicator()
            self.showNextQuestionOrResults()
        }
    }
    
    // MARK: - functions
    
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
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
}
