import SwiftUI

struct AddManuallyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: KitchenListViewModel
    
    @State private var name: String = ""
    @State private var quantityAmount: String = ""
    @State private var piecesAmount: String = "1"
    @State private var selectedUnit: String = "pcs"
    @State private var expiryDate: Date = Date()
    @State private var selectedCategory: String = "Other"
    
    let units = ["pcs", "g", "kg", "ml", "L"]
    let categories = ["Dairy", "Meat", "Fruit & Veg", "Bakery", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Product Info")) {
                    TextField("Position name", text: $name)
                        .font(.headline)
                        .accessibilityIdentifier("item_name_input")
                    
                    Stepper(value: Binding(
                        get: { Int(piecesAmount) ?? 1 },
                        set: { piecesAmount = String($0) }
                    ), in: 1...99) {
                        Text("Pieces: \(piecesAmount)")
                    }
                    
                    HStack {
                        TextField("Amount (e.g. 500)", text: $quantityAmount)
                            .keyboardType(.decimalPad)
                            .accessibilityIdentifier("item_quantity_input")
                        
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                }
                
                Section(header: Text("Details")) {
                    DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section {
                    Button(action: saveItem) {
                        if viewModel.state.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Add to kitchen")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                        }
                    }
                    .listRowBackground(Color.orange)
                    .disabled(name.isEmpty)
                    .opacity(name.isEmpty ? 0.6 : 1.0)
                    .accessibilityIdentifier("confirm_add_button")
                }
            }
            .navigationTitle("Add manually")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onChange(of: viewModel.state.errorMessage) { oldValue, newValue in
                if let error = newValue {
                    print("Eror when adding: \(error)")
                }
            }
        }
    }
    
    func saveItem() {
        let quantity = Int(quantityAmount) ?? 0
        let pieces = Int(piecesAmount) ?? 1
        
        viewModel.addItem(
            name: name,
            quantity: quantity,
            unit: selectedUnit,
            pieces: pieces,
            expiryDate: expiryDate,
            category: selectedCategory
        )
        presentationMode.wrappedValue.dismiss()
    }
}
