//
//  MonthlySpendingBarChartView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 20/08/25.
//

import SwiftUI
import Charts

struct MonthlySpendingBarChartView: View {
    let monthlySpending: [(month: String, amount: Double)]
    @AppStorage("showBalance") private var showBalance: Bool = true
    var body: some View {
        Chart {
            // Bar Chart
            ForEach(monthlySpending, id: \.month) { entry in
                BarMark(
                    x: .value("Month", entry.month),
                    y: .value("Spending", entry.amount)
                )
                .foregroundStyle(.blue)
                .annotation(position: .top) {
                    Text(maskedAmount(entry.amount,showBalance: showBalance))
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
        }.frame(height: 300)
    }
}

