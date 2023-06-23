import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {  
    
    // MARK: - Properties
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        //добавляем чтобы заработала связь с MVP
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenterImpl(viewController: self)
    }

    // MARK: - Methods
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderWidth = 0
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        hideLoadingIndicator()
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
                self.imageView.image = UIImage(named: "Loading")
                self.presenter.restartGame()
            })
        alertPresenter?.show(with: model)
    }
    
    func showFinalResults() {
        imageView.layer.borderColor = nil
        imageView.image = UIImage(named: "Loading")
        alertPresenter?.show(with: presenter.createFinalResultsAlerModel())
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
    
    /// метод, который будет показывать индикатор загрузки
    func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    /// метод, скрывающий индикатор загрузки
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}
