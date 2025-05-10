//
//  MovieAPI.swift
//  CineMatchApp
//
//  Created by Brielle on 2025-05-07.
//

import Foundation

class MovieAPI {
    static let shared = MovieAPI()
    let baseURL = "http://127.0.0.1:8000/movies"

    func fetchMovies(genre: Int = 28, rating: Double = 7.0, completion: @escaping ([Movie]) -> Void) {
        guard let url = URL(string: "\(baseURL)?genre=\(genre)&rating=\(rating)") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(decoded.results)
                    }
                } catch {
                    print("Decoding error:", error)
                }
            } else if let error = error {
                print("Network error:", error)
            }
        }.resume()
    }
}

struct MovieResponse: Codable {
    let results: [Movie]
}

