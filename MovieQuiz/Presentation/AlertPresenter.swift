//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Vitaly on 13/08/2024.
//

import UIKit

class AlertPresenter {
    
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func showAlert(quiz result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion()
        }
        alert.addAction(action)
        delegate?.presentAlert(alert: alert)
    }
}

protocol AlertPresenterDelegate: AnyObject {
    func presentAlert(alert: UIAlertController)
}
