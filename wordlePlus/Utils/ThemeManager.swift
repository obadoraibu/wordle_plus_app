//
//  ThemeManager.swift
//  wordlePlus
//
//  Created by Egor Zavyalov on 17.12.2023.
//

import UIKit

class ThemeManager {
    enum Theme: String {
        case dark
        case light
    }
    
    static let shared = ThemeManager()
    
    var currentTheme: Theme = .light
    
    var bgColor: UIColor = .white
    
    var mainColor: UIColor = .customPurple
    
    var secondaryColor: UIColor = .customYellow
    
    var defaultButton: UIColor = .customLightGrayButton
    
    var wrongGuess: UIColor = .customDarkGrayPressedButton
    
    var newTextColor: UIColor = .black
    
    let mainTextColor: UIColor = .white
    
    var disabledButton: UIColor = .customDisabledButton
    
    private init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "Theme"),
            let theme = Theme(rawValue: savedTheme) {
                currentTheme = theme
        }
        configureForTheme()
    }
    
    func configureForTheme() {
        bgColor = currentTheme == .light ? .white : .customDarkGrayBG
        newTextColor = currentTheme == .light ? .black : .white
    }
    
    func saveTheme(_: Theme) {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: "Theme")
    }
    
    func changeTheme() {
        if currentTheme == .light {
            currentTheme = .dark
        } else {
            currentTheme = .light
        }
        saveTheme(currentTheme)
        configureForTheme()
    }
}

extension UIColor {
    static let customPurple = UIColor(hex: 0x528D4C)
    static let customYellow = UIColor(hex: 0xB59F3C)
    static let customDarkGrayBG = UIColor(hex: 0x121212)
    static let customDarkGrayPressedButton = UIColor(hex: 0x3A3A3C)
    static let customLightGrayButton = UIColor(hex: 0x828385)
    static let customDisabledButton = UIColor(hex: 0xeeeeee)
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
