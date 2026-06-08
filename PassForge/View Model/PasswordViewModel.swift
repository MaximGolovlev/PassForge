//
//  PasswordViewModel.swift
//  PassForge
//
//  Created by Maxim Golovlev on 08.06.2026.
//


import SwiftUI
import Combine

class PasswordViewModel: ObservableObject {
    // Сохраняем настройки генератора в UserDefaults
    @AppStorage("forge_password_length") var passwordLength: Double = 12.0
    @AppStorage("forge_include_numbers") var includeNumbers: Bool = true
    @AppStorage("forge_include_symbols") var includeSymbols: Bool = false
    @AppStorage("forge_include_uppercase") var includeUppercase: Bool = true
    
    @Published var generatedPassword: String = ""
    
    // Возвращает строку из точек, соответствующую длине пароля
    var maskedPassword: String {
        String(repeating: "•", count: generatedPassword.count)
    }
    
    init() {
        generatePassword()
    }
    
    // Оценка надежности пароля (1 - Слабый, 2 - Средний, 3 - Криптостойкий)
    var passwordStrength: Int {
        let length = Int(passwordLength)
        var score = 0
        
        if length >= 8 { score += 1 }
        if length >= 14 { score += 1 }
        
        var activeTypes = 1 // Строчные буквы активны всегда
        if includeNumbers { activeTypes += 1 }
        if includeSymbols { activeTypes += 1 }
        if includeUppercase { activeTypes += 1 }
        
        if activeTypes >= 3 && length >= 10 { score += 1 }
        
        return max(1, min(3, score))
    }
    
    // Текстовое описание и цвет для шкалы надежности
    var strengthLabel: (text: String, color: Color) {
        switch passwordStrength {
        case 1:
            return ("VULNERABLE", Color.red)
        case 2:
            return ("SECURE", Color.orange)
        default:
            return ("FORTIFIED", Color.green)
        }
    }
    
    // Главная логика генерации пароля
    func generatePassword() {
        let lowercase = "abcdefghijklmnopqrstuvwxyz"
        let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        let symbols = "!@#$%^&*()_+-=[]{}|;:,.<>?"
        
        var pool = lowercase
        if includeUppercase { pool += uppercase }
        if includeNumbers { pool += numbers }
        if includeSymbols { pool += symbols }
        
        // Защита на случай, если пользователь выключил вообще всё
        if pool.isEmpty { pool = lowercase }
        
        let length = Int(passwordLength)
        var password = ""
        
        for _ in 0..<length {
            if let randomChar = pool.randomElement() {
                password.append(randomChar)
            }
        }
        
        self.generatedPassword = password
    }
}
