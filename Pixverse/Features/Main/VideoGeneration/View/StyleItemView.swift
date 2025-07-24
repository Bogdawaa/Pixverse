//
//  SliderView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 17.07.2025.
//


import SwiftUI

struct StyleItemView: View {
    @ObservedObject var viewModel: TextGenerationViewModel
    let item: any ContentItemProtocol
    
    @State private var thumbnailImage: UIImage?
    
    var isSelected: Bool {
        viewModel.selectedStyleItem?.id == item.id
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let thumbnailImage = thumbnailImage {
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .scaledToFill()
                    .overlay(alignment: .bottom) {
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    .black.opacity(0),
                                    .appBackground
                                ]
                            ),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .background(.appCard)
                    .overlay {
                        ProgressView()
                    }
            }
            
            Text(item.name)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .font(.system(size: 14))
                .padding(.horizontal)
                .padding()
        }
        .frame(width: 125, height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.appGreen : Color.clear, lineWidth: 1)
        )
        .onTapGesture {
            viewModel.selectedStyleItem = item
        }
        .task {
            await loadThumbnail()
        }
    }
    
    private func loadThumbnail() async {
        guard let previewUrl = item.previewSmallURL else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: previewUrl)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    thumbnailImage = image
                }
            }
        } catch {
            print("Error loading thumbnail: \(error.localizedDescription)")
        }
    }
}
