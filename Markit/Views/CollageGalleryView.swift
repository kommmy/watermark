import SwiftUI

/// The 拼图 tab: a Pic-Frame-style gallery of collage shapes grouped by photo
/// count. Tap a shape to open the editor and fill it with photos.
struct CollageGalleryView: View {
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: AppTheme.Spacing.xl, pinnedViews: []) {
                    ForEach(CollageFrame.groups, id: \.count) { group in
                        section(count: group.count, frames: group.frames)
                    }
                }
                .padding(.top, AppTheme.Spacing.m)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .navigationTitle("拼图")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.Palette.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .appBackground()
        }
    }

    private func section(count: Int, frames: [CollageFrame]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
            SectionHeader(title: L10n.photoCount(count))

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(frames) { frame in
                    NavigationLink {
                        CollageEditorView(frame: frame)
                    } label: {
                        CollageFrameThumbnail(frame: frame)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(L10n.photoCollageLabel(count)))
                }
            }
            .padding(.horizontal, AppTheme.Spacing.l)
        }
    }
}

struct CollageGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        CollageGalleryView()
    }
}
