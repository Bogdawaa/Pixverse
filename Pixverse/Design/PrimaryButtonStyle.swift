//
//  PrimaryButtonStyle.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 08.07.2025.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
            .foregroundStyle(isEnabled ? .appBackground : .appSecondary)
            .background(isEnabled ? .appGreen: .appCard2)
            .clipShape(Capsule(style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.smooth, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primaryButton: PrimaryButtonStyle { .init() }
}
