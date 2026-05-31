import SwiftUI

struct CameraDetailLayout: View {
    let images: [UIImage]
    let options: PuzzleOptions
    var camera: CameraBackModel = .m11

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let camBlockH = cameraBlockHeight(for: w)

            VStack(spacing: 0) {
                // ── Camera section ────────────────────────────────────
                VStack(spacing: 0) {
                    CameraBackView(model: camera, image: images.first)
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
        let cameraH  = cameraW / camera.bodyAspect
        let topPad   = width * 0.036
        let botPad   = width * 0.044
        return topPad + cameraH + botPad
    }
}
