//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Семён Кривцов on 17.03.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
