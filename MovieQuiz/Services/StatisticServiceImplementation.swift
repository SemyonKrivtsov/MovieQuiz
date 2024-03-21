//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by Семён Кривцов on 19.03.2024.
//

import Foundation

final class StatisticServiceImplementation: StatisticService {
    
    // MARK: - Private property
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    private let userDefaults = UserDefaults.standard
    private var total: Int {
        get {
            let total = userDefaults.integer(forKey: Keys.total.rawValue)
            return total
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    private var correct: Int {
        get {
            let correct = userDefaults.integer(forKey: Keys.correct.rawValue)
            return correct
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    // MARK: - Internal property StatisticService
    var totalAccuracy: Double {
        
        return Double(correct) / Double(total) * 100
    }
    
    var gamesCount: Int {
        get {
            let value = userDefaults.integer(forKey: Keys.gamesCount.rawValue)
            return value
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }

            return record
        }

        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }

            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let newGame = GameRecord(correct: count, total: amount, date: Date())
        
        if !bestGame.isBetterThan(newGame) {
            bestGame = newGame
        }
        
        correct += count
        total += amount
        gamesCount += 1
    }
    
}
