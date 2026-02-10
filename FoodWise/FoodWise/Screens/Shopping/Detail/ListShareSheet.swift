
//  ListShareSheet.swift
//  FoodWise
//
//  Created by Illia Melnyk on 22.12.2025.
//
import SwiftUI

struct ListShareSheet: View {
    let list: ShoppingList
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Invide others")
                    .font(.headline)
                
                if let code = list.inviteCode {
                    VStack {
                        Text(code)
                            .font(.system(size: 50, weight: .bold, design: .monospaced))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .contextMenu {
                                Button("Copy") { UIPasteboard.general.string = code }
                            }
                        
                        Text("Tap and copy")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    ShareLink(item: code, message: Text("Hello, connect to our shopping list '\(list.name)' in FoodWise. Code: \(code)")) {
                        Label("Send code", systemImage: "paperplane.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                } else {
                    Text("This list does not have code for sharing.")
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Share: \(list.name)")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
        .presentationDetents([.medium])
    }
}
