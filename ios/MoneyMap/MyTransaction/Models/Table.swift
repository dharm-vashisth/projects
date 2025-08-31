//
//  Table.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 08/08/25.
//

enum TableType: String, CaseIterable, Identifiable {
    case transactions = "Transactions"
    case wallet = "Wallet"
    case inflow = "Inflow"

    var id: String { self.rawValue }
}
