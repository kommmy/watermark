import SwiftUI

/// 色彩漫步：取照片最具代表性的颜色铺成顶部色块，配一句艺术 serif 点评，
/// 下方接整张照片。色块在 init 里算一次，避免布局时反复采样。
struct ColorWalkTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata
    private let palette: PhotoPalette

    init(image: UIImage, meta: PhotoMetadata) {
        self.image = image
        self.meta = meta
        self.palette = image.colorWalkPalette()
    }

    /// 模板内 1pt == 1px，所有尺寸以图宽为基准，适配任意分辨率。
    private var w: CGFloat { image.size.width }

    /// 主标题：用户点评优先，否则艺术日期。
    private var mainText: String { meta.colorWalkText }

    /// 用户写了自定义点评时，下方再补一行小字日期（像参考图里"主题 + 日期"那样）。
    private var subText: String? {
        guard let c = meta.caption?.trimmingCharacters(in: .whitespacesAndNewlines),
              !c.isEmpty, c != meta.artisticDate else { return nil }
        return meta.artisticDate
    }

    var body: some View {
        VStack(spacing: 0) {
            colorBlock
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
    }

    private var colorBlock: some View {
        ZStack {
            palette.main
            VStack(spacing: w * 0.018) {
                Text(mainText)
                    .font(.system(size: w * 0.058, weight: .regular, design: .serif))
                    .italic()
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.5)
                if let subText {
                    Text(subText)
                        .font(.system(size: w * 0.030, weight: .regular, design: .serif))
                        .tracking(w * 0.004)
                        .opacity(0.82)
                }
            }
            .foregroundColor(palette.onMain)
            .padding(.horizontal, w * 0.12)
        }
        .frame(width: w, height: w * 0.66)
    }
}

struct ColorWalkTemplate_Previews: PreviewProvider {
    static var previews: some View {
        ColorWalkTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
