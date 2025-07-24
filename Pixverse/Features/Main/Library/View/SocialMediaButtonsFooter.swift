//
//  SocialMediaButtons.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import SwiftUI

struct SocialMediaButtonsFooter: View {
    
    var shareItem: URL?
    
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
            
            if let shareItem = shareItem {
                ShareLink(item: shareItem) {
                    SocialMediaButton(
                        icon: Image(systemName: "ellipsis"),
                        label: "Still"
                    )
                    .disabled(true) // disabled for sharelink interaction collision
                }
            }
        }
        .padding()
    }
}
