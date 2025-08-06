//
//  LibraryView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 21.07.2025.
//

import SwiftUI

struct LibraryView: View {
    
    @EnvironmentObject var router: Router
    
    @StateObject private var viewModel: LibraryViewModel = LibraryViewModel()
    
    private var gridLayout: [GridItem] {
        [
            GridItem(.fixed(175), spacing: 8),
            GridItem(.fixed(175), spacing: 8)
        ]
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack {
                if viewModel.generations.isEmpty {
                    emptyContentView
                } else {
                    generationsView
                }
                Spacer()
            }
            .padding()
        }
        .onAppear {
            viewModel.loadGenerations()
        }
    }
    
    private var emptyContentView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.appCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .frame(height: 225)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(.appCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .frame(height: 225)
            }
            
            Text("Start your first creation!")
                .font(.system(size: 28))
                .fontWeight(.bold)
                .tracking(0.4)
                .foregroundStyle(.appMainText)
            
            Text("Choose what would you'd like to create first - a photo or a video. Your library will soon be full of inspiration")
                .foregroundStyle(.appPrimaryText)
                .font(.system(size: 17))
                .tracking(-0.43)
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
            
            Button {
                router.navigateToVideoTab()
            } label: {
                Text("Generate")
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 50)
            }
            .buttonStyle(.primaryButton)
            .padding(.top, 24)
            
            Spacer()
        }
    }
    
    private var generationsView: some View {
        ZStack {
            Color.appBackground
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                if viewModel.generations.count == 1 {
                    HStack(alignment: .top) {
                        GenerationItemView(generation: viewModel.generations[0])
                            .onTapGesture {
                                viewModel.selectedGeneration = viewModel.generations[0]
                            }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 24)
                } else {
                    LazyVGrid(columns: gridLayout, spacing: 8) {
                        ForEach(viewModel.generations, id: \.id) { item in
                            GenerationItemView(generation: item)
                                .frame(height: 225)
                                .onTapGesture {
                                    viewModel.selectedGeneration = item
                                }
                                .onDisappear {
                                    viewModel.selectedGeneration = nil
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                }
            }
            .scrollIndicators(.hidden)
            .onAppear {
                viewModel.loadGenerations()
            }
        }
        .onChange(of: viewModel.selectedGeneration) { generation in
            if let generation = generation, generation.videoUrl != nil {
                let vm = GenerationResultViewModel(item: generation)
                router.path.append(vm)
            }
        }
        .onChange(of: router.selectedTab) { newTab in
            if newTab != 2 {
                viewModel.selectedGeneration = nil
            }
        }
    }
}

#Preview {
    LibraryView()
}
