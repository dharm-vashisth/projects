//
//  TransactionChartView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 05/08/25.
//

import SwiftUI
import Charts

struct GroupedTransaction: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let category: String
    let totalAmount: Double
}


// Hashable key to group transactions by day and category
struct DateCategoryKey: Hashable {
    let date: Date
    let category: String
}


struct GroupedCategoryChartView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    
    
    var groupedData: [GroupedTransaction] {
        let calendar = Calendar.current

        // Group by month (year+month) and category
        let grouped = Dictionary(grouping: viewModel.transactions) { tx -> DateCategoryKey in
            guard let parsedDate = DateHelper.parse(tx.date) else {
                // Skip transactions with invalid dates
                return DateCategoryKey(date: Date.distantPast, category: tx.category)
            }

            // Extract year and month components for grouping by month
            var comps = calendar.dateComponents([.year, .month], from: parsedDate)
            comps.day = 1 // Set day to 1 to normalize the date to the first of the month
            let monthDate = calendar.date(from: comps) ?? Date.distantPast

            return DateCategoryKey(date: monthDate, category: tx.category)
        }

        return grouped.map { (key, transactions) in
            let total = transactions.reduce(0) { $0 + $1.amount }
            return GroupedTransaction(date: key.date, category: key.category, totalAmount: total)
        }
        .filter { $0.date != Date.distantPast } // remove bad entries
        .sorted { $0.date < $1.date }
    }

    var body: some View {
        Chart {
            ForEach(groupedData) { item in
                BarMark(
                    x: .value("Month", item.date, unit: .month),
                    y: .value("Amount", item.totalAmount),
                    stacking: .normalized
                )
                .foregroundStyle(by: .value("Category", item.category))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated))
            }
        }
        .frame(height: 300)
        .padding()
    }

}
