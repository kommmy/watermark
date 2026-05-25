import SwiftUI

// Signature camera-detail layout:
//   - Top: white tile holding the camera product image + a caption (e.g. "Ricoh GR 3")
//   - Bottom: the actual photo filling the rest
struct CameraDetailLayout: View {
    let images: [UIImage]
    let options: PuzzleOptions

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ZStack {
                    Color.white
                    VStack(spacing: 6) {
                        if let cam = images[safe: 0] {
                            Image(uiImage: cam)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: geo.size.width * 0.62)
                                .frame(maxHeight: geo.size.height * 0.28)
                        } else {
                            Image(systemName: "camera")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(Color(white: 0.4))
                        }
                        if !options.caption.isEmpty {
                            Text(options.caption)
                                .font(.system(size: max(geo.size.width * 0.030, 12), weight: .semibold))
                                .foregroundColor(Color(white: 0.15))
                        }
                    }
                    .padding(geo.size.width * 0.04)
                }
                .frame(height: geo.size.height * 0.38)

                PuzzleSlot(image: images[safe: 1])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(options.background.view)
        }
        .aspectRatio(options.aspect.value, contentMode: .fit)
    }
}
