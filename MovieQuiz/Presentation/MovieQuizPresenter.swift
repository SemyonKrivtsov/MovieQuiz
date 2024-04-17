//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Семён Кривцов on 17.04.2024.
//

import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    weak var viewController: MovieQuizViewController?
    var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        let isCorrect = currentQuestion.correctAnswer == givenAnswer
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        let isCorrect = currentQuestion.correctAnswer == givenAnswer
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(imageLiteralResourceName: "xmark"),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
}
