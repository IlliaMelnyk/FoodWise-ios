import SwiftUI
import VisionKit

struct KitchenListView: View {
    @StateObject var viewModel = KitchenListViewModel()
    
    let googleService = GoogleAIStudioService()
    let recognizer = TextRecognizer()
    
    @State private var isAddSheetPresented = false
    @State private var isScannerPresented = false
    @State private var isProfilePresented = false
    @State private var isPhotoPickerPresented = false
    @State private var itemToEdit: KitchenItem?
    
    @State private var scannedRawText: String?
    @State private var scanError: String?
    @State private var selectedImage: UIImage?
    @State private var isProcessing = false
    
    @State private var selectedExpiredItem: KitchenItem?
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.state.isLoading {
                    ProgressView("Loading kitchen...")
                } else if viewModel.state.products.isEmpty {
                    ContentUnavailableView("Kitchen is empty", systemImage: "refrigerator")
                } else {
                    List {
                        ForEach(viewModel.state.products) { product in
                            KitchenListRow(item: product)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if product.isExpired {
                                        selectedExpiredItem = product
                                    } else {
                                        itemToEdit = product
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button("Used") {
                                        viewModel.markAsConsumed(item: product)
                                    }
                                    .tint(.green)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button("Waste") {
                                        viewModel.markAsWasted(item: product)
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Kitchen")
            .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    isProfilePresented = true
                                } label: {
                                    Image(systemName: "person.crop.circle")
                                        .font(.system(size: 28))
                                        .foregroundColor(.orange)
                                    
                                }.accessibilityIdentifier("Profile")
                            }
                            
                            ToolbarItem(placement: .primaryAction) {
                                Menu {
                                    Button {
                                        if VNDocumentCameraViewController.isSupported {
                                            isScannerPresented = true
                                        } else {
                                            isPhotoPickerPresented = true
                                        }
                                    } label: {
                                        Label("Scan receipt", systemImage: "camera.viewfinder")
                                    }
                                    
                                    Button {
                                        isAddSheetPresented = true
                                    } label: {
                                        Label("Add manually", systemImage: "square.and.pencil")
                                    }
                                    .accessibilityIdentifier("add_manually_option")
                                    
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundStyle(.orange)
                                }
                                .accessibilityIdentifier("main_add_button")
                            }
                        }
            .sheet(isPresented: $isAddSheetPresented) {
                AddManuallyView(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }
            .sheet(item: $itemToEdit) { item in
                            EditKitchenItemView(viewModel: viewModel, item: item)
            }
            .sheet(isPresented: $isProfilePresented) {
                ProfileView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $isScannerPresented) {
                DocumentScannerView(scannedText: $scannedRawText, error: $scanError)
            }
            .sheet(isPresented: $isPhotoPickerPresented) {
                PhotoPickerView(selectedImage: $selectedImage)
            }
            .sheet(item: $selectedExpiredItem) { item in
                ExpiredActionSheet(
                    item: item,
                    onConsumed: {
                        viewModel.markAsConsumed(item: item)
                        selectedExpiredItem = nil
                    },
                    onWasted: {
                        viewModel.markAsWasted(item: item)
                        selectedExpiredItem = nil
                    }
                )
            }
            
            .onChange(of: selectedImage) { oldValue, newImage in
                if let image = newImage {
                    processImage(image)
                }
            }
            
            .onChange(of: scannedRawText) { oldValue, newText in
                if let text = newText {
                    print("OCR Success! Sending to Gemini...")
                    processReceiptWithGemini(text)
                }
            }
            
            // 4. Loading Overlay
            .overlay {
                if isProcessing {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        VStack(spacing: 15) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Analyzing Receipt...")
                                .font(.headline)
                        }
                        .padding(30)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                    }
                }
            }
        }
    }
    func processImage(_ image: UIImage) {
        isProcessing = true
        Task {
            do {
                let text = try await recognizer.recognizeText(from: image)
                await MainActor.run {
                    self.scannedRawText = text
                }
            } catch {
                print("OCR Error: \(error)")
                await MainActor.run {
                    self.isProcessing = false
                }
            }
        }
    }
    
    // AI Logic
    func processReceiptWithGemini(_ text: String) {
        isProcessing = true
        
        Task {
            do {
                let cleanIngredients = try await googleService.parseReceipt(text: text)
                
                await MainActor.run {
                    viewModel.addItemsFromOCR(cleanIngredients)
                    
                    // Cleanup
                    isProcessing = false
                    scannedRawText = nil
                    selectedImage = nil
                    print("Successfully added: \(cleanIngredients)")
                }
            } catch {
                print("Gemini Error: \(error)")
                await MainActor.run {
                    isProcessing = false
                }
            }
        }
    }
}
