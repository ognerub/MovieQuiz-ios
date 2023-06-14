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
    // MARK: - Network Client
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: //"https://imdb-api.com/en/API/MostPopularMovies/k_om7srkwp")
                            "https://imdb-api.com/en/API/MostPopularMovies/k_yc97138i") else {
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

