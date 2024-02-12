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
        // insets api key here
        let apiKey = "k_zcuw1ytf"
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/" + "\(apiKey)")
        else {
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

