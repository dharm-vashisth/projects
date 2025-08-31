//
//  TransactionFormView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 05/08/25.
//


import SwiftUI

struct InflowFormView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @Environment(\.dismiss) var dismiss

    var transactionToEdit: Inflow?

    @State private var date: Date
    @State private var dateString: String
    @State private var amount: String
    @State private var description: String
    @State private var income_type: String

    init(transaction: Inflow? = nil) {
        self.transactionToEdit = transaction

        // Initialize states with existing data or defaults
        let parsedDate = transaction
            .flatMap { DateHelper.parse($0.date)} ?? Date()

        _date = State(initialValue: parsedDate)
        _dateString = State(initialValue: DateHelper.format(parsedDate))
        _amount = State(initialValue: transaction != nil ? String(transaction!.amount) : "")
        _description = State(initialValue: transaction?.description ?? "")
        _income_type = State(initialValue: transaction?.income_type ?? "")
    }

    var body: some View {
        Form {
            DatePicker("Date", selection: $date, displayedComponents: [.date])
                .onChange(of: date) { _, newDate in
                    dateString = DateHelper.format(newDate)
                }
            TextField("Amount", text: $amount)
                .keyboardType(.numbersAndPunctuation)
            TextField("Income Type", text: $income_type)
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
        let amt = Double(amount) ?? 0.0

        if let tx = transactionToEdit {
            // Update existing
            let updated = Inflow(id: tx.id,income_type: income_type, amount: amt,  date: dateString, description: description)
            viewModel.updateInflowTransaction(inflow: updated)
        } else {
            // Add new
            viewModel.addInflowTransaction(date: dateString, amount: amt, income_type: income_type, description: description)
        }

        dismiss()
    }
}
