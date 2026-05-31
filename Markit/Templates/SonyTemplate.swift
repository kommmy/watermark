import SwiftUI

/// 索尼风格：右下角悬浮的半透明黑色圆角卡片，SONY + 机身 + 参数三段式。
/// 与图片叠加，不挤压原图比例。
struct SonyTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var unit: CGFloat { max(min(image.size.width, image.size.height) * 0.022, 14) }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            WatermarkPhotoFrame(
                image: image,
                borderColor: Color.white.opacity(0.16),
                shadowColor: Color.black.opacity(0.20),
                shadowRadius: 8,
                shadowY: 3
            )

            VStack(alignment: .leading, spacing: unit * 0.35) {
                Image("brand_sony")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: unit * 5.1, height: unit * 1.15, alignment: .leading)
                if meta.cameraDisplayName != "未知相机" {
                    Text(meta.cameraDisplayName)
                        .font(.system(size: unit * 0.85, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                }
                Rectangle()
                    .fill(Color.white.opacity(0.25))
                    .frame(height: 1)
                    .padding(.vertical, unit * 0.15)
                Text(meta.paramsLine)
                    .font(.system(size: unit * 0.85, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)
                if let date = meta.dateText {
                    Text(date)
                        .font(.system(size: unit * 0.7, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
            }
            .padding(unit * 1.2)
            .background(
                RoundedRectangle(cornerRadius: unit * 0.8, style: .continuous)
                    .fill(Color.black.opacity(0.55))
                    .overlay(
                        RoundedRectangle(cornerRadius: unit * 0.8, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                    )
            )
            .padding(unit * 2)
        }
    }
}

struct SonyTemplate_Previews: PreviewProvider {
    static var previews: some View {
        SonyTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
