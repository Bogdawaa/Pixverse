//
//  CapsuledSegmentedControl.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI

// MARK: - Picker Component
struct CapsuleSegmentedPicker<T: Hashable & CaseIterable>: View where T.AllCases: RandomAccessCollection {
    @Binding var selection: T
    let titleMapping: (T) -> String
    
    var body: some View {
        GeometryReader { geometry in
            let segmentCount = CGFloat(T.allCases.count)
            let spacing: CGFloat = 8
            let totalSpacing = spacing * (segmentCount - 1)
            let availableWidth = geometry.size.width
            let segmentWidth = max(0, (availableWidth - totalSpacing) / segmentCount)
            
            HStack(spacing: spacing) {
                ForEach(Array(T.allCases), id: \.self) { option in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selection = option
                        }
                    }) {
                        Text(titleMapping(option))
                            .font(.system(size: 13, weight: .regular))
                            .tracking(-0.08)
                            .foregroundColor(selection == option ? .white : .black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selection == option ? .appGreen : .appCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selection == option ? .clear : .white.opacity(0.05), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .frame(width: segmentWidth)
                }
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
        .frame(height: 40)
    }
}
