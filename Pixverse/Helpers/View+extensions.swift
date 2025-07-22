//
//  View+extensions.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import SwiftUI

// MARK: - SafariView Extension
extension View {
    func safariSheet(url: Binding<AppURL?>) -> some View {
        self.sheet(item: url) { urlCase in
            if UIApplication.shared.canOpenURL(urlCase.url) {
                SFSafariViewWrapper(url: urlCase.url)
                    .ignoresSafeArea()
            } else {
                Text("Invalid URL")
                    .foregroundColor(.blue)
            }
        }
    }
}
