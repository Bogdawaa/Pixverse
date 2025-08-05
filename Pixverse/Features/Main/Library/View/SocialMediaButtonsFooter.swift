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
            if let shareItem = shareItem {
                ShareLink(item: shareItem) {
                    SocialMediaButton(
                        icon: Image(.instagram),
                        label: "Instagram"
                    )
                    .disabled(true) // disabled for sharelink interaction collision
                }
                
                ShareLink(item: shareItem) {
                    SocialMediaButton(
                        icon: Image(.facebook),
                        label: "Facebook"
                    )
                    .disabled(true) // disabled for sharelink interaction collision
                }
                
                ShareLink(item: shareItem) {
                    SocialMediaButton(
                        icon: Image(.tikTok),
                        label: "TikTok"
                    )
                    .disabled(true) // disabled for sharelink interaction collision
                }
                
                ShareLink(item: shareItem) {
                    SocialMediaButton(
                        icon: Image(.whatsapp),
                        label: "WhatsApp"
                    )
                    .disabled(true) // disabled for sharelink interaction collision
                }
                
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
