import UIKit


final class MovieQuizViewController: UIViewController, AlertDelegate {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Property

    private var statisticService: StatisticService?
    private var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Override

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        activityIndicator.hidesWhenStopped = true
        showLoadingIndicator()
        
        statisticService = StatisticServiceImplementation()
        alertPresenter = AlertPresenter()
    }
    
    func showAnswerResult(isCorrect: Bool){
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        
        imageView.image = step.image
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    func showResults() {
        guard let statisticService = statisticService else { return }
        statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        let date = statisticService.bestGame.date.dateTimeString
        let text = "Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)\n" +
                    "Количество сыгранных квизов: \(statisticService.gamesCount)\n" +
                    "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(date))\n" +
                    "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: text,
            buttonText: "Сыграть ещё раз") {[weak self] _ in
                guard let self = self else { return }
                presenter.restartGame()
            }
        alertPresenter?.show(in: self, model: alertModel)
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз") {[weak self] _ in
                guard let self = self else { return }
                        
                self.presenter.restartGame()
            }
        
        alertPresenter?.show(in: self, model: alertModel)
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - AlertDelegate
    
    func didReceiveAlert(alert: UIAlertController?) {
        guard let alert = alert else { return }
        present(alert, animated: true)
    }
    
    // MARK: - IBActions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}
