import SwiftUI

// Puzzle layout cover card: pure geometric shapes hint at the layout.
struct PuzzleLayoutCard: View {
    let layout: PuzzleLayout
    var width: CGFloat = 130
    var height: CGFloat = 160

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cover
                .frame(width: width, height: height)
                .background(AppTheme.Palette.card)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(layout.displayName)
                    .font(AppTheme.Font.small)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Palette.textPrimary)
                    .lineLimit(1)
                Text("\(layout.slotCount) 张照片 · \(layout.hint)")
                    .font(AppTheme.Font.caption)
                    .foregroundColor(AppTheme.Palette.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
            .padding(.top, 8)
            .frame(width: width, alignment: .leading)
        }
    }

    @ViewBuilder
    private var cover: some View {
        let pad: CGFloat = 14
        let gap: CGFloat = 6
        switch layout {
        case .vertical2:
            VStack(spacing: gap) {
                slot.cornerRadius(4)
                slot.cornerRadius(4)
            }
            .padding(pad)

        case .horizontal2:
            HStack(spacing: gap) {
                slot.cornerRadius(4)
                slot.cornerRadius(4)
            }
            .padding(pad)

        case .grid4:
            VStack(spacing: gap) {
                HStack(spacing: gap) {
                    slot.cornerRadius(4)
                    slot.cornerRadius(4)
                }
                HStack(spacing: gap) {
                    slot.cornerRadius(4)
                    slot.cornerRadius(4)
                }
            }
            .padding(pad)

        case .cameraDetail:
            cameraCover(model: .m11)

        case .cameraDetailQ3:
            cameraCover(model: .q3)

        case .polaroidStack, .filmStrip, .magazineCover:
            // Render the real layout (with sample photos) so the cover is
            // exactly what you get — same approach as the watermark cards.
            PuzzleLivePreview(layout: layout)
        }
    }

    private var slot: some View {
        Rectangle().fill(AppTheme.Palette.surface)
    }

    private func cameraCover(model: CameraBackModel) -> some View {
        VStack(spacing: 0) {
            ZStack {
                Color.white
                CameraBackView(model: model, image: UIImage(named: "sample_mountain"))
                    .frame(width: width * 0.74)
            }
            .frame(height: height * 0.46)
            .frame(maxWidth: .infinity)

            Image("sample_mountain")
                .resizable()
                .scaledToFill()
        }
    }
}

/// 用真实布局 + 示例照片渲染封面缩略图，缓存避免重复渲染。
private struct PuzzleLivePreview: View {
    let layout: PuzzleLayout
    @State private var rendered: UIImage?

    var body: some View {
        ZStack {
            AppTheme.Palette.surface
            if let rendered {
                Image(uiImage: rendered)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .tint(AppTheme.Palette.textTertiary)
            }
        }
        .task(id: layout) {
            rendered = PuzzlePreviewRenderer.image(for: layout)
        }
    }
}

enum PuzzlePreviewRenderer {
    @MainActor private static var cache: [String: UIImage] = [:]

    @MainActor
    static func image(for layout: PuzzleLayout) -> UIImage? {
        if let cached = cache[layout.id] { return cached }
        let names = ["sample_mountain", "sample_flowers", "sample_book", "sample_portrait_bw"]
        let imgs = (0..<layout.slotCount).compactMap { UIImage(named: names[$0 % names.count]) }
        guard !imgs.isEmpty else { return nil }
        let out = PuzzleComposer.render(
            images: imgs, layout: layout, options: PuzzleOptions(), maxLongEdge: 440
        )
        if let out { cache[layout.id] = out }
        return out
    }
}
