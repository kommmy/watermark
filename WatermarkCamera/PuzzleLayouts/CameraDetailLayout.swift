import SwiftUI

struct CameraDetailLayout: View {
    let images: [UIImage]
    let options: PuzzleOptions

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let camBlockH = cameraBlockHeight(for: w)

            VStack(spacing: 0) {
                // ── Camera section ────────────────────────────────────
                VStack(spacing: w * 0.022) {
                    LeicaM11Screen(image: images.first)
                        .frame(width: w * 0.70)
                    Text("Leica M11")
                        .font(.system(size: max(w * 0.032, 11), weight: .light))
                        .tracking(max(w * 0.005, 1.5))
                        .foregroundColor(Color(white: 0.40))
                }
                .padding(.top, w * 0.052)
                .padding(.bottom, w * 0.032)
                .frame(maxWidth: .infinity)
                // Warm photographic paper background
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.957, green: 0.942, blue: 0.922),
                            Color(red: 0.932, green: 0.915, blue: 0.892)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // ── Separator ─────────────────────────────────────────
                Rectangle()
                    .fill(Color(white: 0.82))
                    .frame(height: 0.5)

                // ── Photo section ─────────────────────────────────────
                let photoH = max(h - camBlockH - 0.5, 0)
                ZStack {
                    Color(white: 0.14)
                    if let img = images.first {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: w, height: photoH)
                .clipped()
            }
            .frame(width: w, height: h)
            .clipShape(RoundedRectangle(cornerRadius: w * 0.036, style: .continuous))
            .shadow(color: .black.opacity(0.14), radius: 22, x: 0, y: 10)
        }
        .aspectRatio(options.aspect.value, contentMode: .fit)
        .padding(2)
    }

    private func cameraBlockHeight(for width: CGFloat) -> CGFloat {
        let cameraW  = width * 0.70
        let cameraH  = cameraW / LeicaM11Screen.photoAspect
        let labelH   = max(width * 0.04, 13)
        let spacing  = width * 0.022
        let topPad   = width * 0.052
        let botPad   = width * 0.032
        return topPad + cameraH + spacing + labelH + botPad
    }
}

// MARK: - M11 back panel with real photo in LCD

struct LeicaM11Screen: View {
    let image: UIImage?

    // Aspect ratio of camera_m11_back.jpg (1284 x 791 px)
    static let photoAspect: CGFloat = 1.6233

    // LCD bounds pixel-measured from 1284×791 product photo.
    // Slightly expanded beyond the bezel to guarantee full coverage.
    private let lcdLeft:   CGFloat = 0.318
    private let lcdTop:    CGFloat = 0.265
    private let lcdWidth:  CGFloat = 0.372
    private let lcdHeight: CGFloat = 0.530

    var body: some View {
        Color.clear
            .aspectRatio(Self.photoAspect, contentMode: .fit)
            .overlay(alignment: .topLeading) {
                GeometryReader { geo in
                    ZStack(alignment: .topLeading) {
                        Image("camera_m11_back")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()

                        if let img = image {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(
                                    width:  geo.size.width  * lcdWidth,
                                    height: geo.size.height * lcdHeight
                                )
                                .clipped()
                                .offset(
                                    x: geo.size.width  * lcdLeft,
                                    y: geo.size.height * lcdTop
                                )
                        }
                    }
                }
            }
            .shadow(color: Color.black.opacity(0.20), radius: 14, x: 0, y: 6)
    }
}
