import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter?
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter = MovieQuizPresenter(viewController: self)
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        activityIndicator.hidesWhenStopped = true
        
        self.alertPresenter = AlertPresenter(delegate: self)
        
        showLoadingIndicator()
    }
    
    // MARK: IBActions
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter?.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter?.yesButtonClicked()
    }
    
    // MARK: AlertPresenterDelegate
    
    func presentAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: functions
    
    func showLoadingIndicator() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self else { return }
            
            self.presenter?.restartGame()
        }
        
        alertPresenter?.showAlert(quiz: model)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title,
                                    message: result.text,
                                    buttonText: result.buttonText,
                                    completion: { [weak self] in
            guard let self else { return }
            presenter?.restartGame()
        })
        alertPresenter?.showAlert(quiz: alertModel)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
}
