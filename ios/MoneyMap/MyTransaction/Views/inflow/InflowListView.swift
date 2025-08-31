//
//  TransactionListView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 05/08/25.
//
import SwiftUI

struct InflowListView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @State private var showingAddForm = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                InsightCard(title: "Transactions Count: (\(viewModel.inflow.count))", value: "Table: Inflow", masked: false)
                
                List {
                    ForEach(viewModel.inflow) { tx in
                        InflowRowView(inflow: tx)
                            .swipeActions{
                                Button(role: .destructive) {
                                    viewModel.deleteInflowTransaction(id: tx.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deleteInflowTransaction(id: tx.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }.padding(.bottom, 8)
        }.navigationTitle("Inflow Transactions List")
            .toolbar {
                Button {
                    showingAddForm.toggle()
                } label: {
                    Label("Add Transaction", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddForm) {
                InflowFormView()
                    .environmentObject(viewModel)
            }
    }
}
