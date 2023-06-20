//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Admin on 20.06.2023.
//

import UIKit

/// метод конвертации, принимаем моковый вопрос и возвращаем вью модель для экрана вопросов
final class MovieQuizPresenter {
    /// переменная общего количества вопросов
    let questionsAmount: Int = 10
    /// переменная с индексом текущего вопроса, начальное значение 0
    private var currentQuestionIndex: Int = 0
    
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
}

