//
//  UploadView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 17.07.2025.
//

import SwiftUI

//struct UploadView: View {
//    @State private var showPhotoPicker = false
//    @State private var selectedImage: UIImage?
//    
//    var body: some View {
//        DashedView {
//            Button(action: {
//                checkPhotoLibraryPermission()
//            }) {
//                ZStack {
//                    // Show selected image if exists
//                    if let selectedImage {
//                        Image(uiImage: selectedImage)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 168)
//                            .clipped()
//                    }
//                    
//                    // Upload UI (hidden when image is selected)
//                    VStack {
//                        Image(.upload)
//                        Text("Upload Photo")
//                    }
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 168)
//                    .foregroundColor(.appSecondaryText2)
//                    .font(.headline)
//                    .opacity(selectedImage == nil ? 1 : 0) // Hide when image selected
//                }
//            }
//        }
//        .sheet(isPresented: $showPhotoPicker) {
//            ImagePicker(selectedImage: $selectedImage)
//        }
//    }
