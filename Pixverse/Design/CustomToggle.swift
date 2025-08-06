//
//  СгыещьЕщппду.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 06.08.2025.
//

import SwiftUI

struct CustomToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle("", isOn: $isOn)
            .toggleStyle(CustomToggleStyle())
            .labelsHidden()
    }
}

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Capsule()
                .fill(configuration.isOn ? .appGreen : .appCard2)
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(configuration.isOn ? Color.white : .appGreen)
                        .frame(width: 26, height: 26)
                        .offset(x: configuration.isOn ? -2 : 2),
                    alignment: configuration.isOn ? .trailing : .leading
                )
                .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                .onTapGesture {
                    withAnimation {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}
