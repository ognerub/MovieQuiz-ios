//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Admin on 31.05.2023.
//

import Foundation

struct MostPopularMovies: Decodable {
    let items: [MostPopularMovie]
    let errorMessage: String
    
    enum CodingKeys: String, CodingKey {
        case items = "items"
        case errorMessage = "errorMessage"
    }
}

struct MostPopularMovie: Decodable {
    
    let title: String
    let rating: String
    let imageURL: String
    
    var resizedImageURL: URL {
        let urlString = (URL(string: imageURL) ?? URL(fileURLWithPath: "")).absoluteString
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        guard let newURL = URL(string: imageUrlString) else {
            return URL(string: imageURL) ?? URL(fileURLWithPath: "")
        }
        return newURL
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
