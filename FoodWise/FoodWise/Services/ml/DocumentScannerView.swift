//
//  DocumentScannerView.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 23.12.2025.
//

import Foundation
import SwiftUI
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    
    @Binding var scannedText: String?
    @Binding var error: String?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScannerView
        let recognizer = TextRecognizer()
        
        init(parent: DocumentScannerView) {
            self.parent = parent
        }
        
       
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount >= 1 else {
                controller.dismiss(animated: true)
                return
            }
            
            let image = scan.imageOfPage(at: 0)
            
            Task {
                do {
                    let text = try await recognizer.recognizeText(from: image)
                    DispatchQueue.main.async {
                        self.parent.scannedText = text
                        controller.dismiss(animated: true)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.parent.error = error.localizedDescription
                        controller.dismiss(animated: true)
                    }
                }
            }
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.error = error.localizedDescription
            controller.dismiss(animated: true)
        }
    }
}
