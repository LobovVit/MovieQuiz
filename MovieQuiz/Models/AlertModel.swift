//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Vitaly on 13/08/2024.
//

import Foundation

struct AlertModel {
   let title: String
   let message: String
   let buttonText: String
   var completion: () -> Void
}
