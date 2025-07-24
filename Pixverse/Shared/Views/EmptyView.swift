//
//  EmptyView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 14.07.2025.
//

import SwiftUI

struct EmptyView: View {
    var retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No content available")
                .font(.headline)
                .foregroundColor(.white)
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    Text("Try Again")
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    EmptyView(retryAction: { })
}
