//
//  CustomTextField.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 16.07.2025.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var height: CGFloat = 130
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .foregroundColor(.appMainText)
                .scrollContentBackground(.hidden)
                .background(Color.appCard2)
                .frame(height: height)
                .cornerRadius(10)
                .padding(.top, 16)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            
            // Placeholder
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.appSecondaryText2)
                    .padding(.top, 24)
                    .padding(.leading, 20)
                    .allowsHitTesting(false)
            }
        }
        .background(Color.appCard2)
        .cornerRadius(10)
    }
}

#Preview {
    CustomTextField(placeholder: "Enter your prompt", text: .constant("1"))
}
