//
//  InsightCard.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 08/08/25.
//
import SwiftUI

struct InsightCard: View {
    @AppStorage("showBalance") private var showBalance: Bool = true
    var title: String
    var value: String
    var masked: Bool? = nil

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text((masked ?? true) ? maskedAmount(value, showBalance: showBalance) : value)
                .font(.title2)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}
