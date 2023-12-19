//
//  GameViewController.swift
//  wordlePlus
//
//  Created by Egor Zavyalov on 10.12.2023.
//

import UIKit

class GameViewController: UIViewController, UITextFieldDelegate {
    // MARK: - Constants
    enum Constants {
        static let defaultWordLength: Int = 4
        static let errorMessage: String = "an error accured"
        static let winMessage: String = "YOU WON"
        static let loseMessage: String = "YOU LOST"
        static let saveButtonTitle: String = "Save"
        static let cancelButtonTitle: String = "Cancel"
        static let okButtonTitle: String = "OK"
        static let blank: String = ""
        static let keybordRows = ["RESET", "Q W E R T Y U I O P", "A S D F G H J K L", "Z X C V B N M", "DELETE SUBMIT"]
        
        // layout
        static let dialogCornerRadius: CGFloat = 10
        static let dialogButtonsStackSpacing: CGFloat = 10
        static let saveDialogWidth: CGFloat = 300
        static let saveDialogHeight: CGFloat = 200
        static let titleLabelTopMargin: CGFloat = 20
        static let labelSpacing: CGFloat = 10
        static let buttonsStackTopMargin: CGFloat = 20
        static let buttonsStackWidthMultiplier: CGFloat = 0.8
        static let definitionTopMargin: CGFloat = 10
        static let definitionLeadingMargin: CGFloat = 20
        
        static let wordGridSpacing: CGFloat = 5
        static let wordGridMargin: CGFloat = 20
        static let letterBoxFontSize: CGFloat = 24
        static let letterBoxBorderWidth: CGFloat = 1
        static let keyboardRowSpacing: CGFloat = 5
        static let keyboardButtonCornerRadius: CGFloat = 3
        static let keyboardContainerHeight: CGFloat = 230
        static let keyboardContainerMargin: CGFloat = 20
        static let shakeAnimationDuration: TimeInterval = 0.05
        static let flipAnimationDuration: TimeInterval = 0.3
        static let shakeAnimationRepeatCount: Float = 5
        static let shakeAnimationOffset: CGFloat = 10
        
    }
    
    // MARK: - Properties
    var wordLength: Int = Constants.defaultWordLength
    var gameModel: GameModel!
    var wordGrid: UIStackView!
    var keyboardContainer: UIStackView!
    var currentGuess: String = Constants.blank
    var activityIndicator: UIActivityIndicatorView!
    
    var resetButton: UIButton?
    var deleteButton: UIButton?
    var submitButton: UIButton?
    
    var saveDialogView: UIView?

    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.bgColor
        gameModel = GameModel(wordLength: wordLength)
        setupKeyboard()
        setupWordGrid()
        setupGameModel()
    }
    
    // MARK: - Setup Methods
    func setupGameModel() {
        if gameModel.isTargetConfigured() {
            updateWordGridFromSave()
        } else {
            submitButton?.isEnabled = false
            submitButton?.backgroundColor = ThemeManager.shared.disabledButton
            resetButton?.isEnabled = false
            resetButton?.backgroundColor = ThemeManager.shared.disabledButton
            gameModel.startNewGame(wordLength: wordLength) { [weak self] (success, error) in
                DispatchQueue.main.async {
                    if success {
                        print(self?.gameModel.targetWord as Any)
                        self?.submitButton?.isEnabled = true
                        self?.submitButton?.backgroundColor = ThemeManager.shared.defaultButton
                        self?.resetButton?.isEnabled = true
                        self?.resetButton?.backgroundColor = ThemeManager.shared.defaultButton
                    } else if error != nil {
                        self?.showAlert(title: "Error", message: Constants.errorMessage)
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    private func updateKeyboardForAllGuesses() {
        for guess in gameModel.guesses {
            let evaluation = gameModel.evaluateGuess(guess)
            for (index, letter) in guess.enumerated() {
                let character = String(letter).uppercased()
                let status = evaluation[index]
                updateKeyColor(for: character, with: status)
            }
        }
    }
    
    func updateWordGridFromSave() {
        for (rowIndex, guess) in gameModel.guesses.enumerated() {
            guard rowIndex < gameModel.maxAttempts else { break }

            if let row = wordGrid.arrangedSubviews[rowIndex] as? UIStackView {
                let evaluation = gameModel.evaluateGuess(guess)

                for (index, letterBox) in row.arrangedSubviews.enumerated() {
                    if let label = letterBox as? UILabel {
                        label.text = String(guess[guess.index(guess.startIndex, offsetBy: index)].uppercased())
                        label.backgroundColor = colorForLetterStatus(evaluation[index])
                        label.textColor = ThemeManager.shared.mainTextColor
                    }
                }
            }
        }
        updateKeyboardForAllGuesses()
    }

    private func resetGame() {
        currentGuess = Constants.blank
        submitButton?.isEnabled = false
        submitButton?.backgroundColor = ThemeManager.shared.disabledButton
        resetButton?.isEnabled = false
        resetButton?.backgroundColor = ThemeManager.shared.disabledButton
        gameModel.startNewGame(wordLength: wordLength) { [weak self] (success, error) in
            DispatchQueue.main.async {
                if success {
                    print(self?.gameModel.targetWord as Any)
                    self?.submitButton?.isEnabled = true
                    self?.submitButton?.backgroundColor = ThemeManager.shared.defaultButton
                    self?.resetButton?.isEnabled = true
                    self?.resetButton?.backgroundColor = ThemeManager.shared.defaultButton
                    self?.clearWordGrid()
                    self?.gameModel.saveCurrentState()
                    self?.resetKeyboardColors()
                } else if error != nil {
                    self?.showAlert(title: "Error", message: Constants.errorMessage)
                }
            }
        }
        
    }
    
    private func clearWordGrid() {
        for row in wordGrid.arrangedSubviews {
            if let rowStackView = row as? UIStackView {
                for letterBox in rowStackView.arrangedSubviews {
                    if let label = letterBox as? UILabel {
                        label.text = Constants.blank
                        label.backgroundColor = ThemeManager.shared.bgColor
                    }
                }
            }
        }
    }
    
    private func updateCurrentGuessDisplay() {
        let rowIndex = gameModel.guesses.count
        if let row = wordGrid.arrangedSubviews[rowIndex] as? UIStackView {
            for (index, view) in row.arrangedSubviews.enumerated() {
                if let letterBox = view as? UILabel {
                    letterBox.text = index < currentGuess.count ?String(currentGuess[currentGuess.index(currentGuess.startIndex,offsetBy: index)].uppercased()) : Constants.blank
                    letterBox.textColor = ThemeManager.shared.newTextColor
                }
            }
        }
    }
    
    private func submitGuess() {
        guard currentGuess.count == gameModel.wordLength else {
            return
        }
        gameModel.checkWord(currentGuess) { [weak self] (isValid, error) in
            DispatchQueue.main.async {
                if isValid {
                    self?.gameModel.makeGuess(guess: self?.currentGuess ?? Constants.blank)
                    self?.updateWordGridAfterGuess()
                    self?.checkForEndOfGame()
                    self?.currentGuess = Constants.blank
                    self?.gameModel.saveCurrentState()
                } else if error != nil {
                    self?.showAlert(title: "Error", message: Constants.errorMessage)
                } else {
                    if let rowIndex = self?.gameModel.guesses.count,
                        let row = self?.wordGrid.arrangedSubviews[rowIndex] as? UIStackView {
                        self?.shakeAnimation(for: row)
                    }
                }
            }
        }
    }		
    
    private func checkForEndOfGame() {
        if gameModel.hasWon || gameModel.hasLost {
            let word = gameModel.targetWord
            let definition = gameModel.wordDescription
            setupSaveDialog(word: word, definition: definition, gameWon: gameModel.hasWon)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.okButtonTitle, style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func updateWordGridAfterGuess() {
        let rowIndex = gameModel.guesses.count - 1
        guard rowIndex < gameModel.maxAttempts else { return }

        if let row = wordGrid.arrangedSubviews[rowIndex] as? UIStackView {
            let guess = gameModel.guesses[rowIndex]
            let evaluation = gameModel.evaluateGuess(guess)

            for (index, letterBox) in row.arrangedSubviews.enumerated() {
                if let label = letterBox as? UILabel {
                    let character = String(guess[guess.index(guess.startIndex, offsetBy: index)].uppercased())
                    let backgroundColor = colorForLetterStatus(evaluation[index])
                    flipAnimation(for: label, withText: character, backgroundColor: backgroundColor, textColor: ThemeManager.shared.mainTextColor)
                    updateKeyColor(for: character, with: evaluation[index])
                }
            }
        }
    }
}

// MARK: - Animations and Color Updates
extension GameViewController {
    private func shakeAnimation(for row: UIStackView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = Constants.shakeAnimationDuration
        animation.repeatCount = Constants.shakeAnimationRepeatCount
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: row.center.x - Constants.shakeAnimationOffset, y: row.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: row.center.x + Constants.shakeAnimationOffset, y: row.center.y))

        row.layer.add(animation, forKey: "position")
    }

    private func resetKeyboardColors() {
        for rowView in keyboardContainer.arrangedSubviews {
            guard let rowStackView = rowView as? UIStackView else { continue }
            for keyView in rowStackView.arrangedSubviews {
                if let keyButton = keyView as? UIButton {
                    keyButton.backgroundColor = ThemeManager.shared.defaultButton
                }
            }
        }
    }

    private func colorForLetterStatus(_ status: GameModel.LetterStatus) -> UIColor {
        switch status {
        case .correct:
            return ThemeManager.shared.mainColor
        case .present:
            return ThemeManager.shared.secondaryColor
        case .absent:
            return ThemeManager.shared.wrongGuess
        }
    }

    private func updateKeyColor(for character: String, with status: GameModel.LetterStatus) {
        for rowView in keyboardContainer.arrangedSubviews {
            guard let rowStackView = rowView as? UIStackView else { continue }
            for keyView in rowStackView.arrangedSubviews {
                if let keyButton = keyView as? UIButton, keyButton.title(for: .normal) == character.uppercased() {
                    keyButton.backgroundColor = colorForLetterStatus(status)
                    break
                }
            }
        }
    }

    private func flipAnimation(for label: UILabel, withText newText: String, backgroundColor: UIColor, textColor: UIColor) {
        UIView.transition(with: label, duration: Constants.flipAnimationDuration, options: .transitionFlipFromTop, animations: {
            label.text = newText
            label.backgroundColor = backgroundColor
            label.textColor = textColor
        })
    }
}


// MARK: - UI Setup
extension GameViewController {
    func setupWordGrid() {
        wordGrid = UIStackView()
        wordGrid.axis = .vertical
        wordGrid.alignment = .fill
        wordGrid.distribution = .fillEqually
        wordGrid.spacing = Constants.wordGridSpacing

        for _ in 0..<gameModel.maxAttempts {
            let row = createWordRow()
            wordGrid.addArrangedSubview(row)
        }

        view.addSubview(wordGrid)
        wordGrid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wordGrid.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.wordGridMargin),
            wordGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.wordGridMargin),
            wordGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.wordGridMargin),
            wordGrid.bottomAnchor.constraint(equalTo: keyboardContainer.topAnchor, constant: -Constants.wordGridMargin)
        ])
    }

    private func createWordRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .fill
        row.distribution = .fillEqually
        row.spacing = Constants.wordGridSpacing

        for _ in 0..<gameModel.wordLength {
            let letterBox = UILabel()
            letterBox.backgroundColor = ThemeManager.shared.bgColor
            letterBox.textAlignment = .center
            letterBox.font = UIFont.systemFont(ofSize: Constants.letterBoxFontSize)
            letterBox.layer.borderWidth = Constants.letterBoxBorderWidth
            letterBox.layer.borderColor = UIColor.lightGray.cgColor

            row.addArrangedSubview(letterBox)
        }
        return row
    }

    func setupKeyboard() {
        keyboardContainer = UIStackView()
        keyboardContainer.axis = .vertical
        keyboardContainer.alignment = .fill
        keyboardContainer.distribution = .fillEqually
        keyboardContainer.spacing = Constants.keyboardRowSpacing


        for (index, row) in Constants.keybordRows.enumerated() {
            keyboardContainer.addArrangedSubview(createKeyboardRow(keys: row, isSpecialRow: index == Constants.keybordRows.count - 1, isFirstRow: index == 0))
        }

        view.addSubview(keyboardContainer)
        
        keyboardContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyboardContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.keyboardContainerMargin),
            keyboardContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.keyboardContainerMargin),
            keyboardContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.keyboardContainerMargin),
            keyboardContainer.heightAnchor.constraint(equalToConstant: Constants.keyboardContainerHeight)
        ])
    }

    func createKeyboardRow(keys: String, isSpecialRow: Bool = false, isFirstRow: Bool = false) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .fill
        row.distribution = .fillEqually
        row.spacing = Constants.keyboardRowSpacing

        for key in keys.split(whereSeparator: { $0.isWhitespace }) {
            let button = UIButton()
            button.setTitle(String(key), for: .normal)
            button.backgroundColor = ThemeManager.shared.defaultButton
            button.layer.cornerRadius = Constants.keyboardButtonCornerRadius
            button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
            if key == "RESET" {
                resetButton = button
            } else if key == "DELETE" {
                deleteButton = button
            } else if key == "SUBMIT" {
                submitButton = button
            }
            row.addArrangedSubview(button)
        }
        return row
    }

    func setupSaveDialog(word: String, definition: String, gameWon: Bool) {
            saveDialogView = UIView()
            saveDialogView?.backgroundColor = ThemeManager.shared.bgColor
            saveDialogView?.layer.cornerRadius = Constants.dialogCornerRadius
            saveDialogView?.translatesAutoresizingMaskIntoConstraints = false
            saveDialogView?.layer.borderWidth = 1
        saveDialogView?.layer.borderColor = ThemeManager.shared.defaultButton.cgColor

            let titleLabel = UILabel()
            titleLabel.text = gameWon ? Constants.winMessage : Constants.loseMessage
            titleLabel.textColor = ThemeManager.shared.newTextColor
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            saveDialogView?.addSubview(titleLabel)

            let wordLabel = UILabel()
            wordLabel.text = "Word: \(word)"
            wordLabel.textColor = ThemeManager.shared.newTextColor
            wordLabel.translatesAutoresizingMaskIntoConstraints = false
            saveDialogView?.addSubview(wordLabel)

            let definitionLabel = UILabel()
            definitionLabel.text = "Definition: \(definition)"
            definitionLabel.numberOfLines = 0
            definitionLabel.textColor = ThemeManager.shared.newTextColor
            definitionLabel.translatesAutoresizingMaskIntoConstraints = false
            saveDialogView?.addSubview(definitionLabel)

            let buttonsStackView = UIStackView()
            buttonsStackView.axis = .horizontal
            buttonsStackView.distribution = .fillEqually
            buttonsStackView.spacing = Constants.dialogButtonsStackSpacing
            buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
            saveDialogView?.addSubview(buttonsStackView)

            let saveButton = UIButton()
            saveButton.setTitle(Constants.saveButtonTitle, for: .normal)
        saveButton.backgroundColor = ThemeManager.shared.mainColor
            saveButton.addTarget(self, action: #selector(saveWord), for: .touchUpInside)
            buttonsStackView.addArrangedSubview(saveButton)

            let cancelButton = UIButton()
            cancelButton.setTitle(Constants.cancelButtonTitle, for: .normal)
            cancelButton.backgroundColor = ThemeManager.shared.defaultButton
            cancelButton.addTarget(self, action: #selector(dismissSaveDialog), for: .touchUpInside)
            buttonsStackView.addArrangedSubview(cancelButton)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSaveDialog))
            view.addGestureRecognizer(tapGesture)

            view.addSubview(saveDialogView!)
            NSLayoutConstraint.activate([
                saveDialogView!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                saveDialogView!.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                saveDialogView!.widthAnchor.constraint(equalToConstant: Constants.saveDialogWidth),
                saveDialogView!.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.saveDialogHeight)

            ])
            setupConstraintsForSaveDialog(titleLabel: titleLabel, wordLabel: wordLabel, definitionLabel: definitionLabel, buttonsStackView: buttonsStackView)
        }
        
    func setupConstraintsForSaveDialog(titleLabel: UILabel, wordLabel: UILabel, definitionLabel: UILabel, buttonsStackView: UIStackView) {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: saveDialogView!.topAnchor, constant: Constants.titleLabelTopMargin),
            titleLabel.centerXAnchor.constraint(equalTo: saveDialogView!.centerXAnchor),

            wordLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.wordGridMargin),
            wordLabel.centerXAnchor.constraint(equalTo: saveDialogView!.centerXAnchor),

            definitionLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: Constants.definitionTopMargin),
            definitionLabel.centerXAnchor.constraint(equalTo: saveDialogView!.centerXAnchor),
            definitionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: saveDialogView!.leadingAnchor, constant: Constants.definitionLeadingMargin),
            definitionLabel.trailingAnchor.constraint(lessThanOrEqualTo: saveDialogView!.trailingAnchor, constant: -Constants.definitionLeadingMargin),

            buttonsStackView.topAnchor.constraint(equalTo: definitionLabel.bottomAnchor, constant: Constants.buttonsStackTopMargin),
            buttonsStackView.centerXAnchor.constraint(equalTo: saveDialogView!.centerXAnchor),
            buttonsStackView.widthAnchor.constraint(equalTo: saveDialogView!.widthAnchor, multiplier: Constants.buttonsStackWidthMultiplier),
            buttonsStackView.bottomAnchor.constraint(equalTo: saveDialogView!.bottomAnchor, constant: -Constants.buttonsStackTopMargin)
        ])
    }
}

// MARK: - Button Actions
extension GameViewController {
    @objc func saveWord() {
        CoreDataManager.shared.createWord(word: gameModel.targetWord, definition: gameModel.wordDescription)
        dismissSaveDialog()
    }

    @objc func dismissSaveDialog() {
        saveDialogView?.removeFromSuperview()
    }

    @objc func keyPressed(_ sender: UIButton) {
        guard let key = sender.titleLabel?.text else { return }
    
        if key == "DELETE" {
            deleteLastCharacter()
        } else if key == "SUBMIT" {
            submitGuess()
        } else if key == "RESET" {
            resetGame()
        } else {
            addCharacter(key)
        }
    }

    private func deleteLastCharacter() {
        if !currentGuess.isEmpty {
            currentGuess.removeLast()
            updateCurrentGuessDisplay()
        }
    }
    private func addCharacter(_ character: String) {
        if currentGuess.count < gameModel.wordLength && !gameModel.hasWon && !gameModel.hasLost {
            currentGuess += character.lowercased()
            updateCurrentGuessDisplay()
        }
    }
}
