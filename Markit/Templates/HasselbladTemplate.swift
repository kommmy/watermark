import SwiftUI

/// 哈苏风格：原图嵌入一个略大于自身的白色相纸画框，下方放品牌 logo 与参数行。
/// 适合人像 / 静物，视觉上像一张实体相纸。
struct HasselbladTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var pad: CGFloat { max(image.size.width * 0.04, 24) }
    private var footerHeight: CGFloat { max(image.size.width * 0.08, 56) }

    var body: some View {
        VStack(spacing: 0) {
            WatermarkPhotoFrame(
                image: image,
                borderColor: Color.black.opacity(0.08),
                shadowColor: Color.black.opacity(0.12),
                shadowRadius: 12,
                shadowY: 5
            )
                .padding(.horizontal, pad)
                .padding(.top, pad)

            HStack(alignment: .firstTextBaseline, spacing: pad * 0.5) {
                VStack(alignment: .leading, spacing: footerHeight * 0.08) {
                    Image("brand_hasselblad")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.black)
                        .frame(width: footerHeight * 3.2, height: footerHeight * 0.36, alignment: .leading)
                    if meta.cameraDisplayName != "未知相机" {
                        Text(meta.cameraDisplayName)
                            .font(.system(size: footerHeight * 0.22))
                            .foregroundColor(Color(white: 0.45))
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: footerHeight * 0.08) {
                    Text(meta.paramsLine)
                        .font(.system(size: footerHeight * 0.24, weight: .medium, design: .monospaced))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    if let date = meta.dateText {
                        Text(date)
                            .font(.system(size: footerHeight * 0.18, design: .monospaced))
                            .foregroundColor(Color(white: 0.45))
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, pad)
            .padding(.vertical, pad * 0.5)
            .padding(.bottom, pad * 0.5)
        }
        .background(Color.white)
    }
}

struct HasselbladTemplate_Previews: PreviewProvider {
    static var previews: some View {
        HasselbladTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
