import SwiftUI

/// App root: a bottom tab bar with the creation hub (water­mark + camera collage)
/// and the new 拼图 (collage frames) gallery.
struct HomeView: View {
    enum Tab: Hashable { case discover, watermark, puzzle, me }

    enum Selection: Hashable { case create, collage }

    private let initialTab: Tab
    @State private var selection: Selection

    init(initialTab: Tab = .watermark, initialSelection: Selection = .create) {
        self.initialTab = initialTab
        _selection = State(initialValue: initialSelection)
    }

    /// Switch tabs without any transition animation. Recent iOS adds an
    /// exaggerated content transition on tab change; mutating `selection` inside
    /// an animation-disabled transaction suppresses it without touching the
    /// animations inside each tab.
    private var selectionBinding: Binding<Selection> {
        Binding(
            get: { selection },
            set: { newValue in
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) { selection = newValue }
            }
        )
    }

    var body: some View {
        TabView(selection: selectionBinding) {
            WatermarkTab(initialFocus: initialTab == .puzzle ? .puzzle : .watermark)
                .tabItem { Label("创作", systemImage: "wand.and.stars") }
                .tag(Selection.create)

            CollageGalleryView()
                .tabItem { Label("拼图", systemImage: "square.grid.2x2") }
                .tag(Selection.collage)
        }
        .tint(.black)
        .preferredColorScheme(.light)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
