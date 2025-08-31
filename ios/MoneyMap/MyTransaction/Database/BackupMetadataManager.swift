//
//  BackupMetadataManager.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 17/08/25.
//
import Foundation

/*
    Struct representing metadata about last backup timestamps
    for different database tables.
*/
struct BackupMetadata: Codable {
    var transactions: String?
    var wallet: String?
    var inflow: String?
}

/*
    Manager class responsible for handling backup metadata storage.

    - Implements singleton pattern via `shared` instance.
    - Loads metadata from a JSON file in Application Support directory.
    - Updates timestamps for tables and saves back to disk.
    - Ensures directories exist before file operations.
*/
class BackupMetadataManager {
    static let shared = BackupMetadataManager()
    
    /// Filename for metadata storage
    private let fileName = "backup_metadata.json"
    
    /// Full file URL for the metadata JSON file
    private let fileURL: URL
    
    /// Cached in-memory metadata object
    private var metadata: BackupMetadata
    
    /*
        Private initializer to enforce singleton usage.

        - Determines Application Support directory.
        - Ensures directory exists.
        - Loads existing metadata from disk or initializes new.
    */
    private init() {
        let appSupport = AppDirectories.getAppDirectory()
        
        BackupMetadataManager.ensureDirectoryExists(at: appSupport)
        
        self.fileURL = appSupport.appendingPathComponent(fileName)
        
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(BackupMetadata.self, from: data) {
            self.metadata = decoded
        } else {
            self.metadata = BackupMetadata()
        }
    }
    
    /*
        Returns the last modified timestamp for a given table.

        - Parameter table: Table name as String
        - Returns: Optional String representing timestamp, or nil if none exists.
    */
    func lastModified(for table: String) -> String? {
        switch table {
        case TableType.transactions.rawValue: return metadata.transactions
        case TableType.wallet.rawValue: return metadata.wallet
        case TableType.inflow.rawValue: return metadata.inflow
        default: return nil
        }
    }
    
    /*
        Updates the last modified timestamp for the specified table.

        - Parameters:
            - table: Table name to update.
            - timestamp: Date to record; defaults to current date/time.
    */
    func update(table: String, timestamp: Date = Date()) {
        let dateString = Self.dateFormatter.string(from: timestamp)
        switch table {
        case TableType.transactions.rawValue: metadata.transactions = dateString
        case TableType.wallet.rawValue: metadata.wallet = dateString
        case TableType.inflow.rawValue: metadata.inflow = dateString
        default: break
        }
        save()
    }
    
    /*
        Saves the metadata JSON to disk.

        - Ensures the directory exists before saving.
        - Handles and logs errors during saving.
    */
    private func save() {
        do {
            let dir = fileURL.deletingLastPathComponent()
            BackupMetadataManager.ensureDirectoryExists(at: dir)
            
            let data = try JSONEncoder().encode(metadata)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("⚠️ Failed to save backup metadata at \(fileURL.path): \(error.localizedDescription)")
        }
    }
    
    /*
        Helper method to ensure the specified directory exists.

        - Parameter url: Directory URL to check/create.
    */
    private static func ensureDirectoryExists(at url: URL) {
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
    
    /*
        Shared date formatter used for timestamps.

        - Format: "yyyy-MM-dd HH:mm:ss"
        - Locale: POSIX for consistent parsing
    */
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
