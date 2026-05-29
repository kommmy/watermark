import SwiftUI

/// 胶片边框：经典黑色电影胶片风格
/// 上下各有打孔条（sprocket holes），照片居中，
/// 底部 Leica 红点 + 参数，白字。
struct FilmBorderTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var imgW: CGFloat { image.size.width }
    private var sprocketH: CGFloat { max(imgW * 0.058, 36) }
    private var sideW:     CGFloat { max(imgW * 0.060, 38) }
    private var infoH:     CGFloat { max(imgW * 0.095, 56) }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Full black background
            Color.black

            VStack(spacing: 0) {
                // ── Top sprocket strip ─────────────────────────────
                sprocketStrip(height: sprocketH)

                // ── Photo ──────────────────────────────────────────
                HStack(spacing: 0) {
                    sideStrip(width: sideW, height: imgH)
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                    sideStrip(width: sideW, height: imgH)
                }

                // ── Bottom sprocket strip ─────────────────────────
                sprocketStrip(height: sprocketH)

                // ── Info bar ──────────────────────────────────────
                HStack(alignment: .center, spacing: 0) {
                    // Leica dot logo
                    Circle()
                        .fill(Color(red: 0.86, green: 0.03, blue: 0.05))
                        .frame(width: infoH * 0.42, height: infoH * 0.42)
                        .overlay(
                            Text("Leica")
                                .font(.system(size: max(infoH * 0.095, 7), weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                        )

                    VStack(alignment: .leading, spacing: infoH * 0.08) {
                        Text(meta.cameraDisplayName)
                            .font(.system(size: infoH * 0.22, weight: .semibold))
                            .foregroundColor(.white)
                        if !meta.lensDisplayName.isEmpty {
                            Text(meta.lensDisplayName)
                                .font(.system(size: infoH * 0.14, design: .monospaced))
                                .foregroundColor(.white.opacity(0.52))
                        }
                    }
                    .padding(.leading, infoH * 0.28)

                    Spacer(minLength: infoH * 0.3)

                    VStack(alignment: .trailing, spacing: infoH * 0.08) {
                        Text(meta.paramsLine)
                            .font(.system(size: infoH * 0.19, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                        Text(meta.paramsDate)
                            .font(.system(size: infoH * 0.14, design: .monospaced))
                            .foregroundColor(.white.opacity(0.50))
                    }
                }
                .padding(.horizontal, sideW)
                .frame(height: infoH)
            }
        }
    }

    // Approximate photo height (aspect-fit within full width minus sides)
    private var imgH: CGFloat {
        let photoW = imgW - sideW * 2
        return photoW * (image.size.height / image.size.width)
    }

    private func sprocketStrip(height: CGFloat) -> some View {
        HStack(spacing: 0) {
            sideStrip(width: sideW, height: height)
                .overlay(alignment: .leading) {
                    HStack(spacing: height * 0.32) {
                        ForEach(0..<Int(max(imgW / (height * 1.1), 2)), id: \.self) { _ in
                            RoundedRectangle(cornerRadius: height * 0.12, style: .continuous)
                                .fill(Color.white.opacity(0.14))
                                .frame(width: height * 0.52, height: height * 0.60)
                        }
                    }
                    .padding(.leading, height * 0.16)
                }
            Color.black
                .frame(maxWidth: .infinity, maxHeight: height)
            sideStrip(width: sideW, height: height)
        }
    }

    private func sideStrip(width: CGFloat, height: CGFloat) -> some View {
        Color(white: 0.04).frame(width: width, height: height)
    }
}
