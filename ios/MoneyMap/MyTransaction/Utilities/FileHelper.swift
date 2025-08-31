//
//  FileHelper.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 20/08/25.
//

import Foundation

enum AppDirectories {

    static let appFolderName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
    Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "MoneyMap"

    static func getAppDirectory() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let appDir = docs.appendingPathComponent(appFolderName)

        if !FileManager.default.fileExists(atPath: appDir.path) {
            try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        }
        return appDir
    }

    static func subdirectory(_ name: String) -> URL {
        let dir = getAppDirectory().appendingPathComponent(name)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

}
