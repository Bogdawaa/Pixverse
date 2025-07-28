import SwiftUI

struct VideoView: View {
    @ObservedObject var viewModel: VideoViewModel
    @ObservedObject var videoGenerationVM: VideoGenerationViewModel
    @ObservedObject var textGenerationVM: TextGenerationViewModel
    
    @EnvironmentObject private var router: Router
    
    var body: some View {
        ZStack {
            Color.appBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Segmented Picker
                CapsuleSegmentedPicker(selection: $router.selectedVideoTab) { tab in
                    tab.rawValue
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                
                // Main Content
                Group {
                    switch router.selectedVideoTab {
                    case .textGeneration:
                        TextGenerationView(viewModel: textGenerationVM)
                            .padding()
                            .onAppear {
                                router.selectedVideoTab = .textGeneration
                            }
                    case .styles:
                        contentSectionsView
                            .onAppear {
                                router.selectedVideoTab = .styles
                            }
                    default:
                        contentSectionsView
                            .onAppear {
                                router.selectedVideoTab = .templates
                            }
                    }
                }
                
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Video generation")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.appSecondaryText2)
    }
    
    private var contentSectionsView: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(viewModel.filteredSections(for: router.selectedVideoTab)) { section in
                    let sectionVM = ContentSectionViewModel()
                    
                    MainContentSectionView(viewModel: sectionVM, section: section, showAll: true)
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
}
