import SwiftUI

// Two photos stacked vertically.
struct Vertical2Layout: View {
    let images: [UIImage]
    let options: PuzzleOptions

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                VStack(spacing: options.gap) {
                    PuzzleSlot(image: images[safe: 0])
                    PuzzleSlot(image: images[safe: 1])
                }
                .padding(options.gap * 1.4)

                if !options.caption.isEmpty {
                    Text(options.caption)
                        .font(.system(size: max(geo.size.width * 0.028, 11), weight: .medium))
                        .foregroundColor(options.background.captionColor)
                        .padding(.bottom, options.gap * 1.4)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            .background(options.background.view)
        }
        .aspectRatio(options.aspect.value, contentMode: .fit)
    }
}

// Shared slot view: fills with image (scaledToFill) or shows surface placeholder.
struct PuzzleSlot: View {
    let image: UIImage?
    var cornerRadius: CGFloat = 6

    var body: some View {
        ZStack {
            AppTheme.Palette.surface
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .clipped()
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
