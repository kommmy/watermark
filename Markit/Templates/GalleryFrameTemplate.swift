import SwiftUI

/// 画廊边框：美术馆级别宽边白框
/// 大量留白，照片居中，底部 Leica 红点 + 简洁信息，
/// 支持横竖版照片自动适配。
struct GalleryFrameTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var imgW: CGFloat { image.size.width }
    private var isPortrait: Bool { image.size.height > image.size.width }

    // Adaptive padding: portrait needs less horizontal padding so photo stays large
    private var hPad:    CGFloat { imgW * (isPortrait ? 0.080 : 0.095) }
    private var vPadTop: CGFloat { imgW * 0.080 }
    private var infoH:   CGFloat { max(imgW * 0.115, 68) }
    private var vPadBot: CGFloat { max(imgW * 0.040, 28) }

    var body: some View {
        VStack(spacing: 0) {
            // ── Top padding ─────────────────────────────────────
            Color(red: 0.960, green: 0.952, blue: 0.940)
                .frame(height: vPadTop)

            // ── Photo with subtle shadow ─────────────────────────
            WatermarkPhotoFrame(
                image: image,
                cornerRadius: max(imgW * 0.006, 3),
                borderColor: Color.black.opacity(0.08),
                lineWidth: 1,
                shadowColor: Color.black.opacity(0.18),
                shadowRadius: max(imgW * 0.014, 10),
                shadowY: max(imgW * 0.008, 5)
            )
            .padding(.horizontal, hPad)
            .background(Color(red: 0.960, green: 0.952, blue: 0.940))

            // ── Info bar ─────────────────────────────────────────
            HStack(alignment: .center, spacing: 0) {
                // Leica red dot
                Circle()
                    .fill(Color(red: 0.86, green: 0.03, blue: 0.05))
                    .frame(width: infoH * 0.38, height: infoH * 0.38)
                    .overlay(
                        Text("Leica")
                            .font(.system(size: max(infoH * 0.088, 6), weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.5)
                    )

                VStack(alignment: .leading, spacing: infoH * 0.07) {
                    Text(meta.cameraDisplayName)
                        .font(.system(size: infoH * 0.20, weight: .semibold))
                        .foregroundColor(Color(white: 0.15))
                    if !meta.lensDisplayName.isEmpty {
                        Text(meta.lensDisplayName)
                            .font(.system(size: infoH * 0.13, design: .monospaced))
                            .foregroundColor(Color(white: 0.50))
                    }
                }
                .padding(.leading, infoH * 0.26)

                Spacer(minLength: infoH * 0.2)

                // Divider
                Rectangle()
                    .fill(Color(white: 0.80))
                    .frame(width: 0.5, height: infoH * 0.55)
                    .padding(.horizontal, infoH * 0.18)

                VStack(alignment: .trailing, spacing: infoH * 0.07) {
                    Text(meta.paramsLine)
                        .font(.system(size: infoH * 0.18, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(white: 0.18))
                    Text(meta.paramsDate)
                        .font(.system(size: infoH * 0.13, design: .monospaced))
                        .foregroundColor(Color(white: 0.50))
                }
            }
            .padding(.horizontal, hPad)
            .frame(height: infoH)
            .background(Color(red: 0.960, green: 0.952, blue: 0.940))

            // ── Bottom padding ───────────────────────────────────
            Color(red: 0.960, green: 0.952, blue: 0.940)
                .frame(height: vPadBot)
        }
    }
}
