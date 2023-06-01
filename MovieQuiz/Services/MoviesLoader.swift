//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Admin on 31.05.2023.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

// создаем загрузчик
struct MoviesLoader: MoviesLoading {
    // создаем переменную в загрузчике
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // если не смогли преобразовать строку в URL, то приложение упадет
        guard let url = URL(string: "https://imdb-api.com/en/API/MostPopularMovies/k_om7srkwp") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) {
            result in switch result {
        case .success(let data): do {
            let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
            handler(.success(mostPopularMovies))
        } catch {
            handler(.failure(error))
        }
        case .failure(let error):
            handler(.failure(error))
        }
        }
    }
}

