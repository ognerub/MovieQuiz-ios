import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        /// добавляем чтобы заработала связь с MVP
        presenter.viewController = self
        presenter.viewDidLoad()      
    }
    
    func didReceiveNextQuestion(_ question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question)
    }
    
    // MARK: - Private functions

    /// метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderWidth = 0
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        presenter.hideLoadingIndicator()
    }
    /// метод отображающий результат ответа
    func showAnswerResult() {
        presenter.showAnswerResult()
    }
    /// метод определяющий что отображать, следующий вопрос или результат игры
    func showNextQuestionOrResults() {
        presenter.showNextQuestionOrResults()
    }
    /// метод, отображающий алерт с ошибкой загрузки
    func showNetworkError(message: String) {
        presenter.showNetworkError(message: message)
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}
