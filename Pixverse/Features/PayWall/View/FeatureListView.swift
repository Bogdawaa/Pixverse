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
            HStack {
                Text("Pixverse Video")
                    .font(.system(size: 28, weight: .bold))
                Text("PRO")
                    .foregroundStyle(.appGreen)
                    .font(.system(size: 28, weight: .bold))
            }
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
