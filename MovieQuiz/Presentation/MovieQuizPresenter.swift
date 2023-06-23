//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Admin on 20.06.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var isCorrect: Bool = false
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
    private var currentQuestion: QuizQuestion?
    
    //private weak var viewController: MovieQuizViewController?
    // подсовываем mock`овый протокол для тестирования
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    //init(viewController: MovieQuizViewController) {
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImpl()
        questionFactory = QuestionFactoryImpl(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Methods
    /// метод начала загрузки (происходит единожды)
    func didLoadDataFromServer() {
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    /// метод ошибки во время загрузки данных (происходит при каждой ошибке)
    func didFailToLoadData(with error: Error) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func restartGame() {
        resetQuestionIndex()
        correctAnswers = 0
        questionFactory?.loadData()
    }
        
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            // меняем отображение картинки с локальной на загруженную
            image: (UIImage(data: model.image) ?? UIImage(named: "Loading")) ?? UIImage(),
            question: model.text,
            
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
        
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
        
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(_ question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
        viewController?.yesAndNoButtonsActivation(nowItIs: true)
    }
    
    func storeStatistic() {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
    }
    
    func quizResultText () -> String {
        makeResultMessage()
    }
    
    /// метод определяющий что отображать, следующий вопрос или результат игры
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            viewController?.showFinalResults()
        } else {
            viewController?.showLoadingIndicator()
            switchToNextQuestion()
        }
    }
    
    func createFinalResultsAlerModel() -> AlertModel {
        storeStatistic()
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: quizResultText(),
            buttonText: "Сыграть еще раз!",
            completion: { [weak self] in guard let self else { return }
                self.restartGame()
            })
        return alertModel
    }
    
    
    // MARK: - Private methods
    
    private func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    /// создаем отдельный метод для повторяющегося кода кнопок
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        isCorrect = givenAnswer == currentQuestion.correctAnswer
        showAnswerResult()
    }
    
    private func showAnswerResult() {
        if isCorrect {
            self.correctAnswers += 1
        }
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        // запускаем через 1 секунду с помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in guard let self = self else { return }
            // код, который мы хотим вызвать через 1 секунду
            self.showNextQuestionOrResults()
        }
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
        let currentCameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд \(bestGame.correct)/\(bestGame.total) (\(resultDate))"
        let averageAccuracyLine = "Средняя точность: \(accuracy)%"
        let resultMessage = [currentCameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        
        return resultMessage
    }
}

