//
//  TransactionRowView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 10/08/25.
//

import SwiftUI

struct TransactionRowView: View {
    @AppStorage("showBalance") private var showBalance: Bool = true
    
    let transaction: Transaction

    var body: some View {
        NavigationLink(destination: TransactionFormView(transaction: transaction)) {
            VStack(alignment: .leading) {
                Text(transaction.category)
                    .font(.headline)
                Text(transaction.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Text(transaction.parsedDate, style: .date)
                    Spacer()
                    Text(maskedAmount(transaction.amount, showBalance: showBalance))
                        .bold()
                }
            }
        }
    }
}
