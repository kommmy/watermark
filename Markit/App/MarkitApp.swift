import SwiftUI
import UIKit

@main
struct MarkitApp: App {
    var body: some Scene {
        WindowGroup {
            rootView
                .preferredColorScheme(.light)
        }
    }

    @ViewBuilder
    private var rootView: some View {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--screenshot-watermark-editor"),
           let image = UIImage(named: "sample_mountain") {
            NavigationStack {
                EditorView(image: image, initialMetadata: .preview, initialTemplate: .leica_white_space)
            }
        } else if ProcessInfo.processInfo.arguments.contains("--screenshot-puzzle-tab") {
            HomeView(initialTab: .puzzle)
        } else {
            HomeView()
        }
        #else
        HomeView()
        #endif
    }
}
