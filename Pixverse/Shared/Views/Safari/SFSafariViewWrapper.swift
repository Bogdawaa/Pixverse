//
//  SFSafariView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 10.07.2025.
//

import SwiftUI
import SafariServices

enum AppURL: String, Identifiable {
    case privacy = "https://docs.google.com/document/d/1JvO3C-4M-OrKST22rshQ4wmmgTODLjXcTqHdaKXlCkM/edit?tab=t.0"
    case terms = "https://docs.google.com/document/d/1Flw2PbLZzorHJyhW6Ljvcpsm6PCKKcQXpJo9P9Pb81I/edit?tab=t.0"
    
    var id: String { rawValue }
    
    var url: URL { URL(string: rawValue)! }
}

struct SFSafariViewWrapper: UIViewControllerRepresentable {
    
    let url: URL

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<Self>
    ) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<SFSafariViewWrapper>
    ) {}
}
