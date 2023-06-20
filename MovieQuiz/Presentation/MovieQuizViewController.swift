import UIKit

// добавляем в объявление класса реализацию протокола делегата
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Properties
    // переменные из экрана
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    /// переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    /// переменная с текущим  вопросом
    private var currentQuestion: QuizQuestion?
    /// переменная фабрики вопросов подписанная под протокол
    private var questionFactory: QuestionFactoryProtocol?
    /// переменная алерт сообщения подписанная под протокол
    private var alertPresenter: AlertPresenterProtocol?
    ///  переменная сервиса статистики
    private var statisticService: StatisticService?
    /// переменная MVP (презентера) созданная после рефакторинга
    private var presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        // инъекция через свойство, поэтому задаем делегата в методе
        questionFactory = QuestionFactoryImpl(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData() // загружаем данные единожды, по хорошему нужно загружать до viewDidLoad ?
        statisticService = StatisticServiceImpl()
        alertPresenter = AlertPresenterImpl(viewController: self)
        
    }
    
    // MARK: - QuestionFactoryDelegate
    /// метод получения следующего вопроса, и действий с этим связанных
    func didReceiveNextQuestion(_ question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in self?.show(quiz: viewModel)
        }
        self.yesButton.isEnabled = true
        self.noButton.isEnabled = true
    }
    
    // MARK: - Private functions

    /// метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderWidth = 0
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        hideLoadingIndicator()
    }
    /// метод отображающий результат ответа
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        yesButton.isEnabled = false
        noButton.isEnabled = false
        if isCorrect {correctAnswers += 1}
        
        // запускаем через 1 секунду с помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in guard let self = self else { return }
            // код, который мы хотим вызвать через 1 секунду
            self.showNextQuestionOrResults()
        }
    }
    /// метод, содержащий логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            // идем в состояние "Результат квиза"
            showFinalResults()
        } else {
            presenter.swithToNextQuestion()
            showLoadingIndicator()
            // идем в состояние "Запрос следующего вопроса"
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Show final results
    private func showFinalResults() {
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage(),
            buttonText: "Сыграть еще раз!",
            completion: { [weak self] in guard let self else { return }
                self.imageView.layer.borderColor = nil
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.imageView.image = UIImage(named: "Loading")
                self.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.show(with: alertModel)
    }
    /// метод для формирования статистического сообщения в конце игры
    private func makeResultMessage() -> String {
        
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("Error message: Show final result")
            return ""
            
        }
        // изменяем отображение даты и времени лучшей игры
        let gameDate = bestGame.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YY HH:MM"
        let resultDate = dateFormatter.string(from: gameDate)
        
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gameCount)"
        let currentCameResultLine = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)"
        let bestGameInfoLine = "Рекорд \(bestGame.correct)/\(bestGame.total) (\(resultDate))"
        let averageAccuracyLine = "Средняя точность: \(accuracy)%"
        let resultMessage = [currentCameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        
        return resultMessage
    }
    
    // MARK: - Loading from network
    /// метод, который будет показывать индикатор загрузки
    private func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    /// метод, скрывающий индикатор загрузки
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        
    }
    /// метод начала загрузки (происходит единожды)
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    /// метод ошибки во время загрузки данных (происходит при каждой ошибке)
    func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        showNetworkError(message: error.localizedDescription)
    }
    /// метод, отображающий алерт с ошибкой загрузки
    private func showNetworkError(message: String) {
        let model = AlertModel(
            title: "Что-то пошло не так(",
            /// скрыл  message который соответствует  шаблону figma, но при этом добился оторажения текущей ошибки, дописав в Question Factory в catch метода requestNextQuestion - self.loadData()
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in guard let self = self else {return}
                // сбрасываем состояние игры на 1 вопрос
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.imageView.image = UIImage(named: "Loading")
                self.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.show(with: model)
    }
    
    // MARK: - Actions
    /// нажатие на "ДА"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    /// нажатие на "НЕТ"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
