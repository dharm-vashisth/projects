//
//  DataVisualizationView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 05/08/25.
//

import SwiftUI

struct DataVisualizationView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @State private var selectedChart: ChartType = .pieChart

    var body: some View {
        NavigationStack {
            ScrollView{
                VStack {
                    Picker("Select Chart", selection: $selectedChart) {
                        ForEach(ChartType.allCases) { chart in
                            Text(chart.rawValue).tag(chart)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .padding()
                    
                    Spacer()
                    
                    // Show chart based on selection
                    Group {
                        switch selectedChart {
                        case .monthlySpendingChart:
                            MonthlySpendingStackedBarChartView(monthlyData: viewModel.monthlySpendingData)
                        case .groupedBar:
                            GroupedCategoryChartView()
                        case .monthlyBarLine:
                            MonthlySpendingBarChartView(monthlySpending: viewModel.monthlyTransactionSpending)
                        case .pieChart:
                            CombineBalancePieChartView(segments: viewModel.balanceSegments)
                        }
                    }
                    .animation(.easeInOut, value: selectedChart)
                    .padding()
                    
                    Spacer()
                }
            }
        }.navigationTitle("Charts")
    }
}
