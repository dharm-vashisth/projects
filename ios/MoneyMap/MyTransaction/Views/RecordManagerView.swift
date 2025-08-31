//
//  RecordManagerView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 13/08/25.
//

import SwiftUI

struct RecordManagerView: View {
    @State private var selectedTable: TableType = .transactions
    
    var body: some View {
        NavigationStack {
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
                        TransactionListView()
                    case .wallet:
                        WalletTransactionListView()
                    case .inflow:
                        InflowListView()
                    }
                }
            }.padding(.bottom, 8)
        }
    }
    
}
