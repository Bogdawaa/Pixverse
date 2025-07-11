//
//  ContentSectionsView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI

struct ContentSectionsView: View {
    
    @ObservedObject var viewModel: ContentSectionViewModel
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 24) {
                ForEach(viewModel.sections) { section in
                    ContentSectionView(viewModel: viewModel, section: section)
                }
            }
            .padding(.vertical, 16)
        }
    }
}
