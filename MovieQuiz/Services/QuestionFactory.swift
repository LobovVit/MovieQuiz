//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Vitaly on 09/08/2024.
//

import Foundation

class QuestionFactory : QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovies.Item] = []
    
    private let questions: [QuizQuestion] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        let index = (0..<self.movies.count).randomElement() ?? 0
        
        guard let movie = self.movies[safe: index] else { return }
        URLSession.shared.dataTask(with: movie.resizedImageURL) { data, response, error in
            guard let recievedData = data, error == nil  else {
                print("Error: No Data")
                return
            }
            let rating = Float(movie.rating) ?? 0
            
            let qestionRating = Int.random(in: 6..<10)
            let text = "Рейтинг этого фильма больше чем \(qestionRating)?"
            let correctAnswer = rating > Float(qestionRating)
            var imageData = Data()
            imageData = recievedData
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }.resume()
    }
}
