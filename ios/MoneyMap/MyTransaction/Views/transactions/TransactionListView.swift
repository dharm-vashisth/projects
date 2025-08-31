//
//  TransactionListView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 05/08/25.
//
import SwiftUI

struct TransactionListView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @State private var showingAddForm = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                InsightCard(title: "Transactions Count: (\(viewModel.transactions.count))", value: "Table: Transaction", masked: false)
                
                List {
                    ForEach(viewModel.transactions) { tx in
                        TransactionRowView(transaction: tx)
                            .swipeActions{
                                Button(role: .destructive) {
                                    viewModel.deleteTransaction(id: tx.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deleteTransaction(id: tx.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }.padding(.bottom, 8)
        }.navigationTitle("Transactions List")
            .toolbar {
                Button {
                    showingAddForm.toggle()
                } label: {
                    Label("Add Transaction", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddForm) {
                TransactionFormView()
                    .environmentObject(viewModel)
            }
    }
}
