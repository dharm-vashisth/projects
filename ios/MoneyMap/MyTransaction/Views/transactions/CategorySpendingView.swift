//
//  CategoryWiseSpendingView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 10/08/25.
//

import SwiftUI

struct CategorySpendingView: View {
    let categoryTotals: [(category: String, amount: Double)]
    @State private var expanded = false
    @AppStorage("showBalance") private var showBalance: Bool = true
    let initialCount = 3  // How many to show initially

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.title2)
                .bold()
                .padding(.bottom, 8)

            // Show limited or full list
            let displayedEntries = expanded ? categoryTotals : Array(categoryTotals.prefix(initialCount))

            ForEach(displayedEntries, id: \.category) { entry in
                HStack {
                    Text(entry.category)
                        .font(.body)
                    Spacer()
                    Text(maskedAmount(entry.amount,showBalance: showBalance))
                        .font(.body)
                        .foregroundColor(.green)
                }
                .padding(.horizontal)
            }

            // Show Read More / Read Less button only if items are more than initialCount
            if categoryTotals.count > initialCount {
                Button(action: {
                    withAnimation {
                        expanded.toggle()
                    }
                }) {
                    Text(expanded ? "Read Less" : "Read More")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
}
