//
//  SocialMediaButtons.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import SwiftUI

struct SocialMediaButtonsFooter: View {
    var body: some View {
        HStack(spacing: 12) {
            SocialMediaButton(
                icon: Image(.instagram),
                label: "Instagram"
            )
            
            SocialMediaButton(
                icon: Image(.facebook),
                label: "Facebook"
            )
            
            SocialMediaButton(
                icon: Image(.tikTok),
                label: "TikTok"
            )
            
            SocialMediaButton(
                icon: Image(.whatsapp),
                label: "WhatsApp"
            )
            
            SocialMediaButton(
                icon: Image(systemName: "ellipsis"),
                label: "Still"
            )
        }
        .padding()
    }
}
