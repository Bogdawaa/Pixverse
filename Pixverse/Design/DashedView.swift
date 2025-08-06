//
//  DashedView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 16.07.2025.
//

import SwiftUI

struct DashedView<Content: View>: View {
    var cornerRadius: CGFloat = 8
    var dashLength: CGFloat = 2
    var dashGap: CGFloat = 2
    var lineWidth: CGFloat = 1
    var color: Color = .appGreen
    let content: Content
    
    init(cornerRadius: CGFloat = 8,
         dashLength: CGFloat = 2,
         dashGap: CGFloat = 2,
         lineWidth: CGFloat = 1,
         color: Color = .appGreen,
         @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.dashLength = dashLength
        self.dashGap = dashGap
        self.lineWidth = lineWidth
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(style: StrokeStyle(
                        lineWidth: lineWidth,
                        dash: [dashLength, dashGap]
                    ))
                    .foregroundColor(color)
            )
    }
}
