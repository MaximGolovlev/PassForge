//
//  ToggleRow.swift
//  PassForge
//
//  Created by Maxim Golovlev on 08.06.2026.
//

import SwiftUI


// --- ВСПОМОГАТЕЛЬНЫЙ КОМПОНЕНТ: СТРОКА ТУМБЛЕРА ---
struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let onChange: () -> Void
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.system(.caption2, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.95, green: 0.9, blue: 0.0)))
        .frame(height: 30) // Исключает прыжки при переключениях
        .onChange(of: isOn) { _ in
            onChange()
        }
    }
}
