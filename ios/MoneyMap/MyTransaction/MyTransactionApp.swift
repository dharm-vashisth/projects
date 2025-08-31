//
//  MyTransactionApp.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 05/08/25.
//

import SwiftUI

@main
struct MyTransactionApp: App {
    @StateObject private var viewModel = TransactionViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }

}
