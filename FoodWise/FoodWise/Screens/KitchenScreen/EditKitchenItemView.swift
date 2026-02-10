//
//  EditKitchenItemView.swift
//  FoodWise
//
//  Created by Illia Melnyk on 12.01.2026.
//

import SwiftUI

struct EditKitchenItemView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: KitchenListViewModel
    
    @State var item: KitchenItem
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Information")) {
                    TextField("Name", text: $item.name)
                   
                    HStack {
    
                        TextField("Quantity", value: $item.quantity, format: .number)
                            .keyboardType(.decimalPad)

                        TextField("Unit", text: $item.unit)
                    }
                }
                
                Section(header: Text("Shelf Life")) {
                    DatePicker(
                        "Expiration Date", // Datum spotřeby
                        selection: $item.expiryDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }
                
                Section(header: Text("Category")) { // Kategorie
                    Picker("Category", selection: $item.category) {
                        Text("Dairy").tag("Dairy")
                        Text("Meat").tag("Meat")
                        Text("Produce").tag("Produce")
                        Text("Bakery").tag("Bakery")
                        Text("Pantry").tag("Pantry")
                        Text("Other").tag("Other")
                    }
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { 
                        viewModel.updateItem(item)
                        dismiss()
                    }
                }
            }
        }
    }
}
