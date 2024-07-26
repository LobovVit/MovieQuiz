import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    private struct QuizResultsViewModel {
      let title: String
      let text: String
      let buttonText: String
    }
    
    private struct QuizStepViewModel {
      let image: UIImage
      let question: String
      let questionNumber: String
    }
    
    private struct QuizQuestion {
      let image: String
      let text: String
      let correctAnswer: Bool
    }
    
    private var questions: [QuizQuestion] = [
             QuizQuestion(image: "The Godfather",
                          text: "Рейтинг этого фильма больше чем 6?",
                          correctAnswer: true),
             QuizQuestion(image: "The Dark Knight",
                          text: "Рейтинг этого фильма больше чем 6?",
                          correctAnswer: true),
             QuizQuestion(image: "Kill Bill",
                          text: "Рейтинг этого фильма больше чем 6?",
                          correctAnswer: true),
             QuizQuestion(image: "The Avengers",
                          text: "Рейтинг этого фильма больше чем 6?",
                          correctAnswer: true),
             QuizQuestion(image: "Deadpool",
                          text: "Рейтинг этого фильма больше чем 6?",
                          correctAnswer: true),
             QuizQuestion(image: "The Green Knight",
                          text: "Рейтинг этого фильма больше чем 6?",
                          correctAnswer: true),
             QuizQuestion(image: "Old",
                          text: "Рейтинг этого фильма больше чем 6?",
                          correctAnswer: false),
             QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
                          text: "Рейтинг этого фильма больше чем 6?",
                          correctAnswer: false),
             QuizQuestion(image: "Tesla",
                          text: "Рейтинг этого фильма больше чем 6?",
                          correctAnswer: false),
             QuizQuestion(image: "Vivarium",
                          text: "Рейтинг этого фильма больше чем 6?",
                          correctAnswer: false),
    ]
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        show(quiz: convert(model: questions[currentQuestionIndex]))
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: !questions[currentQuestionIndex].correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                          question: model.text,
                          questionNumber: "\(currentQuestionIndex+1)/\(questions.count)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.ypBackground.cgColor
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.show(quiz: self.convert(model: self.questions[self.currentQuestionIndex]))
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        var inc: Bool = false
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            inc = true
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults(inc: inc)
        }
    }
    
    private func showNextQuestionOrResults(inc : Bool) {
        if inc { correctAnswers += 1 }
        if currentQuestionIndex == questions.count - 1 {
            show(quiz: QuizResultsViewModel(title: "Этот раунд окончен!",
                                            text: "Ваш результат: \(correctAnswers) из \(questions.count)",
                                            buttonText: "Сыграть ещё раз"))
        } else {
            currentQuestionIndex += 1
            show(quiz: convert(model: questions[currentQuestionIndex]))
        }
    }
}
