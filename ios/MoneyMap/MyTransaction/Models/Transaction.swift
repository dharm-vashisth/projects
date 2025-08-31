//
//  Transaction.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 05/08/25.
//

import Foundation

struct Transaction: Identifiable {
    var id: Int64
    let date: String
    var amount: Double
    var category: String
    var description: String
    var mode: String?
    var parsedDate: Date {
        DateHelper.parse(date) ?? Date.distantPast
    }
}

struct Wallet: Identifiable {
    var id: Int64
    var amount: Double
    var date: String
    var description: String
    var creation_date: String?
    var parsedDate: Date {
        DateHelper.parse(date) ?? Date.distantPast
    }
}

struct CombineBalance: Identifiable {
    let id = UUID()
    let today: String
    let onlineBalance: Double
    let wallet: Double
    let totalBalance: Double
}

//struct CashTrack: Identifiable {
//    var id: Int64
//    var amount: Double
//    var description: String
//    var date: String
//    var creation_date: String
//}
extension CombineBalance {
    var asDictionary: [String: Any] {
        return [
            "Today": today,
            "Online_Balance": onlineBalance,
            "Wallet": wallet,
            "Total_Balance": totalBalance
        ]
    }
}

struct Inflow: Identifiable {
    var id: Int64
    var income_type: String
    var amount: Double
    var date: String
    var description: String
    var creation_date: String?
    var parsedDate: Date {
        DateHelper.parse(date) ?? Date.distantPast
    }
}
