import SwiftUI

// Puzzle tab: 2-col grid of all 4 layouts. Tap to enter the editor.
struct PuzzleTab: View {
    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.m),
        GridItem(.flexible(), spacing: AppTheme.Spacing.m),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: AppTheme.Spacing.l) {
                    ForEach(PuzzleLayout.allCases) { layout in
                        NavigationLink {
                            PuzzleEditorView(layout: layout)
                        } label: {
                            PuzzleLayoutCard(layout: layout, width: 160, height: 200)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(AppTheme.Spacing.l)
            }
            .navigationTitle("Puzzles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.Palette.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .appBackground()
        }
    }
}

struct PuzzleTab_Previews: PreviewProvider {
    static var previews: some View {
        PuzzleTab().preferredColorScheme(.dark)
    }
}
