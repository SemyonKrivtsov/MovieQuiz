//
//  AlertDelegate.swift
//  MovieQuiz
//
//  Created by Семён Кривцов on 17.03.2024.
//

import UIKit

protocol AlertDelegate: AnyObject {
    func didReceiveAlert(alert: UIAlertController?)
}
