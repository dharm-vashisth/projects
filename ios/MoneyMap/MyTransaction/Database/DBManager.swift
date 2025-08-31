//
//  DBManager.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 05/08/25.
//

import SQLite
import Foundation

/*
    DBManager
    Singleton class managing the SQLite database connection,
    schema creation, and database backup operations.
*/
class DBManager {
    static let shared = DBManager()
    
    private(set) var db: Connection!
    
    // Database name
    private let db_name = "insighthub.sqlite3"
    
    // Backup file names
    private let currentBackupFileName = "current_backup.sql"
    private let previousBackupFileName = "previous_backup.sql"
    
    // Tables and Views
    let transactions = Table("transactions")
    let wallet = Table("wallet")
    let inflow = Table("inflow")
    let cashTrack = Table("cash_track")
    let combineBalance = View("combine_balance")
    
    // Table and view names as strings
    private let transactionsTable = "transactions"
    private let walletTable = "wallet"
    private let inflowTable = "inflow"
    private let cashTrackTable = "cash_track"
    private let currentBalanceView = "current_balance"
    private let combineBalanceView = "combine_balance"
    
    // Columns (Expressions)
    let id = SQLite.Expression<Int64>("id")
    let date = SQLite.Expression<String>("date")
    let amount = SQLite.Expression<Double>("amount")
    let category = SQLite.Expression<String>("category")
    let description = SQLite.Expression<String>("description")
    let mode = SQLite.Expression<String?>("mode")
    let incomeType = SQLite.Expression<String>("income_type")
    let creationDate = SQLite.Expression<String>("creation_date")
    
    /*
        Private initializer to enforce singleton.
        Establishes DB connection and ensures tables/views exist.
    */
    private init() {
        connect()
        createTablesIfNeeded()
        createViewsIfNeeded()
    }
    
    /*
        Establishes SQLite connection to the database file in the documents directory.
        Creates the directory if it doesn't exist.
    */
    private func connect() {
        do {
            guard let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("❌ Could not find Documents directory")
                return
            }
            
            try FileManager.default.createDirectory(at: docsURL, withIntermediateDirectories: true)
            
            let dbPath = docsURL.appendingPathComponent(db_name).path
            db = try Connection(dbPath)
            
        } catch {
            print("❌ Database connection error: \(error)")
        }
    }
    
    /*
        Creates all necessary tables if they don't exist,
        inserts default data as needed.
    */
    private func createTablesIfNeeded() {
        createTableIfNeeded(name: transactionsTable,
                            createSQL: SqlStatements.create_transaction,
                            insertSQL: SqlStatements.insert_transaction_records)
        
        createTableIfNeeded(name: walletTable,
                            createSQL: SqlStatements.create_wallet_transaction,
                            insertSQL: SqlStatements.insert_wallet_transaction_records)
        
        createTableIfNeeded(name: inflowTable,
                            createSQL: SqlStatements.create_inflow_transaction,
                            insertSQL: SqlStatements.insert_inflow_transaction_records)
    }
    
    /*
        Creates a single table if it doesn't exist.
    */
    private func createTableIfNeeded(name: String, createSQL: String, insertSQL: String) {
        do {
            let exists = try db.scalar(SqlStatements.isTableExistsSQL(tableName: name)) as! Int64
            if exists == 0 {
                try db.execute(createSQL)
                try db.execute(insertSQL)
            }
        } catch {
            print("❌ Error creating table '\(name)': \(error)")
        }
    }
    
    /*
        Creates views if they don't exist.
    */
    private func createViewsIfNeeded() {
        createViewIfNeeded(name: currentBalanceView, createSQL: SqlStatements.create_current_balance_view)
        createViewIfNeeded(name: combineBalanceView, createSQL: SqlStatements.create_combine_balance_view)
    }
    
    /*
        Creates a single view if it doesn't exist.
    */
    private func createViewIfNeeded(name: String, createSQL: String) {
        do {
            let exists = try db.scalar(SqlStatements.isViewExistsSQL(viewName: name)) as! Int64
            if exists == 0 {
                try db.execute(createSQL)
            }
        } catch {
            print("❌ Error creating view '\(name)': \(error)")
        }
    }
}

// MARK: - Backup extension

extension DBManager {
    
    /*
        Creates a full textual backup of all tables,
        saving snapshots into files in Application Support.
    */
    func backupDatabase()->String {
        let metadata = BackupMetadataManager.shared
        let timestamp = BackupMetadataManager.dateFormatter.string(from: Date())
        var snapshot = "-- Snapshot: \(timestamp)\n"
        
        snapshot += dumpTable(
            name: transactionsTable,
            createSQL: SqlStatements.create_transaction,
            expressions: [id, date, description, amount, category, mode],
            metadata: metadata
        )
        
        snapshot += dumpTable(
            name: walletTable,
            createSQL: SqlStatements.create_wallet_transaction,
            expressions: [id, amount, description, date, creationDate],
            metadata: metadata
        )
        
        snapshot += dumpTable(
            name: inflowTable,
            createSQL: SqlStatements.create_inflow_transaction,
            expressions: [id, incomeType, amount, date, description, creationDate],
            metadata: metadata
        )
        
        snapshot += "\n\n"
        
        do {
            let appSupport = AppDirectories.getAppDirectory()

            let currentBackupURL = appSupport.appendingPathComponent(currentBackupFileName)
            let previousBackupURL = appSupport.appendingPathComponent(previousBackupFileName)
            
            // Write current snapshot
            try snapshot.write(to: currentBackupURL, atomically: true, encoding: .utf8)
            
            // Prepend to previous backup file
            var previousContent = ""
            if FileManager.default.fileExists(atPath: previousBackupURL.path) {
                previousContent = try String(contentsOf: previousBackupURL, encoding: .utf8)
            }
            
            let mergedContent = snapshot + previousContent
            try mergedContent.write(to: previousBackupURL, atomically: true, encoding: .utf8)
            return currentBackupURL.absoluteString
        } catch {
            print("⚠️ Error: Backup failed: \(error)")
            return "⚠️ Error: Backup failed: \(error)"
        }
    }
    
    /*
        Helper method to dump the contents of a table as SQL INSERT statements.

        - Parameters:
          - name: Table name
          - createSQL: SQL statement to create the table (used for reference)
          - expressions: Array of column expressions to dump
          - metadata: BackupMetadataManager instance to update timestamps

        - Returns: String with SQL dump for the table
    */
    private func dumpTable(
        name: String,
        createSQL: String,
        expressions: [Expressible],
        metadata: BackupMetadataManager
    ) -> String {
        var dump = "-- \(name)\n"
        
        do {
            let table = Table(name)
            var rowsSQL: [String] = []
            
            for row in try db.prepare(table) {
                var values: [String] = []
                
                for expr in expressions {
                    switch expr {
                    case let intExpr as SQLite.Expression<Int64>:
                        values.append("\(row[intExpr])")
                    case let doubleExpr as SQLite.Expression<Double>:
                        values.append("\(row[doubleExpr])")
                    case let stringExpr as SQLite.Expression<String>:
                        let safeValue = row[stringExpr].replacingOccurrences(of: "'", with: "''")
                        values.append("'\(safeValue)'")
                    case let optStringExpr as SQLite.Expression<String?>:
                        if let value = row[optStringExpr] {
                            let safeValue = value.replacingOccurrences(of: "'", with: "''")
                            values.append("'\(safeValue)'")
                        } else {
                            values.append("NULL")
                        }
                    default:
                        values.append("NULL")
                    }
                }
                
                rowsSQL.append("(\(values.joined(separator: ", ")))")
            }
            
            if rowsSQL.isEmpty {
                if let lastDate = metadata.lastModified(for: name) {
                    dump += "-- no changes since last backup (last modified: \(lastDate))\n"
                } else {
                    dump += "-- no data available yet\n"
                }
            } else {
                metadata.update(table: name, timestamp: Date())
                
                let columnNames = expressions.map { "\($0)" }.joined(separator: ", ")
                let insertHeader = "INSERT INTO \(name) (\(columnNames)) VALUES\n"
                dump += insertHeader + rowsSQL.joined(separator: ",\n") + ";\n"
            }
            
        } catch {
            dump += "-- ⚠️ Failed to dump \(name): \(error)\n"
        }
        
        return dump + "\n"
    }
}
