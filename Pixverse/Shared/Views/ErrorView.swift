//
//  ErrorView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 14.07.2025.
//

import SwiftUI

struct ErrorView: View {
    let error: Error
    var dismissAction: (() -> Void)?
    var retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            
            // Header content
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                
                Text("Error Occurred")
                    .font(.title3.bold())
                
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Actions
                HStack(spacing: 16) {
                    if let retryAction = retryAction {
                        Button(action: retryAction) {
                            Text("Retry")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Button(action: { dismissAction?() }) {
                        Text("Dismiss")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4))
    }
}
