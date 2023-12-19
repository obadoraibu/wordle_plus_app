//
//  HomeViewController.swift
//  wordlePlus
//
//  Created by Egor Zavyalov on 10.12.2023.
//

import UIKit

class HomeViewController: UIViewController {
    
    enum Constants {
        static let defaultWordLength: Int = 4
        static let titleLabelText: String = "Wordle+"
        
        static let dialogCornerRadius: CGFloat = 10
        static let dialogButtonsStackSpacing: CGFloat = 10
        static let infoDialogWidth: CGFloat = 300
        static let infoDialogHeight: CGFloat = 200
        static let infoDialogBorderWidth: CGFloat = 1
        
        static let buttonBorderWidth: CGFloat = 1
        static let buttonCornerRadius: CGFloat = 1
        static let buttonFontSize: CGFloat = 20
        
        static let homeButtonsSpacing: CGFloat = 10
        static let homeButtonsLeadingAnchorConstraint: CGFloat = 60
        static let homeButtonsTrailingAnchorConstraint: CGFloat = -60

        static let iconButtonsPointSize: CGFloat = 30
        static let iconButtonsBottomAnchorConstraint: CGFloat = -20
        static let iconButtonsTrailingAnchorConstraint: CGFloat = -40
        static let iconButtonsLeadingAnchorConstraint: CGFloat = 40
        
        
        static let fourLetterButtonText: String = "4 letters"
        static let fiveLetterButtonText: String = "PLAY"
        static let sixLetterButtonText: String = "6 letters"
        static let dictionaryButtonText: String = "dictionary"
        
        static let infoDialogTitleLabelText: String = "INFO"
        static let infoDialogInfoLabelText: String = "Created by Egor Zavylov | 2023"
        static let infoDialogTitleLabelTopAnchorConstraint: CGFloat = 20
        static let infoDialogInfoLabelTopAnchorConstraint: CGFloat = 10
        static let infoDialogLeadingLabelTopAnchorConstraint: CGFloat = 20
        static let infoDialogInfoLabelTrailingAnchorConstraint: CGFloat = -20
        static let titleLabelFontSize: CGFloat = 40
        static let titleLabelBottomAnchor: CGFloat = -40
    }
    
    // UI Elements
    private let titleLabel = UILabel()
    private let fourLetterButton = UIButton()
    private let fiveLetterButton = UIButton()
    private let sixLetterButton = UIButton()
    private let dictionaryButton = UIButton()
    private var infoDialogView: UIView?
    
    private let infoButton = UIButton()
    private let themeChangeButton = UIButton()

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - UI Configuration
    private func configureUI() {
        view.backgroundColor = ThemeManager.shared.bgColor
        configureButtons()
        configureTitleLabel()
        configureInfoButton()
        configureThemeChangeButton()
    }
    
    // MARK: - Theme Change
    func changeTheme() {
        view.backgroundColor = ThemeManager.shared.bgColor
        titleLabel.textColor = ThemeManager.shared.newTextColor
        updateButtonColors()
    }
    
    private func updateButtonColors() {
        let buttons = [fourLetterButton, sixLetterButton, dictionaryButton]
        for button in buttons {
            button.setTitleColor(ThemeManager.shared.newTextColor, for: .normal)
            button.setTitleColor(.white, for: .highlighted)
            button.setTitleColor(.white, for: .disabled)
        }
    }
}

// MARK: - InfoDialog setup
extension HomeViewController {
    func setupInfoDialog() {
        infoDialogView = UIView()
        infoDialogView?.backgroundColor = ThemeManager.shared.bgColor
        infoDialogView?.layer.cornerRadius = Constants.dialogCornerRadius
        infoDialogView?.translatesAutoresizingMaskIntoConstraints = false
        infoDialogView?.layer.borderWidth = Constants.infoDialogBorderWidth
        infoDialogView?.layer.borderColor = ThemeManager.shared.defaultButton.cgColor

        let titleLabel = UILabel()
        titleLabel.text = Constants.infoDialogTitleLabelText
        titleLabel.textColor = ThemeManager.shared.newTextColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoDialogView?.addSubview(titleLabel)
        
        let infoLabel = UILabel()
        infoLabel.text = Constants.infoDialogInfoLabelText
        infoLabel.numberOfLines = 0
        infoLabel.textColor = ThemeManager.shared.newTextColor
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoDialogView?.addSubview(infoLabel)


        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSaveDialog))
        view.addGestureRecognizer(tapGesture)

        view.addSubview(infoDialogView!)
        NSLayoutConstraint.activate([
            infoDialogView!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoDialogView!.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoDialogView!.widthAnchor.constraint(equalToConstant: Constants.infoDialogWidth),
            infoDialogView!.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.infoDialogHeight)

        ])
        setupConstraintsForSaveDialog(titleLabel: titleLabel, infoLabel: infoLabel)
    }
        
    func setupConstraintsForSaveDialog(titleLabel: UILabel, infoLabel: UILabel) {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: infoDialogView!.topAnchor, constant: Constants.infoDialogTitleLabelTopAnchorConstraint),
            titleLabel.centerXAnchor.constraint(equalTo: infoDialogView!.centerXAnchor),

            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.infoDialogInfoLabelTopAnchorConstraint),
            infoLabel.centerXAnchor.constraint(equalTo: infoDialogView!.centerXAnchor),
            infoLabel.leadingAnchor.constraint(greaterThanOrEqualTo: infoDialogView!.leadingAnchor, constant: Constants.infoDialogLeadingLabelTopAnchorConstraint),
            infoLabel.trailingAnchor.constraint(lessThanOrEqualTo: infoDialogView!.trailingAnchor, constant: Constants.infoDialogInfoLabelTrailingAnchorConstraint),
        ])
    }

    @objc func dismissSaveDialog() {
        infoDialogView?.removeFromSuperview()
    }
}

// MARK: - UI Setup Helpers
extension HomeViewController {
    private func configureTitleLabel() {
        titleLabel.text = Constants.titleLabelText
        titleLabel.textColor = ThemeManager.shared.newTextColor
        titleLabel.font = UIFont.systemFont(ofSize: Constants.titleLabelFontSize, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = true
        view.addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: fiveLetterButton.topAnchor, constant: Constants.titleLabelBottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func configureButtons() {
        configureButton(fiveLetterButton, title: Constants.fiveLetterButtonText, textColor: ThemeManager.shared.mainTextColor, bgColor: ThemeManager.shared.mainColor, action: #selector(fiveLetterAction))
        configureButton(fourLetterButton, title: Constants.fourLetterButtonText, textColor: ThemeManager.shared.newTextColor, bgColor: .clear, action: #selector(fourLetterAction))
        configureButton(sixLetterButton, title: Constants.sixLetterButtonText, textColor: ThemeManager.shared.newTextColor, bgColor: .clear, action: #selector(sixLetterAction))
        configureButton(dictionaryButton, title: Constants.dictionaryButtonText, textColor: ThemeManager.shared.newTextColor, bgColor: .clear, action: #selector(dictionaryAction))

        let stackView = UIStackView(arrangedSubviews: [fiveLetterButton, fourLetterButton, sixLetterButton, dictionaryButton])
        stackView.axis = .vertical
        stackView.spacing = Constants.homeButtonsSpacing
        stackView.distribution = .fillEqually
        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.homeButtonsLeadingAnchorConstraint),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.homeButtonsTrailingAnchorConstraint)
        ])
    }
    
    private func configureButton(_ button: UIButton, title: String, textColor: UIColor, bgColor: UIColor, action: Selector) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: Constants.buttonFontSize, weight: .bold)
        button.backgroundColor = bgColor
        button.layer.borderWidth = Constants.buttonBorderWidth
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.addTarget(self, action: action, for: .touchUpInside)
    }
    
    private func configureInfoButton() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: Constants.iconButtonsPointSize, weight: .regular)
        let largeSymbolImage = UIImage(systemName: "info.circle.fill", withConfiguration: largeConfig)
        infoButton.setImage(largeSymbolImage, for: .normal)
        infoButton.tintColor = ThemeManager.shared.defaultButton
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)

        view.addSubview(infoButton)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.iconButtonsBottomAnchorConstraint),
            infoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.iconButtonsTrailingAnchorConstraint)
        ])
    }

    private func configureThemeChangeButton() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: Constants.iconButtonsPointSize, weight: .regular)
        let largeSymbolImage = UIImage(systemName: "swirl.circle.righthalf.filled", withConfiguration: largeConfig)
        themeChangeButton.setImage(largeSymbolImage, for: .normal)
        themeChangeButton.tintColor = ThemeManager.shared.defaultButton
        themeChangeButton.addTarget(self, action: #selector(themeChangeButtonTapped), for: .touchUpInside)
        
        
        view.addSubview(themeChangeButton)
        themeChangeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            themeChangeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.iconButtonsBottomAnchorConstraint),
            themeChangeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.iconButtonsLeadingAnchorConstraint)
        ])
    }
}

// MARK: - Actions
extension HomeViewController {
    @objc private func themeChangeButtonTapped() {
        ThemeManager.shared.changeTheme()
        changeTheme()
    }
    
    @objc private func infoButtonTapped() {
        setupInfoDialog()
    }

    @objc private func fourLetterAction() {
        let gameVC = GameViewController()
        gameVC.wordLength = 4
        present(gameVC, animated: true, completion: nil)
    }
    @objc private func fiveLetterAction() {
        let gameVC = GameViewController()
        gameVC.wordLength = 5
        present(gameVC, animated: true, completion: nil)
    }
    @objc private func sixLetterAction() {
        let gameVC = GameViewController()
        gameVC.wordLength = 6
        present(gameVC, animated: true, completion: nil)
    }
    
    @objc private func dictionaryAction() {
        let dictionaryVC = DictionaryViewController()
        present(dictionaryVC, animated: true, completion: nil)
    }
}
