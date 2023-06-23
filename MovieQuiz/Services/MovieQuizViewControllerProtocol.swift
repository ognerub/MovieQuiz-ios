//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Admin on 21.06.2023.
//

import UIKit

/// создаем протокол для unit-теста
protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showNetworkError(message: String)
    func showFinalResults()
    func highlightImageBorder(isCorrectAnswer: Bool)
    func yesAndNoButtonsActivation(nowItIs: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
}
