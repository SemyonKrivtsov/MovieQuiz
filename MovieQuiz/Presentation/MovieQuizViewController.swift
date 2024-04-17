import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertDelegate {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Property

    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
    private var alertPresenter: AlertPresenter?
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Override

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let moviesLoader = MoviesLoader()
        questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
        
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        self.questionFactory?.loadData()
        
        statisticService = StatisticServiceImplementation()
        alertPresenter = AlertPresenter()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }

        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        showLoadingIndicator()
        questionFactory?.requestNextQuestion()
        hideLoadingIndicator()
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
        showLoadingIndicator()
        self.questionFactory?.loadData()
    }
    
    // MARK: - AlertDelegate
    
    func didReceiveAlert(alert: UIAlertController?) {
        guard let alert = alert else { return }
        present(alert, animated: true)
    }
    
    // MARK: - IBActions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        let isCorrect = currentQuestion.correctAnswer == givenAnswer
        showAnswerResult(isCorrect: isCorrect)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        let isCorrect = currentQuestion.correctAnswer == givenAnswer
        showAnswerResult(isCorrect: isCorrect)
    }
    
    // MARK: - Private methods
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз") {[weak self] _ in
                guard let self = self else { return }
                        
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                self.questionFactory?.requestNextQuestion()
            }
        
        alertPresenter?.show(in: self, model: alertModel)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        
        imageView.image = step.image
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    private func showAnswerResult(isCorrect: Bool){
        
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let date = statisticService.bestGame.date.dateTimeString
            let text = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)\n" +
                        "Количество сыгранных квизов: \(statisticService.gamesCount)\n" +
                        "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(date))\n" +
                        "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз") {[weak self] _ in
                    guard let self = self else { return }
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    
                    guard let questionFactory = questionFactory else { return }
                    questionFactory.requestNextQuestion()
                }
            alertPresenter?.show(in: self, model: alertModel)
        } else {
            guard let questionFactory = questionFactory else { return }
            presenter.switchToNextQuestion()
            questionFactory.requestNextQuestion()
        }
    }
}
