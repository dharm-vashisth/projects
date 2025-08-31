//
//  WalletTransactionListView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 13/08/25.
//
import SwiftUI

struct WalletTransactionListView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @State private var showingAddWalletForm = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                InsightCard(title: "Transactions Count: (\(viewModel.wallet.count))", value: "Table: Wallet", masked: false)
                
                List {
                    ForEach(viewModel.wallet) { tx in
                        WalletTransactionRowView(wallet: tx)
                            .swipeActions{
                                Button(role: .destructive) {
                                    viewModel.deleteWalletTransaction(id: tx.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deleteWalletTransaction(id: tx.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }.padding(.bottom, 8)
        }.navigationTitle("Wallet Transactions List")
            .toolbar {
                Button {
                    showingAddWalletForm.toggle()
                } label: {
                    Label("Add Wallet Transaction", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddWalletForm) {
                WalletTransactionFormView()
                    .environmentObject(viewModel)
            }
    }
}
