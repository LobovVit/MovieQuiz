//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Vitaly on 26/08/2024.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    
    // MARK: - NetworkClient
    
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - URL
    private enum Constants {
        static let mostPopularMoviesUrlString = "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf"
    }
    
    enum MoviesLoaderError: Error {
        case emptyItems(String)
    }
    
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: Constants.mostPopularMoviesUrlString) else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    if mostPopularMovies.items.isEmpty {
                        handler(.failure(MoviesLoaderError.emptyItems(mostPopularMovies.errorMessage)))
                    } else {
                        handler(.success(mostPopularMovies))
                    }
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
