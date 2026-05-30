import SwiftUI

/// 徕卡风格：纯白底信息条占图片高 ~11%，
/// 左侧 LEICA 红色块 logo + 机身，右侧两列灰字（曝光参数 / 日期）。
struct LeicaTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var isPortrait: Bool { image.size.height > image.size.width * 1.08 }
    private var barHeight: CGFloat { max(min(image.size.height * 0.10, image.size.width * 0.18), 46) }

    var body: some View {
        VStack(spacing: 0) {
            WatermarkPhotoFrame(
                image: image,
                borderColor: Color.black.opacity(0.08),
                shadowColor: Color.black.opacity(0.10),
                shadowRadius: 8,
                shadowY: 3
            )

            HStack(alignment: .center, spacing: 0) {
                HStack(spacing: barHeight * 0.22) {
                    Image("brand_leica")
                        .resizable()
                        .scaledToFit()
                        .frame(width: barHeight * 0.74, height: barHeight * 0.74)

                    VStack(alignment: .leading, spacing: barHeight * 0.05) {
                        Text(meta.cameraDisplayName)
                            .font(.system(size: barHeight * 0.28, weight: .semibold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.55)
                    }
                }

                Spacer(minLength: barHeight * 0.3)

                Rectangle()
                    .fill(Color(white: 0.85))
                    .frame(width: 1, height: barHeight * 0.6)
                    .padding(.horizontal, barHeight * 0.2)

                VStack(alignment: .trailing, spacing: barHeight * 0.05) {
                    Text(meta.compactExposureLine)
                        .font(.system(size: barHeight * 0.22, weight: .medium, design: .monospaced))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(isPortrait ? 0.36 : 0.48)
                    if !isPortrait, let date = meta.dateText {
                        Text(date)
                            .font(.system(size: barHeight * 0.16, design: .monospaced))
                            .foregroundColor(Color(white: 0.45))
                            .lineLimit(1)
                            .minimumScaleFactor(0.55)
                    }
                }
            }
            .padding(.horizontal, isPortrait ? barHeight * 0.24 : barHeight * 0.4)
            .frame(height: barHeight)
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
    }
}

struct LeicaTemplate_Previews: PreviewProvider {
    static var previews: some View {
        LeicaTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
