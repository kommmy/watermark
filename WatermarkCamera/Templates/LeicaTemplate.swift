import SwiftUI

/// 徕卡风格：纯白底信息条占图片高 ~11%，
/// 左侧 LEICA 红色块 logo + 机身/镜头，右侧两列灰字（参数 / 日期）。
struct LeicaTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var barHeight: CGFloat { max(image.size.height * 0.11, 56) }

    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)

            HStack(alignment: .center, spacing: 0) {
                HStack(spacing: barHeight * 0.22) {
                    Text("LEICA")
                        .font(.system(size: barHeight * 0.32, weight: .heavy))
                        .foregroundColor(.white)
                        .tracking(barHeight * 0.02)
                        .padding(.horizontal, barHeight * 0.2)
                        .padding(.vertical, barHeight * 0.08)
                        .background(Color(red: 0.86, green: 0.07, blue: 0.13))

                    VStack(alignment: .leading, spacing: barHeight * 0.05) {
                        Text(meta.cameraModel ?? meta.brand.displayName)
                            .font(.system(size: barHeight * 0.28, weight: .semibold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        if let lens = meta.lensModel, !lens.isEmpty {
                            Text(lens)
                                .font(.system(size: barHeight * 0.16))
                                .foregroundColor(Color(white: 0.45))
                                .lineLimit(1)
                        }
                    }
                }

                Spacer(minLength: barHeight * 0.3)

                Rectangle()
                    .fill(Color(white: 0.85))
                    .frame(width: 1, height: barHeight * 0.6)
                    .padding(.horizontal, barHeight * 0.2)

                VStack(alignment: .trailing, spacing: barHeight * 0.05) {
                    Text(meta.paramsLine)
                        .font(.system(size: barHeight * 0.22, weight: .medium, design: .monospaced))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    if let date = meta.dateText {
                        Text(date)
                            .font(.system(size: barHeight * 0.16, design: .monospaced))
                            .foregroundColor(Color(white: 0.45))
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, barHeight * 0.4)
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
