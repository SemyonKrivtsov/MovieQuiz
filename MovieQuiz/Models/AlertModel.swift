//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Семён Кривцов on 17.03.2024.
//

import UIKit

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: (UIAlertAction) -> Void
}
