//
//  WalletTransactionRowView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 13/08/25.
//

import SwiftUI

struct WalletTransactionRowView: View {
    @AppStorage("showBalance") private var showBalance: Bool = true
    
    let wallet: Wallet

    var body: some View {
        NavigationLink(destination: WalletTransactionFormView(transaction: wallet)) {
            VStack(alignment: .leading) {
                Text(wallet.description)
                    .font(.headline)
                
                HStack {
                    Text(wallet.parsedDate, style: .date).foregroundColor(.secondary)
                    Spacer()
                    Text(maskedAmount(wallet.amount, showBalance: showBalance))
                        .bold()
                }
            }
        }
    }
}
