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
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, pad)
                .padding(.top, pad)

            HStack(alignment: .firstTextBaseline, spacing: pad * 0.5) {
                VStack(alignment: .leading, spacing: footerHeight * 0.08) {
                    HStack(spacing: footerHeight * 0.12) {
                        Text("H")
                            .font(.system(size: footerHeight * 0.55, weight: .black))
                            .foregroundColor(.white)
                            .frame(
                                width: footerHeight * 0.55,
                                height: footerHeight * 0.55
                            )
                            .background(Circle().fill(Color.black))
                        Text("HASSELBLAD")
                            .font(.system(size: footerHeight * 0.32, weight: .bold))
                            .foregroundColor(.black)
                            .tracking(footerHeight * 0.04)
                    }
                    if let model = meta.cameraModel {
                        Text(model)
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

#Preview {
    HasselbladTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
        .frame(width: 600)
}
