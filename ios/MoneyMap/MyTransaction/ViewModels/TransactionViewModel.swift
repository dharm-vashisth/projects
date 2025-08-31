//
//  TransactionViewModel.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 05/08/25.
//

import Foundation
import SQLite

// pie chart for summary
struct BalanceSegment: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    var percentage: Double = 0.0  // ← Optional if you compute in View
}

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var wallet: [Wallet] = []
    @Published var inflow: [Inflow] = []
    @Published var combineBalance: CombineBalance?
    
    private let db = DBManager.shared
    
    // sql statements for views
    private let current_balance_data = "SELECT Current_Balance,inflow_total, expense_total FROM current_balance"
    private let combine_balance_data = "SELECT date,online,wallet,total_bal FROM combine_balance"
    
    init() {
        fetchTransactions()
        fetchWalletTransactions()
        fetchInflowTransactions()
        fetchCombineBalanceView()
    }
    
    // Insight Variables.
    
    var totalTransactionAmount: Double {
        let transactionSum = transactions.reduce(0) { $0 + $1.amount }
        let walletSum = wallet.reduce(0) { $0 + ($1.amount > 0 ? $1.amount : 0) }
        return transactionSum + walletSum
    }
    
    var totalInflowAmount: Double {
        let tran=transactions.reduce(0) { $0 + ($1.amount < 0 ? $1.amount : 0) }
        let wallet=wallet.reduce(0) { $0 + ($1.amount < 0 ? $1.amount : 0) }
        let inf = inflow.reduce(0) { $0 + ($1.amount > 0 ? $1.amount : 0) }
        return (-1*(wallet-tran))+inf
    }

    var totalOutflowAmount: Double {
        let tran=transactions.reduce(0) { $0 + ($1.amount > 0 ? $1.amount : 0) }
        let wallet=wallet.reduce(0) { $0 + ($1.amount > 0 ? $1.amount : 0) }
        return tran+wallet
    }
    
    var transactionTransactionCount: Int {
        transactions.count + wallet.count
    }
    
    var averageTransactionAmount: Double {
        transactions.isEmpty ? 0 : totalTransactionAmount / Double(transactionTransactionCount)
    }
    
    var totalWalletAmount: Double {
        wallet.reduce(0) { $0 + ($1.amount > 0 ? $1.amount : 0) }
    }
    
    var top3TransactionSpendingCategories: [(category: String, amount: Double)] {
        let totals = Dictionary(grouping: transactions, by: { $0.category })
            .mapValues { group in
                group.reduce(0) { $0 + $1.amount }
            }
        
        let sorted = totals
            .sorted(by: { $0.value > $1.value }) // descending order
            .prefix(3) // top 3
        
        return sorted.map { (category: $0.key, amount: $0.value) }
    }
    
    var totalByTransactionCategory: [String: Double] {
        Dictionary(grouping: transactions, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
    }
    
    // variables for chart
    
    private let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()
    
    var balanceSegments: [BalanceSegment] {
        guard let balance = combineBalance else { return [] }
        
        let values = [
            ("Online", balance.onlineBalance),
            ("Wallet", balance.wallet)
        ]
        
        let total = values.map(\.1).reduce(0, +)
        
        return values.map { (label, value) in
            BalanceSegment(label: label, value: value, percentage: total > 0 ? (value / total) * 100 : 0)
        }
    }
    
    var monthlyTransactionSpending: [(month: String, amount: Double)] {
        let grouped = Dictionary(grouping: transactions) { tx in
            Calendar.current.date(from:
                Calendar.current.dateComponents([.year, .month], from: tx.parsedDate)
            )!
        }.mapValues { $0.reduce(0) { $0 + $1.amount } }
        
        return grouped
            .sorted { $0.key < $1.key }
            .map { (month: monthFormatter.string(from: $0.key), amount: $0.value) }
    }
    
    var monthlySpendingData: [MonthlySpendingData] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        // Group transactions by month
        let transactionGroups = Dictionary(grouping: transactions) {
            formatter.string(from: $0.parsedDate)
        }.mapValues { $0.reduce(0) { $0 + $1.amount } }
        
        // Group wallet by month
        let walletGroups = Dictionary(grouping: wallet) {
            formatter.string(from: $0.parsedDate)
        }.mapValues {$0.reduce(0) { $0 + ($1.amount > 0 ? $1.amount : 0) }}
        
        // Collect all unique months
        let allMonths = Set(transactionGroups.keys).union(walletGroups.keys)
        
        
        var entries: [MonthlySpendingData] = []
        for month in allMonths {
            if let amount = transactionGroups[month], amount > 0 {
                entries.append(MonthlySpendingData(month: month, type: "Transactions", amount: amount))
            }
            if let amount = walletGroups[month], amount > 0 {
                entries.append(MonthlySpendingData(month: month, type: "Wallet", amount: amount))
            }
        }
        
        // Sort by date
        return entries.sorted {
            guard let d1 = formatter.date(from: $0.month),
                  let d2 = formatter.date(from: $1.month) else { return false }
            return d1 < d2
        }
    }
    
    // insights from views
    
    // variables
    
    var combineBalanceDictionary: [String: Any]? {
        combineBalance?.asDictionary
    }
    
    var combine_balance: Double {
        max(combineBalance?.totalBalance ?? 0, 0)
    }

    var combine_wallet_balance: Double {
        max(combineBalance?.wallet ?? 0, 0)
    }
    
    // Fetching methods
    
    // tables
    func fetchTransactions() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let rows = try self.db.db.prepare(self.db.transactions.order(self.db.id.desc))
                let items = rows.map { row in
                    Transaction(
                        id: row[self.db.id],
                        date: row[self.db.date],
                        amount: row[self.db.amount],
                        category: row[self.db.category],
                        description: row[self.db.description],
                        mode: row[self.db.mode] ?? "Online"
                    )
                }
                DispatchQueue.main.async { self.transactions = items }
            } catch {
                print("Error fetching transactions: \(error)")
            }
        }
    }
    
    func fetchWalletTransactions() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let rows = try self.db.db.prepare(self.db.wallet.order(self.db.id.desc))
                let items = rows.map { row in
                    Wallet(
                        id: row[self.db.id],
                        amount: row[self.db.amount],
                        date: row[self.db.date],
                        description: row[self.db.description],
                        creation_date: row[self.db.creationDate]
                    )
                }
                DispatchQueue.main.async {
                    self.wallet = items
                }
            } catch {
                print("Error fetching wallet transactions: \(error)")
            }
        }
    }

    
    func fetchInflowTransactions() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let rows = try self.db.db.prepare(self.db.inflow.order(self.db.id.desc))
                let items = rows.map { row in
                    Inflow(
                        id: row[self.db.id],
                        income_type: row[self.db.incomeType],
                        amount: row[self.db.amount],
                        date: row[self.db.date],
                        description: row[self.db.description],
                        creation_date: row[self.db.creationDate]
                    )
                }
                DispatchQueue.main.async {
                    self.inflow = items
                }
            } catch {
                print("Error fetching inflow transactions: \(error)")
            }
        }
    }
    
    //view
    
    func fetchCombineBalanceView() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let rows = try self.db.db.prepare(self.combine_balance_data)
                if let row = rows.first(where: { _ in true }) {
                    let item = CombineBalance(
                        today: row[0] as? String ?? "",
                        onlineBalance: row[1] as? Double ?? 0,
                        wallet: row[2] as? Double ?? 0,
                        totalBalance: row[3] as? Double ?? 0
                    )
                    DispatchQueue.main.async {
                        self.combineBalance = item
                    }
                } else {
                    print("No combine balance data found.")
                }
            } catch {
                print("Error fetching combine balance: \(error)")
            }
        }
    }
    
    // addition of transactions
    
    func addTransaction(date: String, amount: Double, category: String, description: String) {
        do {
            let insert = db.transactions.insert(
                db.date <- date,
                db.amount <- amount,
                db.category <- category,
                db.description <- description
            )
            try db.db.run(insert)
            fetchTransactions()
        } catch {
            print("Error adding transaction: \(error)")
        }
    }
    
    func addWalletTransaction(date: String, amount: Double, description: String) {
        do {
            let insert = db.wallet.insert(
                db.date <- date,
                db.amount <- amount,
                db.description <- description
            )
            try db.db.run(insert)
            fetchWalletTransactions()
        } catch {
            print("Error adding wallet transaction: \(error)")
        }
    }
    
    func addInflowTransaction(date: String, amount: Double, income_type: String, description: String) {
        do {
            let insert = db.inflow.insert(
                db.date <- date,
                db.amount <- amount,
                db.incomeType <- income_type,
                db.description <- description
            )
            try db.db.run(insert)
            fetchInflowTransactions()
        } catch {
            print("Error adding inflow transaction: \(error)")
        }
    }
    
    // deletion of transactions
    
    func deleteTransaction(id: Int64) {
        let transactionToDelete = db.transactions.filter(db.id == id)
        do {
            try db.db.run(transactionToDelete.delete())
            fetchTransactions()
        } catch {
            print("Error deleting transaction: \(error)")
        }
    }
    
    func deleteWalletTransaction(id: Int64) {
        let walletTransactionToDelete = db.wallet.filter(db.id == id)
        do {
            try db.db.run(walletTransactionToDelete.delete())
            fetchWalletTransactions()
        } catch {
            print("Error deleting wallet transaction: \(error)")
        }
    }
    
    func deleteInflowTransaction(id: Int64) {
        let inflowTransactionToDelete = db.inflow.filter(db.id == id)
        do {
            try db.db.run(inflowTransactionToDelete.delete())
            fetchInflowTransactions()
        } catch {
            print("Error deleting wallet transaction: \(error)")
        }
    }
    
    // updation of transaction.
    
    func updateTransaction(transaction: Transaction) {
        let row = db.transactions.filter(db.id == transaction.id)
        do {
            try db.db.run(row.update(
                db.date <- transaction.date,
                db.amount <- transaction.amount,
                db.category <- transaction.category,
                db.description <- transaction.description
            ))
            fetchTransactions()
        } catch {
            print("Error updating transaction: \(error)")
        }
    }
    
    func updateWalletTransaction(wallet: Wallet) {
        let row = db.wallet.filter(db.id == wallet.id)
        do {
            try db.db.run(row.update(
                db.date <- wallet.date,
                db.amount <- wallet.amount,
                db.description <- wallet.description
            ))
            fetchWalletTransactions()
        } catch {
            print("Error updating wallet transaction: \(error)")
        }
    }
    
    func updateInflowTransaction(inflow: Inflow) {
        let row = db.inflow.filter(db.id == inflow.id)
        do {
            try db.db.run(row.update(
                db.date <- inflow.date,
                db.amount <- inflow.amount,
                db.description <- inflow.description,
                db.incomeType <- inflow.income_type
            ))
            fetchInflowTransactions()
        } catch {
            print("Error updating wallet transaction: \(error)")
        }
    }
}
