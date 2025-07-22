//
//  PhotoPickerView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 15.07.2025.
//

import SwiftUI
import PhotosUI 

struct PhotoPickerView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @Binding var isPresented: Bool
        
    var onImageSelected: (UIImage) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            
            ZStack {
                Color.appCard
                    .cornerRadius(15)
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Select a photo", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        onImageSelected(image)
                        isPresented = false
                    }
                }
            }
            
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
            }
            
            Button("Cancel") {
                isPresented = false
            }
            .foregroundColor(.blue)
        }
        .background(Color.appCard)
        .padding()
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
    }
}

