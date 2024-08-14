import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    // MARK: - Lifecycle
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.questionFactory = QuestionFactory(delegate: self)
        self.alertPresenter = AlertPresenter(delegate: self)
        
        questionFactory?.requestNextQuestion()

    }
    
    // MARK: QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        self.show(quiz: viewModel)
    }
    
    // MARK: AlertPresenterDelegate
    func presentAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
        
    // MARK: IBActions
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    
    // MARK: private functions
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                          question: model.text,
                          questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.ypBackground.cgColor
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        alertPresenter?.showAlert(quiz: AlertModel(title: result.buttonText,
                                                    message: result.text,
                                                    buttonText: result.buttonText,
                                                    completion: { [weak self] in
                                                                    guard let self = self else { return }
            
                                                                    currentQuestionIndex = 0
                                                                    correctAnswers = 0
                                                                    questionFactory?.requestNextQuestion()
                                                                }
                                                   )
        )
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        yesButton.isEnabled = false
        noButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        if currentQuestionIndex == questionsAmount - 1 {
            show(quiz: QuizResultsViewModel(title: "Этот раунд окончен!",
                                            text: correctAnswers == questionsAmount ?
                                                "Поздравляем, вы ответили на \(questionsAmount) из \(questionsAmount)!" :
                                                "Вы ответили на \(correctAnswers) из \(questionsAmount), попробуйте ещё раз!",
                                            buttonText: "Сыграть ещё раз"))
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
        
    }
}
