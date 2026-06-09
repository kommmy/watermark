import SwiftUI

/// 富士胶片风格：黑底信息条，左侧 FUJIFILM logo + 机身，右侧参数 + 拍摄日期。
/// 文字偏暖白色以致敬胶片机背的菜单印刷字。
struct FujiTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var barHeight: CGFloat { max(image.size.height * 0.10, 56) }
    private let warmWhite = Color(red: 0.94, green: 0.92, blue: 0.86)

    var body: some View {
        VStack(spacing: 0) {
            WatermarkPhotoFrame(
                image: image,
                borderColor: Color.white.opacity(0.10),
                shadowColor: Color.black.opacity(0.28),
                shadowRadius: 10,
                shadowY: 4
            )

            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: barHeight * 0.08) {
                    Image("brand_fujifilm")
                        .resizable()
                        .scaledToFit()
                        .frame(width: barHeight * 1.8, height: barHeight * 0.34, alignment: .leading)
                    Text(L10n.text(meta.cameraDisplayName == "未知相机" ? "X SERIES" : meta.cameraDisplayName))
                        .font(.system(size: barHeight * 0.18))
                        .foregroundColor(warmWhite.opacity(0.7))
                        .lineLimit(1)
                }

                Spacer(minLength: barHeight * 0.4)

                VStack(alignment: .trailing, spacing: barHeight * 0.08) {
                    Text(meta.paramsLine)
                        .font(.system(size: barHeight * 0.22, weight: .semibold, design: .monospaced))
                        .foregroundColor(warmWhite)
                        .lineLimit(1)
                    Text(meta.dateText ?? "")
                        .font(.system(size: barHeight * 0.16, design: .monospaced))
                        .foregroundColor(warmWhite.opacity(0.6))
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, barHeight * 0.5)
            .frame(height: barHeight)
            .frame(maxWidth: .infinity)
            .background(Color(white: 0.08))
        }
    }
}

struct FujiTemplate_Previews: PreviewProvider {
    static var previews: some View {
        FujiTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
