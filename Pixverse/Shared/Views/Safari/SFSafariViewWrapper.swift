//
//  SFSafariView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 10.07.2025.
//

import SwiftUI
import SafariServices

enum AppURL: String, Identifiable {
    case privacy = "https://exampleapi.com/privacy"
    case terms = "https://exampleapi.com/terms"
    case contact = "https://exampleapi.com/contact"
    
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
