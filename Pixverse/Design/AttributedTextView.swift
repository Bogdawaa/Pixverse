//
//  AttributedText.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 09.07.2025.
//

import SwiftUI

struct AttributedTextView: View {
    let text: String
    let boldParts: [String]
    let boldFont: Font
    let regularFont: Font
    let color: Color
    
    var body: some View {
        Text(buildAttributedString())
            .foregroundColor(color)
    }
    
    private func buildAttributedString() -> AttributedString {
        var result = AttributedString(text)
        result.font = regularFont
        
        for part in boldParts {
            if let range = result.range(of: part) {
                result[range].font = boldFont
            }
        }
        
        return result
    }
}
