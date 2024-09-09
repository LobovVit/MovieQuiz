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
        guard let movie = self.movies.randomElement() else { return }
        URLSession.shared.dataTask(with: movie.resizedImageURL) { data, response, error in
            guard let receivedData = data, error == nil  else {
                print("Error: No Data")
                return
            }
            let rating = Float(movie.rating) ?? 0
            
            let questionRating = Int.random(in: 5..<10)
            var text: String
            var correctAnswer: Bool
            if Bool.random() {
                text = "Рейтинг этого фильма больше чем \(questionRating)?"
                correctAnswer = rating > Float(questionRating)
            } else {
                text = "Рейтинг этого фильма меньше чем \(questionRating)?"
                correctAnswer = rating < Float(questionRating)
            }
            let question = QuizQuestion(image: receivedData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }.resume()
    }
}
