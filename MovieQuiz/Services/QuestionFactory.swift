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
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader

        self.delegate = delegate
    }
    
}

extension QuestionFactoryImpl: QuestionFactoryProtocol {

    
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
                    //print("Failed to load image!")
                }
            }
            
            /*
            /// вывод перечны всех фильмов и их рейтинга
            for index in 0..<self.movies.count {
                guard let movie = self.movies[safe: index] else {return}
                print("\(index+1)) \(movie.title) rating is \(movie.rating)")
            } */
            
            let rating = Float(movie.rating) ?? 0
            let randomRatingInt = Int.random(in: 4...9)
            let randomRatingMassive = ["больше", "меньше"]
            let randomRatingString = randomRatingMassive.randomElement()
            let text = "Рейтинг этого фильма \(randomRatingString ?? "больше") чем \(randomRatingInt)"
            let correctAnswer = randomRatingString == "больше" ? Int(rating) >= randomRatingInt : Int(rating) < randomRatingInt
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async {
                [weak self ] in guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question)
                //print("Image recieved!")
            }
            
        }
    }
}
