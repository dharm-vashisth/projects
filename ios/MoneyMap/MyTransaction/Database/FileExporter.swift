//
//  FileExporter.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 24/08/25.
//

import UIKit
import UniformTypeIdentifiers

struct FileExporter {
    enum FileExporterError: Error {
        case documentsDirectoryNotFound
        case unableToPresentPicker
    }

    static func openBackupFolder() throws {
        let fileManager = FileManager.default
        
        guard let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileExporterError.documentsDirectoryNotFound
        }
        
        let backupFolder = docs.appendingPathComponent("Backup", isDirectory: true)
        
        if !fileManager.fileExists(atPath: backupFolder.path) {
            do {
                try fileManager.createDirectory(at: backupFolder, withIntermediateDirectories: true)
            } catch {
                throw error // propagate error
            }
        }
        
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        picker.directoryURL = backupFolder
        picker.allowsMultipleSelection = false
        
        // Find root view controller safely
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else {
            throw FileExporterError.unableToPresentPicker
        }
        
        DispatchQueue.main.async {
            root.present(picker, animated: true, completion: nil)
        }
    }
}
