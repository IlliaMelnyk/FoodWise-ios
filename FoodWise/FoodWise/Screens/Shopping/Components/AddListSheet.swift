//
//  AddListSheet.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 16.01.2026.
//


//
//  AddListSheet.swift
//  FoodWise
//
//  Created by Illia Melnyk on 22.12.2025.
//
import SwiftUI

struct AddListSheet: View {
    @ObservedObject var viewModel: ShoppingViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab = 0
    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var joinCode: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Action", selection: $selectedTab) {
                    Text("New list").tag(0)
                    Text("Connect").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedTab == 0 {
                    Form {
                        Section(header: Text("Information")) {
                            TextField("Name (e.d Greel)", text: $name)
                            DatePicker("Date", selection: $date, displayedComponents: .date)
                        }
                    }
                    
                    Button(action: {
                        viewModel.addShoppingList(name: name, date: date)
                        dismiss()
                    }) {
                        Text("Add list")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.5))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    .padding()
                    .disabled(name.isEmpty)
                    
                } else {
                    VStack(spacing: 20) {
                        Text("Do you have from family member?")
                            .foregroundColor(.gray)
                        
                        TextField("Type code (e.d AB12CD)", text: $joinCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.center)
                            .textCase(.uppercase)
                            .padding()
                        
                        Button(action: {
                            Task {
                                let success = await viewModel.joinShoppingList(code: joinCode)
                                if success { dismiss() }
                            }
                        }) {
                            Text("Connect")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                        .disabled(joinCode.count < 3)
                    }
                    Spacer()
                }
            }
            .navigationTitle(selectedTab == 0 ? "New list" : "Shared list")
            .navigationBarItems(leading: Button("Dismiss") { dismiss() })
        }
        .presentationDetents([.medium])
    }
}
