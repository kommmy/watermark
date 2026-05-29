import SwiftUI

/// 极简风格：仅底部一行细白条，居中显示 "机型 · 参数 · 日期"，无 logo，适合社交媒体。
struct MinimalTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var barHeight: CGFloat { max(image.size.height * 0.07, 44) }

    var body: some View {
        VStack(spacing: 0) {
            WatermarkPhotoFrame(
                image: image,
                borderColor: Color.black.opacity(0.08),
                shadowColor: Color.black.opacity(0.08),
                shadowRadius: 6,
                shadowY: 2
            )

            HStack(spacing: barHeight * 0.5) {
                if meta.cameraDisplayName != "未知相机" {
                    Text(meta.cameraDisplayName)
                        .font(.system(size: barHeight * 0.32, weight: .medium))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    Rectangle()
                        .fill(Color(white: 0.85))
                        .frame(width: 1, height: barHeight * 0.45)
                }
                Text(detailLine)
                    .font(.system(size: barHeight * 0.28, weight: .light, design: .monospaced))
                    .foregroundColor(Color(white: 0.35))
                    .lineLimit(1)
            }
            .padding(.horizontal, barHeight * 0.6)
            .frame(height: barHeight)
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
    }

    private var detailLine: String {
        [meta.focalLengthText, meta.apertureText, meta.shutter, meta.isoText, meta.dateText]
            .compactMap { $0 }
            .joined(separator: "  ·  ")
    }
}

struct MinimalTemplate_Previews: PreviewProvider {
    static var previews: some View {
        MinimalTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
