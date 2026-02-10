//
//  InputView.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 15.01.2026.
//

import Foundation
import SwiftUI
import UIKit

struct InputView: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundColor(.gray).padding(.leading, 4)
            TextField("", text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
            Divider()
        }
    }
}
