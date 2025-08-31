//
//  BackupView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 20/08/25.
//
import SwiftUI

struct BackupView: View {
    @Binding var backupMessage: String?
    @Binding var showToast: Bool
    
    
    var body: some View {
        
        
        Button(action: {
            do {
                try FileExporter.openBackupFolder()
            } catch {
                print("Failed to open backup folder:", error)
            }
        }) {
            Label("Open Backup Folder", systemImage: "folder")
                .foregroundColor(.blue)
        }
        
        Button(action: {
            let myResult = DBManager.shared.backupDatabase()
            if myResult.contains("Error") {
                backupMessage = "⚠️ Backup Failed. \(myResult)"
            }
            else{
                backupMessage = "✅ Backup created successfully and stored safely for future"
            }
            
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showToast = false
            }
        }) {
            Label("Export Backup", systemImage: "square.and.arrow.up")
                .foregroundColor(.blue)
        }

    }
}

struct ToastView: View {
    let message: String

    var body: some View {
        VStack {
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.black.opacity(0.85))
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: message)
    }
}
