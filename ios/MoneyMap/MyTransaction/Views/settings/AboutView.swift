//
//  AboutView.swift
//  MoneyMap
//
//  Created by Dharm Vashisth on 20/08/25.
//
import SwiftUI

struct AboutView: View {
    
    var body: some View {
        VStack{
            HStack {
                Text("App Version")
                Spacer()
                Text(Bundle.main.appVersion)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Developer")
                Spacer()
                Text("Dharm Vashisth")
                    .foregroundColor(.secondary)
            }
            
        }
    }
}

extension Bundle {
var appVersion: String {
    (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
}
}
