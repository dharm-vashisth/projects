//
//  InflowRowView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 14/08/25.
//

import SwiftUI

struct InflowRowView: View {
    @AppStorage("showBalance") private var showBalance: Bool = true
    
    let inflow: Inflow

    var body: some View {
        NavigationLink(destination: InflowFormView(transaction: inflow)) {
            VStack(alignment: .leading) {
                Text(inflow.income_type)
                    .font(.headline)
                if inflow.description != "NA" {
                    Text(inflow.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(inflow.parsedDate, style: .date).foregroundColor(.secondary)
                    Spacer()
                    Text(maskedAmount(inflow.amount, showBalance: showBalance))
                        .bold()
                }
            }
        }
    }
}
