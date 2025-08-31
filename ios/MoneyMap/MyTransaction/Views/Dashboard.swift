//
//  Dashboard.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 08/08/25.
//

import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @AppStorage("displayName") private var displayName: String = "User"
    @AppStorage("showBalance") private var showBalance: Bool = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Insight Hub")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                            .bold()
                        
                        Text("Welcome, \(displayName)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    // MARK: - Inshort balance sheet
                    VStack {
                        Text("Total Transactions")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("\(viewModel.transactionTransactionCount)")
                            .font(.title2)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 1)

                    
                    // MARK: - Summary section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Summary")
                            .font(.headline)

                        if let item = viewModel.combineBalanceDictionary {
                            let displayOrder = ["Today", "Online_Balance", "Wallet", "Total_Balance"]
                            
                            ForEach(displayOrder, id: \.self) { key in
                                if key != "Today" {
                                    HStack {
                                        Text(key)
                                            .fontWeight(.medium)
                                        Spacer()
                                        if let amount = item[key] as? Double {
                                            Text(maskedAmount(amount,showBalance: showBalance))
                                                .foregroundColor(.green)
                                        } else if let value = item[key] as? String {
                                            Text(maskedAmount(value,showBalance: showBalance))
                                                .foregroundColor(.secondary)
                                        } else {
                                            Text("-")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)

                    // MARK: - Summary Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        FlipInsightCard(title: "Inflow", value: viewModel.totalInflowAmount)
                        FlipInsightCard(title: "OutFlow", value: viewModel.totalOutflowAmount)
                        FlipInsightCard(title: "Transaction Expense", value: viewModel.totalTransactionAmount)
                        FlipInsightCard(title: "Wallet Expense", value: viewModel.totalWalletAmount)
                    }

                    // MARK: - Top Categories
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Top 3 Spending Categories")
                            .font(.headline)

                        ForEach(viewModel.top3TransactionSpendingCategories, id: \.category) { item in
                            FlipInsightCard(title: item.category, value: item.amount)
                            Divider()
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)

                    // MARK: - Monthly Spending Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Monthly Spending")
                            .font(.headline)
                        MonthlySpendingStackedBarChartView(monthlyData: viewModel.monthlySpendingData)
                            .frame(height: 300)
                    }

                    // MARK: - Category Spending Breakdown
                    CategorySpendingView(
                        categoryTotals: viewModel.totalByTransactionCategory
                            .map { (category: $0.key, amount: $0.value) }
                            .sorted { $0.amount > $1.amount }
                            .map { ($0.category, $0.amount) }
                    )
                }
                .padding()
            }
        }
    }
}
