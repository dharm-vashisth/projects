//
//  WalletTransactionFormView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 13/08/25.
//


import SwiftUI

struct WalletTransactionFormView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @Environment(\.dismiss) var dismiss

    var transactionToEdit: Wallet?

    @State private var date: Date
    @State private var dateString: String
    @State private var amount: String
    @State private var description: String

    init(transaction: Wallet? = nil) {
        self.transactionToEdit = transaction

        // Initialize states with existing data or defaults
        let parsedDate = transaction
            .flatMap { DateHelper.parse($0.date)} ?? Date()

        _date = State(initialValue: parsedDate)
        _dateString = State(initialValue: DateHelper.format(parsedDate))
        _amount = State(initialValue: transaction != nil ? String(transaction!.amount) : "")
        _description = State(initialValue: transaction?.description ?? "")
    }

    var body: some View {
        Form {
            DatePicker("Date", selection: $date, displayedComponents: [.date])
                .onChange(of: date) { _, newDate in
                    dateString = DateHelper.format(newDate)
                }
            TextField("Amount", text: $amount)
                .keyboardType(.numbersAndPunctuation)
            TextField("Notes", text: $description)

            Button(action: save) {
                Label(transactionToEdit == nil ? "Add Transaction" : "Update Transaction",
                      systemImage: transactionToEdit == nil ? "plus.circle" : "checkmark.circle")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
        .navigationTitle(transactionToEdit == nil ? "Add Transaction" : "Edit Transaction")
    }

    func save() {
        let amt = Double(amount) ?? 0

        if let tx = transactionToEdit {
            // Update existing
            let updated = Wallet(id: tx.id, amount: amt, date: dateString,  description: description, creation_date: tx.creation_date)
            viewModel.updateWalletTransaction(wallet: updated)
        } else {
            // Add new
            viewModel.addWalletTransaction(date: dateString, amount: amt, description: description)
        }

        dismiss()
    }
}
