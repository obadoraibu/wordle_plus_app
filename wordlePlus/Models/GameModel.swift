//
//  GameModel.swift
//  wordlePlus
//
//  Created by Egor Zavyalov on 10.12.2023.
//

import Foundation

class GameModel {
    enum Constants {
        static let blank: String = ""
    }
    
    enum LetterStatus {
        case correct
        case present
        case absent
    }
    
    var guesses: [String]
    var targetWord: String
    var wordDescription: String
    var maxAttempts: Int
    var wordLength: Int
    var hasWon: Bool
    var hasLost: Bool

    init(wordLength: Int, maxAttempts: Int = 6) {
        self.wordLength = wordLength
        self.maxAttempts = maxAttempts
        self.targetWord = Constants.blank
        self.guesses = []
        self.hasWon = false
        self.hasLost = false
        self.wordDescription = Constants.blank
        
        self.targetWord = DataPersistenceManager.shared.retrieveTargetWord(for: wordLength)
        self.guesses = DataPersistenceManager.shared.retrieveGuesses(for: wordLength)
        
        if !guesses.isEmpty && guesses[guesses.count - 1] == targetWord {
            hasWon = true
        }
    }
    
    func isTargetConfigured() -> Bool {
        return self.targetWord != Constants.blank
    }

    func saveCurrentState() {
        DataPersistenceManager.shared.saveCurrentState(guesses: guesses, targetWord: targetWord, wordLength: wordLength)
    }
    
    func startNewGame(wordLength: Int, completion: @escaping (Bool, Error?) -> Void) {
        NetworkManager.shared.fetchNewWord(ofLength: wordLength) { [weak self] (word, error) in
            if let error = error {
                completion(false, error)
                return
            }
            if let word = word {
                self?.targetWord = word.word
                self?.wordDescription = word.definition
                self?.guesses = []
                self?.hasLost = false
                self?.hasWon = false
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }

    func checkWord(_ attempt: String, completion: @escaping (Bool, Error?) -> Void) {
        print(attempt)
        NetworkManager.shared.checkWord(attempt) { (isValid, error) in
            if let error = error {
                completion(false, error)
                return
            }
            if isValid {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }

    func evaluateGuess(_ guess: String) -> [LetterStatus] {
        var result = [LetterStatus]()
        let targetWordArray = Array(targetWord)
        for (index, letter) in guess.enumerated() {
            if index < targetWordArray.count && targetWordArray[index] == letter {
                result.append(.correct)
            } else if targetWord.contains(letter) {
                result.append(.present)
            } else {
                result.append(.absent)
            }
        }
        return result
    }

    func makeGuess(guess: String) {
        guard guess.count == targetWord.count, !hasWon, !hasLost else {
            return
        }
        guesses.append(guess)
        if isCorrect(guess: guess) {
            hasWon = true
        } else if guesses.count == maxAttempts {
            hasLost = true
        }
        return
    }
    
    func isCorrect(guess: String) -> Bool {
        return guess == targetWord
    }
}

struct UserDefaultsKeys {
    static func targetWordKey(wordLength: Int) -> String {
        return "target" + String(wordLength)
    }
    static func guessesKey(wordLength: Int) -> String {
        return "guesses" + String(wordLength)
    }
}

struct DataPersistenceManager {
    static let shared = DataPersistenceManager()

    func retrieveTargetWord(for wordLength: Int) -> String {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.targetWordKey(wordLength: wordLength)) ?? ""
    }

    func retrieveGuesses(for wordLength: Int) -> [String] {
        return UserDefaults.standard.object(forKey: UserDefaultsKeys.guessesKey(wordLength: wordLength)) as? [String] ?? []
    }
    
    func saveCurrentState(guesses: [String], targetWord: String, wordLength: Int) {
        UserDefaults.standard.set(guesses, forKey: UserDefaultsKeys.guessesKey(wordLength: wordLength))
        UserDefaults.standard.set(targetWord, forKey: UserDefaultsKeys.targetWordKey(wordLength: wordLength))
    }
}
