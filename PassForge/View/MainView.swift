//
//  MainView.swift
//  PassForge
//
//  Created by Maxim Golovlev on 08.06.2026.
//


import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = PasswordViewModel()
    @State private var isCopied = false
    @State private var isPasswordVisible = true // Состояние видимости пароля
    
    // Киберпанк палитра
    private let cyberYellow = Color(red: 0.95, green: 0.9, blue: 0.0)
    private let darkIndustrial = Color(red: 0.05, green: 0.05, blue: 0.06)
    private let panelGray = Color(red: 0.12, green: 0.13, blue: 0.15)
    
    var body: some View {
        NavigationView {
            ZStack {
                darkIndustrial
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // --- ШАПКА ПРИЛОЖЕНИЯ ---
                    VStack(spacing: 12) {
                        Text("PassForge")
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.black)
                            .foregroundColor(cyberYellow)
                        
                        Text("Secure crypto-key generator. Defend your digital perimeter against brute-force attacks by creating high-entropy passwords. Customize entropy bits below to forge absolute security on the fly.")
                            .font(.system(.caption, design: .default))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 34)
                            .lineSpacing(3)
                    }
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    // --- МОНОЛИТНЫЙ ДИСПЛЕЙ ПАРОЛЯ ---
                    VStack(spacing: 12) {
                        // Текстовое поле вывода с кнопкой «глаза»
                        ZStack(alignment: .trailing) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(cyberYellow.opacity(0.15), lineWidth: 1)
                                )
                            
                            // Выводим либо реальный пароль, либо маску из точек
                            Text(isPasswordVisible ? viewModel.generatedPassword : viewModel.maskedPassword)
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.5)
                                .padding(.horizontal, 48) // Увеличиваем отступы, чтобы текст не заезжал на кнопку глаз
                                .frame(maxWidth: .infinity)
                            
                            // Кнопка скрытия / показа
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isPasswordVisible.toggle()
                                }
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(isPasswordVisible ? cyberYellow : .gray)
                                    .frame(width: 36, height: 36)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.trailing, 8)
                        }
                        .frame(height: 64) // Высота по-прежнему намертво зафиксирована
                        
                        // Шкала надежности
                        HStack(spacing: 8) {
                            Text("SECURITY STATUS:")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            Text(viewModel.strengthLabel.text)
                                .font(.system(.caption2, design: .monospaced))
                                .fontWeight(.black)
                                .foregroundColor(viewModel.strengthLabel.color)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                ForEach(1...3, id: \.self) { index in
                                    Rectangle()
                                        .fill(index <= viewModel.passwordStrength ? viewModel.strengthLabel.color : Color.gray.opacity(0.2))
                                        .frame(width: 14, height: 6)
                                        .cornerRadius(1)
                                }
                            }
                        }
                        .frame(height: 14)
                    }
                    .padding(20)
                    .background(panelGray)
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    
                    // --- КНОПКА КОПИРОВАНИЯ ---
                    Button(action: {
                        UIPasteboard.general.string = viewModel.generatedPassword
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        
                        withAnimation(.easeInOut(duration: 0.2)) { isCopied = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.2)) { isCopied = false }
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: isCopied ? "checkmark.shield.fill" : "key.radiowaves.forward.fill")
                                .font(.system(size: 14))
                                .frame(width: 16, height: 16)
                            
                            Text(isCopied ? "KEY SECURED TO CLIPBOARD" : "EXTRACT GENERATED KEY")
                                .fontWeight(.black)
                        }
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(isCopied ? Color.green.opacity(0.15) : cyberYellow.opacity(0.1))
                        .foregroundColor(isCopied ? .green : cyberYellow)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isCopied ? Color.green.opacity(0.4) : cyberYellow.opacity(0.3), lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 24)
                    .padding(.top, 14)
                    
                    Spacer()
                    
                    // --- ПАНЕЛЬ НАСТРОЕК ---
                    VStack(spacing: 16) {
                        VStack(spacing: 6) {
                            HStack {
                                Text("KEY LENGTH")
                                    .font(.system(.caption2, design: .monospaced)).fontWeight(.bold).foregroundColor(.gray)
                                Spacer()
                                Text("\(Int(viewModel.passwordLength)) BITS")
                                    .font(.system(.caption, design: .monospaced)).fontWeight(.black).foregroundColor(cyberYellow)
                            }
                            
                            Slider(value: $viewModel.passwordLength, in: 8...32, step: 1.0, onEditingChanged: { _ in
                                viewModel.generatePassword()
                            })
                            .accentColor(cyberYellow)
                        }
                        
                        Divider().background(Color.white.opacity(0.05))
                        
                        VStack(spacing: 10) {
                            ToggleRow(title: "0-9 NUMERICAL DIGITS", isOn: $viewModel.includeNumbers) { viewModel.generatePassword() }
                            ToggleRow(title: "A-Z UPPERCASE LETTERS", isOn: $viewModel.includeUppercase) { viewModel.generatePassword() }
                            ToggleRow(title: "SPECIAL SYMBOLS (!@#$)", isOn: $viewModel.includeSymbols) { viewModel.generatePassword() }
                        }
                    }
                    .padding(20)
                    .background(panelGray)
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        viewModel.generatePassword()
                    }) {
                        Image(systemName: "goforward")
                            .font(.subheadline)
                            .foregroundColor(cyberYellow)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

