//
//  PreferenceView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 20/08/25.
//
import SwiftUI

struct PreferenceView: View {
    @Binding var isDarkMode: Bool
    @Binding var showBalance: Bool
    
    
    var body: some View {
        VStack{
            Toggle(isOn: $isDarkMode) {
                Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
            }
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            Toggle("Show Account Balance", isOn: $showBalance)
        }
    }
}
