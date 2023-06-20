//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Admin on 20.06.2023.
//

import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = 0
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticService?
    var alertPresenter: AlertPresenterProtocol?
    var isCorrect: Bool = false
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func swithToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            // меняем отображение картинки с локальной на загруженную
            image: (UIImage(data: model.image) ?? UIImage(named: "Loading")) ?? UIImage(),
            question: model.text,
            
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // MARK: - Actions
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    /// создаем отдельный метод для повторяющегося кода кнопок
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        isCorrect = givenAnswer == currentQuestion.correctAnswer
        showAnswerResult()
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
        viewController?.yesButton.isEnabled = true
        viewController?.noButton.isEnabled = true

    }
    
    /// метод, содержащий логику перехода в один из сценариев
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            self.showFinalResults()
        } else {
            self.swithToNextQuestion()
            showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func showAnswerResult() {
        if isCorrect { self.correctAnswers += 1 }
        viewController?.imageView.layer.borderWidth = 8
        viewController?.imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        viewController?.yesButton.isEnabled = false
        viewController?.noButton.isEnabled = false
        // запускаем через 1 секунду с помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in guard let self = self else { return }
            // код, который мы хотим вызвать через 1 секунду
            self.showNextQuestionOrResults()
        }
    }

    func showFinalResults() {
        statisticService?.store(correct: correctAnswers, total: self.questionsAmount)
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage(),
            buttonText: "Сыграть еще раз!",
            completion: { [weak self] in guard let self else { return }
                self.viewController?.imageView.layer.borderColor = nil
                self.resetQuestionIndex()
                self.correctAnswers = 0
                self.viewController?.imageView.image = UIImage(named: "Loading")
                self.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.show(with: alertModel)
    }
    
    /// метод для формирования статистического сообщения в конце игры
    func makeResultMessage() -> String {
        
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
        let currentCameResultLine = "Ваш результат: \(correctAnswers)/\(self.questionsAmount)"
        let bestGameInfoLine = "Рекорд \(bestGame.correct)/\(bestGame.total) (\(resultDate))"
        let averageAccuracyLine = "Средняя точность: \(accuracy)%"
        let resultMessage = [currentCameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        
        return resultMessage
    }
    
    
    func showNetworkError(message: String) {
        let model = AlertModel(
            title: "Что-то пошло не так(",
            /// скрыл  message который соответствует  шаблону figma, но при этом добился оторажения текущей ошибки, дописав в Question Factory в catch метода requestNextQuestion - self.loadData()
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in guard let self = self else {return}
                // сбрасываем состояние игры на 1 вопрос
                self.resetQuestionIndex()
                self.correctAnswers = 0
                self.viewController?.imageView.image = UIImage(named: "Loading")
                self.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.show(with: model)
    }
    
    /// метод, который будет показывать индикатор загрузки
    func showLoadingIndicator() {
        viewController?.activityIndicator.startAnimating() // включаем анимацию
    }
    /// метод, скрывающий индикатор загрузки
    func hideLoadingIndicator() {
        viewController?.activityIndicator.stopAnimating()
        
    }
    
}
