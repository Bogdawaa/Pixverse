//
//  CloseButton.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 10.07.2025.
//

import SwiftUI

struct CloseButton: View {
    
    @Binding var isVisible: Bool
    
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            Image(systemName: "xmark")
                .foregroundStyle(.white.opacity(0.6))
        })
        .accessibilityLabel("Close")
        .padding()
        .opacity(isVisible ? 1 : 0)
        .animation(.easeIn(duration: 0.3), value: isVisible)
    }
}
