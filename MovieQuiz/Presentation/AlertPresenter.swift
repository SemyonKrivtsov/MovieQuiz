//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Семён Кривцов on 17.03.2024.
//

import UIKit

final class AlertPresenter {
    
    // MARK: - Internal methods
    func show(in delegate: AlertDelegate, model alertModel: AlertModel) {
        
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Game results"

        let alertAction = UIAlertAction(
            title: alertModel.buttonText,
            style: .default,
            handler: alertModel.completion)
        
        alert.addAction(alertAction)
        delegate.didReceiveAlert(alert: alert)
    }
    
}
