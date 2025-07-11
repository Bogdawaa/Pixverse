//
//  FeatureView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 10.07.2025.
//

import SwiftUI

struct FeatureListView: View {
    
    let features: [PaywallViewModel.Feature]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(features, id: \.title) { feature in
                Label {
                    Text(feature.title)
                } icon: {
                    Image(systemName: feature.icon)
                        .foregroundStyle(.appGreen)
                }
            }
        }
    }
}

#Preview {
    FeatureListView(features: [])
}
