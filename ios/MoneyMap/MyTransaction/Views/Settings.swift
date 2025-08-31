//
//  Settings.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 14/08/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("showBalance") private var showBalance: Bool = true
    
    @State private var showToast = false
    @State private var backupMessage: String?
    
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                // Profile Section
                Section(header: Text("Profile")) {
                    ProfileView()
                }
                
                // Display Preferences Section
                Section(header: Text("Display")) {
                    PreferenceView(isDarkMode: $isDarkMode, showBalance: $showBalance)
                }
                
                Section(header: Text("Data Management")) {
                    BackupView(backupMessage: $backupMessage, showToast:$showToast)
                }
                
                // About Section
                Section(header: Text("About")) {
                    AboutView()
                }
            }
            .navigationTitle("Settings")
            
            // Toast Overlay on top
            if showToast, let msg = backupMessage {
                ToastView(message: msg)
            }
            
        }
    }
}
