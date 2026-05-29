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

                    Text("只需要选择一张照片，会自动放进徕卡取景框和下方成片。")
                        .font(AppTheme.Font.caption)
                        .foregroundColor(AppTheme.Palette.textTertiary)
                        .padding(.horizontal, AppTheme.Spacing.l)
                        .padding(.bottom, 104)
                }
                .padding(.vertical, AppTheme.Spacing.m)
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

    private var intro: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("徕卡相机拼图")
                .font(AppTheme.Font.title)
                .foregroundColor(AppTheme.Palette.textPrimary)
            Text("上面是一台徕卡相机，取景框里显示照片；下面展示同一张成片。")
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
