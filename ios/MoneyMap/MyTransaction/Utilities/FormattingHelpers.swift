//
//  FormattingHelpers.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 14/08/25.
//

import SwiftUI
import Foundation

struct DateHelper {
    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d/M/yy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    static func parse(_ dateString: String) -> Date? {
        return shortDateFormatter.date(from: dateString)
    }

    static func todayString() -> String { format(Date()) }

    static func format(_ date: Date) -> String {
        return shortDateFormatter.string(from: date)
    }
}

enum MoneyFormatter {
    static let formatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = "INR"
        nf.maximumFractionDigits = 2
        return nf
    }()
    static func string(_ value: Double) -> String {
        MoneyFormatter.formatter.string(from: NSNumber(value: value)) ?? "₹\(value)"
    }
    static func string(from stringValue: String) -> String? {
        guard let doubleValue = Double(stringValue) else {
            return nil
        }
        return string(doubleValue)
    }
}

/// Returns a masked or formatted currency string based on the `showBalance` setting.
func maskedAmount<T>(_ amount: T, showBalance: Bool) -> String {
    guard showBalance else { return "••••••" }

    if let doubleAmount = amount as? Double {
        return MoneyFormatter.string(doubleAmount)
    } else if let stringAmount = amount as? String {
        return MoneyFormatter.string(from: stringAmount) ?? stringAmount
    } else {
        return "Invalid Amount"
    }
}
