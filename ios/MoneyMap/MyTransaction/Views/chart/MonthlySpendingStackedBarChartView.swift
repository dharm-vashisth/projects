//
//  MonthlySpendingStackedBarChartView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 20/08/25.
//

import SwiftUI
import Charts

struct MonthlySpendingStackedBarChartView: View {
    var monthlyData: [MonthlySpendingData]
    @AppStorage("showBalance") private var showBalance: Bool = true
    var totalPerMonth: [(month: String, amount: Double)] {
        Dictionary(grouping: monthlyData, by: { $0.month })
            .map { (month, entries) in
                (month, entries.reduce(0) { $0 + $1.amount })
            }
    }
    
    var body: some View {
        Chart {
            // Stacked Bars
            ForEach(monthlyData) { entry in
                BarMark(
                            x: .value("Month", entry.month),
                            y: .value("Amount", entry.amount)
                        )
                        .foregroundStyle(by: .value("Type", entry.type))
            }
            // One total label per month
              ForEach(totalPerMonth, id: \.month) { total in
                  BarMark(
                      x: .value("Month", total.month),
                      y: .value("Amount", total.amount)
                  )
                  .opacity(0) // invisible bar, just to attach annotation
                  .annotation(position: .overlay) {
                      Text(maskedAmount(total.amount,showBalance: showBalance))
                          .foregroundColor(.primary)
                          .font(.caption)
                          .bold()
                  }
              }
        }
        .frame(height: 320)
        .padding()
        .chartLegend(position: .bottom)
    }
}
