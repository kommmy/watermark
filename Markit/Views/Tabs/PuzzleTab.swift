import SwiftUI

// Puzzle tab: grouped rows for collage layouts. Tap to enter the editor.
struct PuzzleTab: View {
    @State private var openQuickLayout = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                    ForEach(BrowseCatalog.puzzleSections) { section in
                        puzzleSection(section)
                    }
                }
                .padding(.top, AppTheme.Spacing.m)
                .padding(.bottom, 104)
            }
            .navigationTitle("拼图")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .bottomTrailing) {
                FloatingCreateButton { openQuickLayout = true }
                    .padding(.trailing, AppTheme.Spacing.l)
                    .padding(.bottom, AppTheme.Spacing.xl)
            }
            .navigationDestination(isPresented: $openQuickLayout) {
                PuzzleEditorView(layout: .cameraDetail)
            }
            .toolbarBackground(AppTheme.Palette.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .appBackground()
        }
    }

    private func puzzleSection(_ section: BrowseSection) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
            SectionHeader(title: section.title, trailing: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.m) {
                    ForEach(section.items) { item in
                        if case .puzzle(let layout) = item {
                            NavigationLink {
                                PuzzleEditorView(layout: layout)
                            } label: {
                                PuzzleLayoutCard(layout: layout, width: 148, height: 184)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("打开\(layout.displayName)")
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.l)
            }
        }
    }
}

struct PuzzleTab_Previews: PreviewProvider {
    static var previews: some View {
        PuzzleTab().preferredColorScheme(.dark)
    }
}
