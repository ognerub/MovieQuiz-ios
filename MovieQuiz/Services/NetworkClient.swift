//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Admin on 31.05.2023.
//

import Foundation

struct NetworkClient {
    enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            // проверка пришла ли ошибка
            if let error = error { handler(.failure(error))
                return
            }
            
            // проверка что пришел успешный код ответа
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            // возвращаем данные
            guard let data = data else {return}
            handler(.success(data))
        }
        
        task.resume()
    }
}




