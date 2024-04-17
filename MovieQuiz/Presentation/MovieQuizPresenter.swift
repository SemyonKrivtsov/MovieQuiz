//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Семён Кривцов on 17.04.2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Internal Property
    let questionsAmount: Int = 10
    var correctAnswers = 0
    var currentQuestion: QuizQuestion?
    
    
    // MARK: - Private Property
    private var currentQuestionIndex: Int = 0
    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
                
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Internal Methods
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
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
    
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            viewController?.showResults()
        } else {
            guard let questionFactory = questionFactory else { return }
            switchToNextQuestion()
            questionFactory.requestNextQuestion()
        }
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }

    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
                    return
                }
                
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
        viewController?.hideLoadingIndicator()
    }
    
    func didFailToLoadData(with error: any Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
        viewController?.showLoadingIndicator()
    }
    
    // MARK: - Private Methods
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
