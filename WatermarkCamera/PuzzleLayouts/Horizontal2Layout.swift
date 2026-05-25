import SwiftUI

// Two photos side by side.
struct Horizontal2Layout: View {
    let images: [UIImage]
    let options: PuzzleOptions

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                HStack(spacing: options.gap) {
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
