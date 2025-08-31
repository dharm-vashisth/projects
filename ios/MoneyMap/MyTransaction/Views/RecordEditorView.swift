//
//  RecordEditorView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 05/08/25.
//

import SwiftUI

struct RecordEditorView: View {
    @State private var selectedTable: TableType = .transactions
    @EnvironmentObject var viewModel: TransactionViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Select a Table", selection: $selectedTable) {
                    ForEach(TableType.allCases) { table in
                        Text(table.rawValue).tag(table)
                    }
                }
                .pickerStyle(.segmented)
                
                Group{
                    
                    switch selectedTable {
                    case .transactions:
                        Text("Transaction Count: \(viewModel.transactions.count)")
                            .frame(maxWidth: .infinity,alignment: .trailing)
                            .padding(.horizontal)
                        
                        List{
                            ForEach(viewModel.transactions){ transaction in
                                TransactionRowView(transaction:transaction)
                            }
                        }
                    case .wallet:
                        Text("Transaction Count: \(viewModel.wallet.count)")
                            .frame(maxWidth: .infinity,alignment: .trailing)
                            .padding(.horizontal)
                        
                        List{
                            ForEach(viewModel.wallet){ wallet in
                                WalletTransactionRowView(wallet: wallet)
                            }
                        }
                    case .inflow:
                        Text("Transaction Count: \(viewModel.inflow.count)")
                            .frame(maxWidth: .infinity,alignment: .trailing)
                            .padding(.horizontal)
                        
                        List{
                            ForEach(viewModel.inflow){ inflow in
                                InflowRowView(inflow: inflow)
                            }
                        }
                    }
                }
            }.padding(.bottom, 8)
        }.navigationTitle("Transactions")
        
    }
}
