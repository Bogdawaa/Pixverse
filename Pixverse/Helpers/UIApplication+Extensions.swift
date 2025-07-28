//
//  UIApplication+Extensions.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 27.07.2025.
//

import SwiftUI

extension UIApplication {
    static var safeAreaInsets: UIEdgeInsets {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.safeAreaInsets ?? .zero
    }
}
