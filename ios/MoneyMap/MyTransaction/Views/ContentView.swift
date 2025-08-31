//
//  ContentView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 05/08/25.
//


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some View {
        // MARK: - Tab View
        TabView {
            NavigationStack {
                Dashboard()
            }
            .tabItem {
                Label("Dashboard", systemImage:  "rectangle.grid.2x2")
            }
            NavigationStack {
                RecordEditorView()
            }
            .tabItem {
                Label("Records", systemImage: "list.bullet")
            }
            NavigationStack {
                RecordManagerView()
            }
            .tabItem {
                Label("Manage Records", systemImage: "pencil")
            }

            NavigationStack {
                DataVisualizationView()
            }
            .tabItem {
                Label("Analytical", systemImage: "chart.pie")
            }
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }.tint(.red)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
