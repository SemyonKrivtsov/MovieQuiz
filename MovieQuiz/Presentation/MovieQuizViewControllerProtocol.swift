//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Семён Кривцов on 19.04.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
}
