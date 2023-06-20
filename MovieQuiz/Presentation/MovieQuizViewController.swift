import UIKit

// добавляем в объявление класса реализацию протокола делегата
final class MovieQuizViewController: UIViewController {
    
    // MARK: - Properties
    // переменные из экрана
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    /// переменная со счётчиком правильных ответов, начальное значение закономерно 0
    //private var correctAnswers = 0
    /// переменная фабрики вопросов подписанная под протокол
    //private var questionFactory: QuestionFactoryProtocol?
    /// переменная алерт сообщения подписанная под протокол
    //private var alertPresenter: AlertPresenterProtocol?
    ///  переменная сервиса статистики
    //private var statisticService: StatisticService?
    /// переменная MVP (презентера) созданная после рефакторинга
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
