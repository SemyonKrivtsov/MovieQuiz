//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Семён Кривцов on 17.03.2024.
//

import UIKit

final class AlertPresenter {
    
    // MARK: - Internal property
    weak var delegate: AlertDelegate?
    
    // MARK: - Private property
    private var alertModel: AlertModel
    
    // MARK: - Initialization
    init(alertModel: AlertModel) {
        self.alertModel = alertModel
    }
    
    // MARK: - Internal methods
    func show() {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let alertAction = UIAlertAction(
            title: alertModel.buttonText,
            style: .default,
            handler: alertModel.completion)
        
        alert.addAction(alertAction)
        delegate?.didReceiveAlert(alert: alert)
    }
    
}
