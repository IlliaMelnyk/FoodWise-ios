//
//  PasswordInputView.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 15.01.2026.
//

import Foundation
import SwiftUI

struct PasswordInputView: View {
    let title: String
    @Binding var text: String
    @Binding var isVisible: Bool
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundColor(.gray).padding(.leading, 4)
            HStack {
                if isVisible {
                    TextField("", text: $text).autocapitalization(.none)
                } else {
                    SecureField("", text: $text)
                }
                
                Button(action: { isVisible.toggle() }) {
                    Image(systemName: isVisible ? "eye" : "eye.slash")
                        .foregroundColor(iconColor)
                }
            }
            Divider()
        }
    }
}
