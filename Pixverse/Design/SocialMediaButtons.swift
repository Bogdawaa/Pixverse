//
//  SocialMediaButtons.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 17.07.2025.
//

import SwiftUI

struct SocialMediaButton: View {
    let icon: Image
    let label: String
    
    var body: some View {
        Button(action: {
            //
        }) {
            VStack(spacing: 4) {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                Text(label)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.appSecondaryText2)
            }
            .foregroundColor(.white)
            .frame(width: 60)
        }
    }
}
