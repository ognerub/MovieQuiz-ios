import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    private var presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
        /// добавляем чтобы заработала связь с MVP
        presenter.viewController = self
        presenter.viewDidLoad()
    }

    // MARK: - Private functions

    /// метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderWidth = 0
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        hideLoadingIndicator()
    }
    
    /// метод определяющий что отображать, следующий вопрос или результат игры
    func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            showFinalResults()
        } else {
            showLoadingIndicator()
            presenter.swithToNextQuestion()
            presenter.questionFactory?.requestNextQuestion()
        }
    }
    
    /// метод отображающий итоговый результат игры
    func showFinalResults() {
        presenter.statisticService?.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: presenter.makeResultMessage(),
            buttonText: "Сыграть еще раз!",
            completion: { [weak self] in guard let self else { return }
                self.imageView.layer.borderColor = nil
                self.imageView.image = UIImage(named: "Loading")
                self.presenter.resetQuestionIndex()
                self.presenter.correctAnswers = 0
                self.presenter.questionFactory?.requestNextQuestion()
            })
        presenter.alertPresenter?.show(with: alertModel)
    }
    
    /// метод, отображающий алерт с ошибкой загрузки
    func showNetworkError(message: String) {
        let model = AlertModel(
            title: "Что-то пошло не так(",
            /// скрыл  message который соответствует  шаблону figma, но при этом добился оторажения текущей ошибки, дописав в Question Factory в catch метода requestNextQuestion - self.loadData()
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in guard let self = self else {return}
                // сбрасываем состояние игры на 1 вопрос
                self.presenter.resetQuestionIndex()
                self.presenter.correctAnswers = 0
                self.imageView.image = UIImage(named: "Loading")
                self.presenter.questionFactory?.requestNextQuestion()
            })
        presenter.alertPresenter?.show(with: model)
    }
    /// метод, который будет показывать индикатор загрузки
    func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    /// метод, скрывающий индикатор загрузки
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        yesAndNoButtonsActivation(nowItIs: false)
    }
    
    func yesAndNoButtonsActivation(nowItIs: Bool) {
        yesButton.isEnabled = nowItIs
        noButton.isEnabled = nowItIs
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}
