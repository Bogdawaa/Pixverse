//
//  GenerationProgressViewModelProtocol.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 19.07.2025.
//

import Foundation

protocol GenerationProgressViewModelProtocol: ObservableObject {
    associatedtype GenerationParameters
    
    @MainActor var isLoading: Bool { get }
    @MainActor var error: Error? { get }
    @MainActor var generatedVideoUrl: String? { get }
    @MainActor var isGenerationComplete: Bool { get }
    @MainActor var downloadState: VideoGenerationViewModel.DownloadState { get set }
    @MainActor var showAlert: Bool { get set }
    @MainActor var errorMessage: String? { get set }
    
    func generate(with parameters: GenerationParameters) async
    func downloadVideo() async
}
