import SwiftUI

struct VideoView: View {
    @ObservedObject var viewModel: VideoViewModel
    @ObservedObject var videoGenerationVM: VideoGenerationViewModel
    @ObservedObject var textGenerationVM: TextGenerationViewModel
    
    @EnvironmentObject private var videoCoordinator: VideoCoordinator
    @EnvironmentObject private var appCoordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            Color.appBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Segmented Picker
                CapsuleSegmentedPicker(selection: $appCoordinator.selectedVideoTab) { tab in
                    tab.rawValue
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                
                // Main Content
                Group {
                    switch appCoordinator.selectedVideoTab {
                    case .textGeneration:
                        TextGenerationView(viewModel: textGenerationVM)
                            .padding()
                            .navigationDestination(for: UIImage.self) { image in
                                GenerationProgressView(viewModel: textGenerationVM, mediaType: .image(Image(uiImage: image)))
                            }
                            .navigationDestination(for: URL.self) { url in
                                GenerationProgressView(viewModel: textGenerationVM, mediaType: .video(url))
                            }
                    case .styles:
                        contentSectionsView
                    default:
                        contentSectionsView
                    }
                }
                Spacer()
            }
        }
        .background(.appBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AnyContentItem.self) { wrappedItem in
            TemplateView(item: wrappedItem.base, viewModel: videoGenerationVM)
                .environmentObject(videoCoordinator)
        }
    }
    
    private var contentSectionsView: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(viewModel.filteredSections(for: appCoordinator.selectedVideoTab)) { section in
                    let sectionVM = ContentSectionViewModel()
                    
                    MainContentSectionView(viewModel: sectionVM, section: section)
                    .padding(.horizontal, 16)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    VideoView(
        viewModel: VideoViewModel(
            templateService: TemplateService(
                networkClient: DefaultNetworkClientImpl(baseURL: "awdawd.com")
            )
        ),
        videoGenerationVM: VideoGenerationViewModel(),
        textGenerationVM: TextGenerationViewModel()
    )
        .environmentObject(AppCoordinator())
}
