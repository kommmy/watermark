import SwiftUI

/// Pic-Frame-style geometric thumbnail: draws a frame's cells as flat rounded
/// shapes on a card. Pure geometry (no image rendering), so the whole gallery
/// grid is cheap to scroll.
struct CollageFrameThumbnail: View {
    let frame: CollageFrame
    var isSelected: Bool = false

    private let gap: CGFloat = 5

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let radius = min(size.width, size.height) * 0.04
            ZStack(alignment: .topLeading) {
                Color.white
                ForEach(Array(frame.cells.enumerated()), id: \.offset) { _, cell in
                    let rect = CollageFrame.cellRect(cell, in: size, gap: gap)
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(Color(hex: 0xC3C8D2))
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                .stroke(isSelected ? Color.black : AppTheme.Palette.separator,
                        lineWidth: isSelected ? 2 : 1)
        )
    }
}

struct CollageFrameThumbnail_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            ForEach(CollageFrame.all) { frame in
                CollageFrameThumbnail(frame: frame)
            }
        }
        .padding()
        .background(AppTheme.Palette.background)
    }
}
