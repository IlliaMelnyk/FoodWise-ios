import SwiftUI

struct ShoppingView: View {
    @StateObject private var viewModel = ShoppingViewModel()
    @State private var showingAddListSheet = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 15) {
                        
                        if viewModel.state.isLoading {
                            ProgressView().padding()
                        } else if viewModel.state.shoppingLists.isEmpty {
                            Text("You have not had any lists yet.")
                                .foregroundColor(.gray)
                                .padding(.top, 50)
                        }
                        
                        ForEach(viewModel.state.shoppingLists) { list in
                            NavigationLink(destination: ShoppingDetailView(viewModel: viewModel, list: list)) {
                                ShoppingListCard(list: list)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deleteList(list: list)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                Button(action: { showingAddListSheet = true }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                        .frame(width: 56, height: 56)
                        .background(Color.orange.opacity(0.4))
                        .cornerRadius(16)
                        .shadow(radius: 4)
                }
                .padding()
                .accessibilityIdentifier("add_shopping_list_button")
            }
            .navigationTitle("Shopping List")
            .sheet(isPresented: $showingAddListSheet, onDismiss: {
                viewModel.fetchShoppingLists()
            }) {
                AddListSheet(viewModel: viewModel)
            }
            .onAppear {
                viewModel.fetchShoppingLists()
            }
            .onDisappear {
                viewModel.stopListening()
            }
        }
    }
}
