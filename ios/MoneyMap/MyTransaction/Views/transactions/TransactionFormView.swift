//
//  TransactionFormView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 05/08/25.
//


import SwiftUI

struct TransactionFormView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @Environment(\.dismiss) var dismiss

    var transactionToEdit: Transaction?

    @State private var date: Date
    @State private var dateString: String
    @State private var amount: String
    @State private var category: String
    @State private var description: String

    init(transaction: Transaction? = nil) {
        self.transactionToEdit = transaction

        // Initialize states with existing data or defaults
        let parsedDate = transaction
            .flatMap { DateHelper.parse($0.date)} ?? Date()

        _date = State(initialValue: parsedDate)
        _dateString = State(initialValue: DateHelper.format(parsedDate))
        _amount = State(initialValue: transaction != nil ? String(transaction!.amount) : "")
        _category = State(initialValue: transaction?.category ?? "")
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
            TextField("Category", text: $category)
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
        guard let amt = Double(amount), !category.isEmpty else { return }

        if let tx = transactionToEdit {
            // Update existing
            let updated = Transaction(id: tx.id, date: dateString, amount: amt, category: category, description: description, mode: tx.mode)
            viewModel.updateTransaction(transaction: updated)
        } else {
            // Add new
            viewModel.addTransaction(date: dateString, amount: amt, category: category, description: description)
        }

        dismiss()
    }
}
