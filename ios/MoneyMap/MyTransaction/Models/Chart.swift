//
//  Charts.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 05/08/25.
//


enum ChartType: String, CaseIterable, Identifiable {
    case pieChart = "Combine Balance Pie Chart"
    case monthlyBarLine = "Monthly Spending Bar Chart"
    case groupedBar = "Categorywise Grouped chart"
    case monthlySpendingChart = "Combined Monthly Spending Chart"

    var id: String { rawValue }
}

struct MonthlySpendingData: Identifiable {
    var id: String { month }
    var month: String
    let type: String
    var amount: Double
}

