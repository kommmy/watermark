import SwiftUI

/// App root view: a single creation hub for photo cards and collages.
struct HomeView: View {
    enum Tab: Hashable { case discover, watermark, puzzle, me }

    private let initialTab: Tab

    init(initialTab: Tab = .watermark) {
        self.initialTab = initialTab
    }

    var body: some View {
        WatermarkTab(initialFocus: initialTab == .puzzle ? .puzzle : .watermark)
        .tint(.black)
        .preferredColorScheme(.light)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
