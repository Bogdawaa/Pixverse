//
//  VideoTabView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 26.07.2025.
//

import SwiftUI

struct VideoTabView: View {
    @ObservedObject var videoVM: VideoViewModel
    @ObservedObject var videoGenerationVM: VideoGenerationViewModel
    @ObservedObject var textGenerationVM: TextGenerationViewModel
    
    @EnvironmentObject private var router: Router

    var body: some View {
            VideoView(
                viewModel: videoVM,
                videoGenerationVM: videoGenerationVM,
                textGenerationVM: textGenerationVM
            )
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
