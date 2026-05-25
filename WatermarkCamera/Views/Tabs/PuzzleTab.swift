import SwiftUI

// Puzzle tab: grouped rows for collage layouts. Tap to enter the editor.
struct PuzzleTab: View {
    @State private var openQuickLayout = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                    intro
                    ForEach(BrowseCatalog.puzzleSections) { section in
                        puzzleSection(section)
                    }

                    Text("Every layout opens with clear slots. Tap each slot to add or replace a photo.")
                        .font(AppTheme.Font.caption)
                        .foregroundColor(AppTheme.Palette.textTertiary)
                        .padding(.horizontal, AppTheme.Spacing.l)
                        .padding(.bottom, AppTheme.Spacing.xl)
                }
                .padding(.vertical, AppTheme.Spacing.m)
            }
            .navigationTitle("Puzzles")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .bottom) {
                FloatingCreateButton { openQuickLayout = true }
                    .padding(.bottom, AppTheme.Spacing.xl)
            }
            .navigationDestination(isPresented: $openQuickLayout) {
                PuzzleEditorView(layout: .vertical2)
            }
            .toolbarBackground(AppTheme.Palette.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .appBackground()
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Build a story")
                .font(AppTheme.Font.title)
                .foregroundColor(AppTheme.Palette.textPrimary)
            Text("Before/after, camera detail and series layouts for social posts.")
                .font(AppTheme.Font.small)
                .foregroundColor(AppTheme.Palette.textSecondary)
        }
        .padding(.horizontal, AppTheme.Spacing.l)
    }

    private func puzzleSection(_ section: BrowseSection) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
            SectionHeader(title: section.title, trailing: nil)
            Text(section.subtitle)
                .font(AppTheme.Font.caption)
                .foregroundColor(AppTheme.Palette.textSecondary)
                .padding(.horizontal, AppTheme.Spacing.l)
                .padding(.top, -AppTheme.Spacing.s)

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
                            .accessibilityLabel("Open \(layout.displayName)")
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
