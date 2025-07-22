//
//  TextGenerationView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 16.07.2025.
//

import SwiftUI
import PhotosUI
import AVKit

struct TextGenerationView: View {
    
    @ObservedObject var viewModel: TextGenerationViewModel
    
    @State private var selectedItem: PhotosPickerItem?
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var videoCoordinator: VideoCoordinator
    @Environment(\.dismiss) var dismiss

    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CustomTextField(placeholder: "Enter your prompt", text: $viewModel.prompt)
                    .frame(minHeight: 130)
                    .background(.appCard2)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(spacing: 8) {
                    if !viewModel.isUploadVideoEnabled {
                        Toggle("Upload photo", isOn: $viewModel.isUploadPhotoEnabled)
                            .toggleStyle(.switch)
                            .tint(.appGreen)
                            .onChange(of: viewModel.isUploadPhotoEnabled) { enabled in
                                withAnimation(.easeInOut) {
                                    if enabled {
                                        viewModel.isUploadVideoEnabled = false
                                    }
                                }
                            }
                    }
//                    if !viewModel.isUploadPhotoEnabled {
//                        Toggle("Upload video", isOn: $viewModel.isUploadVideoEnabled)
//                            .toggleStyle(.switch)
//                            .tint(.appGreen)
//                            .onChange(of: viewModel.isUploadVideoEnabled) { enabled in
//                                withAnimation(.easeInOut) {
//                                    if enabled {
//                                        viewModel.isUploadPhotoEnabled = false
//                                    }
//                                }
//                            }
//                    }
                }
                
                // MARK: - Dashed view to upload photo/video
                if viewModel.shouldShowUploadButton {
                    DashedView() {
                        Button(action: {
                            viewModel.checkPhotoLibraryPermission()
                        }) {
                            VStack {
                                Image(.upload)
                                Text(viewModel.isUploadPhotoEnabled ? "Upload photo" : "Upload a video")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 168)
                            .foregroundColor(.appSecondaryText2)
                            .font(.headline)
                            .overlay {
                                if let media = viewModel.selectedMedia {
                                    VStack {
                                        switch media {
                                        case .photo(let image):
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                        case .video(_):
                                            if let thumbnail = viewModel.selectedImage {
                                                Image(uiImage: thumbnail)
                                                    .resizable()
                                                    .scaledToFill()
                                            } else {
                                                Image(.upload)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 168)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                    .contentShape(RoundedRectangle(cornerRadius: 24))
                                }
                            }
                        }
                    }
                    .animation(.easeInOut, value: viewModel.selectedMedia)
                }
                
                if viewModel.shouldShowStyleSlider {
                    templatesFooterView
                }
            }
            .padding()
            .foregroundStyle(.white)
            .background(.appCard)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            // Generate button
            Button {
                if let media = viewModel.selectedMedia {
                    let params: TextGenerationViewModel.GenerationParameters
                    
                    switch media {
                    case .photo(let image):
                        params = TextGenerationViewModel.GenerationParameters(
                            prompt: viewModel.prompt,
                            image: image,
                            videoURL: nil,
                            templateId: nil
                        )
                    case .video(let url):
                        params = TextGenerationViewModel.GenerationParameters(
                            prompt: nil,
                            image: nil,
                            videoURL: url,
                            templateId: (viewModel.selectedStyleItem as? StyleItem)?.id // TODO: id or template id????
                        )
                    }
                    
                    Task {
                        videoCoordinator.showGenerationProgress(with: media)
                        await viewModel.generate(with: params)
                    }
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Generate")
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.primaryButton)
            .disabled(viewModel.isGenerateButtonDisabled)
        }
        .alert("Allow access to photos?", isPresented: $viewModel.showPhotoAccessAlert) {
            Button("Allow", role: .none) {
                openAppSettings()
            }
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("To upload an image, the app needs access to your photo library")
        }
        .photosPicker(isPresented: $viewModel.showMediaPicker,
                      selection: $selectedItem,
                      matching: viewModel.isUploadPhotoEnabled ? .images : .videos)
        .onChange(of: selectedItem) { newItem in
            viewModel.handleMediaSelection(newItem)
        }
    }
        
    private var templatesFooterView: some View {
        VStack(alignment: .leading) {
            Text("Styles")
                .fontWeight(.bold)
                .font(.title2)
                .foregroundStyle(.white)
                .padding()
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(TemplateRepository.shared.styles, id:\.id) { item in
                        StyleItemView(viewModel: viewModel, item: item)
                    }
                }
            }
        }
        .background(.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
    
    private func generateContent() {
        // Handle generation logic
        print("Generating content with prompt: \(viewModel.prompt)")
    }
    
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    
}

#Preview {
    TextGenerationView(viewModel: TextGenerationViewModel())
}
