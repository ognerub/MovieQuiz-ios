//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Admin on 19.05.2023.
//

import Foundation


final class QuestionFactoryImpl {
    // добавляем загрузчик фильмов как зависимость
    private let moviesLoader: MoviesLoading
    
    private weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [MostPopularMovie] = []
    
    private var dataLoadedValue: Bool
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?, dataLoadedValue: Bool) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
        self.dataLoadedValue = dataLoadedValue
    }
    
}

extension QuestionFactoryImpl: QuestionFactoryProtocol {
    
    var isDataLoaded: Bool {
        get {
            dataLoadedValue
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {return}
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items // сохранение фильма в новую переменную
                    self.delegate?.didLoadDataFromServer() // сообщаем о загрузке данных
                    
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке
                    
                }
            }
        }
    }
    
    // MARK: - Functions
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async {
                    [weak self ] in guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: NetworkClient.NetworkError.codeError)
                    print("Failed to load image!")
                    self.dataLoadedValue = false
                }
            }
            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async {
                [weak self ] in guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question)
                print("Image recieved!")
                self.dataLoadedValue = true
            }
            
        }
    }
}
/// массив со списком моковых вопросов
/* private let questions: [QuizQuestion] = [
 QuizQuestion(
 image: "The Godfather",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: true),
 QuizQuestion(
 image: "The Dark Knight",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: true),
 QuizQuestion(
 image: "Kill Bill",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: true),
 QuizQuestion(
 image: "The Avengers",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: true),
 QuizQuestion(
 image: "Deadpool",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: true),
 QuizQuestion(
 image: "The Green Knight",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: true),
 QuizQuestion(
 image: "Old",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: false),
 QuizQuestion(
 image: "The Ice Age Adventures of Buck Wild",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: false),
 QuizQuestion(
 image: "Tesla",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: false),
 QuizQuestion(
 image: "Vivarium",
 text: "Рейтинг этого фильма больше чем 6?",
 correctAnswer: false),
 ] */



