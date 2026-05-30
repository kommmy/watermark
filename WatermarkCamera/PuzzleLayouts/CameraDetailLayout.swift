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
                VStack(spacing: 0) {
                    LeicaM11Screen(image: images.first)
                        .frame(width: w * 0.80)
                }
                .padding(.top, w * 0.036)
                .padding(.bottom, w * 0.044)
                .frame(maxWidth: .infinity)
                .background(Color.white)

                // ── Photo section (full-bleed, no separator / letterbox) ──
                let photoH = max(h - camBlockH, 0)
                if let img = images.first {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: w, height: photoH)
                        .clipped()
                } else {
                    Color.white.frame(width: w, height: photoH)
                }
            }
            .frame(width: w, height: h)
            .clipShape(RoundedRectangle(cornerRadius: w * 0.036, style: .continuous))
            .shadow(color: .black.opacity(0.14), radius: 22, x: 0, y: 10)
        }
        .aspectRatio(options.aspect.value, contentMode: .fit)
        .padding(2)
    }

    private func cameraBlockHeight(for width: CGFloat) -> CGFloat {
        let cameraW  = width * 0.80
        let cameraH  = cameraW / LeicaM11Screen.photoAspect
        let topPad   = width * 0.036
        let botPad   = width * 0.044
        return topPad + cameraH + botPad
    }
}

// MARK: - M11 back panel with real photo in LCD

struct LeicaM11Screen: View {
    let image: UIImage?

    static let photoAspect: CGFloat = 1.6233
    // LCD glass rectangle measured directly from the camera_m11_back artwork
    // (1284×791): the visible screen spans x:[395,842] y:[263,602].
    private let lcdLeft: CGFloat = 395.0 / 1284.0
    private let lcdTop: CGFloat = 263.0 / 791.0
    private let lcdWidth: CGFloat = 447.0 / 1284.0
    private let lcdHeight: CGFloat = 339.0 / 791.0

    var body: some View {
        Color.clear
            .aspectRatio(Self.photoAspect, contentMode: .fit)
            .overlay(alignment: .topLeading) {
                GeometryReader { geo in
                    // Photo is drawn ON TOP of the camera, masked to the measured
                    // glass rect — so alignment no longer depends on the asset's
                    // hand-cut transparent hole (which didn't match the screen).
                    ZStack(alignment: .topLeading) {
                        Image("camera_m11_back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width, height: geo.size.height)

                        screenPhoto(in: geo.size)
                    }
                }
            }
            // Grounded contact shadow: soft and dropped low so the camera
            // sits on the page instead of floating.
            .shadow(color: Color.black.opacity(0.22), radius: 18, x: 0, y: 12)
    }

    @ViewBuilder
    private func screenPhoto(in size: CGSize) -> some View {
        let w = size.width
        let h = size.height
        // Small overscan so the photo fills the glass edge-to-edge with no
        // sub-pixel seam; the bleed lands on the (opaque) bezel rim and is
        // invisible. The camera artwork's screen is solid, so nothing white
        // can show through behind the photo.
        let bleed = w * 0.004
        let screenW = w * lcdWidth + bleed * 2
        let screenH = h * lcdHeight + bleed * 2

        ZStack {
            Color.black
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenW, height: screenH)
            }
        }
        .frame(width: screenW, height: screenH)
        .clipShape(RoundedRectangle(cornerRadius: w * 0.008, style: .continuous))
        .offset(x: w * lcdLeft - bleed, y: h * lcdTop - bleed)
    }
}
