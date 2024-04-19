//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Семён Кривцов on 17.04.2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {

    // MARK: - Private Property
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var correctAnswers = 0
    private var currentQuestionIndex: Int = 0
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService
    private var alertPresenter: AlertPresenter!
    
    // MARK: - Initialization
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        alertPresenter = AlertPresenter()
        
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
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        
        let image = model.image.isEmpty ? UIImage() : UIImage(data: model.image) ?? UIImage()
            
        let questionStep = QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
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
        var codeError: Int?
        
        if let error = error as? NetworkError {
            switch error {
            case .codeError(let code):
                codeError = code
            }
        }
        
        viewController?.hideLoadingIndicator()
        let msg = error.localizedDescription
        makeErrorAlert(message: msg, errorCode: codeError)
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - Private Methods
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func makeResultsModel() -> AlertModel {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let date = statisticService.bestGame.date.dateTimeString
        let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)\n" +
                    "Количество сыгранных квизов: \(statisticService.gamesCount)\n" +
                    "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(date))\n" +
                    "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: text,
            buttonText: "Сыграть ещё раз") {[weak self] _ in
                guard let self = self else { return }
                restartGame()
            }
        
        return alertModel
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            let alertModel = makeResultsModel()
            guard let viewController = viewController as? AlertDelegate else { return }
            alertPresenter.show(in: viewController, model: alertModel)
        } else {
            guard let questionFactory = questionFactory else { return }
            switchToNextQuestion()
            questionFactory.requestNextQuestion()
        }
    }
    
    private func makeErrorAlert(message: String, errorCode: Int?) {
        
        var title = "Ошибка"
        
        if let errorCode = errorCode {
            title += " \(errorCode)"
        }
        
        let alertModel = AlertModel(
            title: title,
            message: message,
            buttonText: "Попробовать ещё раз") {[weak self] _ in
                guard let self = self else { return }
                        
                self.restartGame()
            }
        guard let viewController = viewController as? AlertDelegate else { return }
        alertPresenter.show(in: viewController, model: alertModel)
    }
    
    private func proceedWithAnswer(isCorrect: Bool){
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.proceedToNextQuestionOrResults()
        }
    }
}
