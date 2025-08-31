//
//  FlipInsightCard.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 14/08/25.
//

import SwiftUI

struct FlipInsightCard: View {
    @AppStorage("showBalance") private var showBalance: Bool = true
    var title: String
    var value: Double

    @State private var isFlipped = false

    var body: some View {
        ZStack {
            // Front Side
            VStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(radius: 1)
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )

            // Back Side
            VStack {
                Text(maskedAmount(value,showBalance: showBalance))
                    .font(.title2)
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(radius: 1)
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(
                .degrees(isFlipped ? 0 : -180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.5)) {
                isFlipped.toggle()
            }
        }
    }
}
