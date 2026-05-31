import SwiftUI
import UIKit
import CoreImage

/// 徕卡毛玻璃：整张照片四周留一圈"毛玻璃"边框（同图高斯模糊 + 白色磨砂），
/// 清晰原图居中，底部居中显示徕卡红标 + 镜头型号，下面一行曝光参数。
///
/// 模糊背景用 CoreImage 预先渲染成一张 UIImage，而不是用 SwiftUI 的 `.blur()`——
/// 后者在 `ImageRenderer` 离屏渲染里并不可靠，预渲染保证导出结果稳定。
struct LeicaGlassTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata
    private let frosted: UIImage

    init(image: UIImage, meta: PhotoMetadata) {
        self.image = image
        self.meta = meta
        self.frosted = LeicaGlassTemplate.makeFrosted(from: image)
    }

    private var unit: CGFloat { image.size.width }
    private var frameInset: CGFloat { max(unit * 0.020, 14) }
    private var logoSize: CGFloat { max(unit * 0.030, 18) }
    private var lensFont: CGFloat { max(unit * 0.0150, 13) }
    private var paramFont: CGFloat { max(unit * 0.0112, 10) }

    /// 第一行：优先镜头型号（大写），缺失时退回机身名。
    private var titleText: String {
        let lens = meta.lensDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return (lens.isEmpty ? meta.cameraDisplayName : lens).uppercased()
    }

    /// 第二行：快门 · 光圈 · ISO · 焦段，读不到时填徕卡风格默认值，保证排版完整。
    private var paramText: String {
        let parts = [meta.shutter, meta.apertureText, meta.isoText, meta.focalLengthText]
            .compactMap { $0 }
        if !parts.isEmpty { return parts.joined(separator: "  ·  ") }
        return "1/250s  ·  f/1.4  ·  ISO 200  ·  35mm"
    }

    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: unit * 0.004, style: .continuous))
                .shadow(color: .black.opacity(0.16), radius: frameInset * 0.5, y: frameInset * 0.18)
                .padding(.horizontal, frameInset)
                .padding(.top, frameInset)

            VStack(spacing: unit * 0.0065) {
                HStack(spacing: logoSize * 0.42) {
                    Image("brand_leica")
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoSize, height: logoSize)
                    Text(titleText)
                        .font(.system(size: lensFont, weight: .semibold))
                        .tracking(lensFont * 0.04)
                        .foregroundColor(.black.opacity(0.85))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }

                Text(paramText)
                    .font(.system(size: paramFont, weight: .medium, design: .monospaced))
                    .tracking(paramFont * 0.04)
                    .foregroundColor(.black.opacity(0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, unit * 0.024)
            .padding(.bottom, unit * 0.030)
            .padding(.horizontal, frameInset)
        }
        .frame(maxWidth: .infinity)
        .background(
            Image(uiImage: frosted)
                .resizable()
                .scaledToFill()
                .overlay(Color.white.opacity(0.40))
                .clipped()
        )
    }

    /// 把原图缩小后做高斯模糊，作为毛玻璃边框背景。
    private static func makeFrosted(from image: UIImage) -> UIImage {
        let small = image.resized(toWidth: 240) ?? image
        guard let input = CIImage(image: small) else { return small }
        let blurred = input
            .clampedToExtent()                 // 钳制边缘，避免模糊后四周变透明
            .applyingGaussianBlur(sigma: 16)
        let context = CIContext(options: nil)
        guard let cg = context.createCGImage(blurred, from: input.extent) else { return small }
        return UIImage(cgImage: cg)
    }
}

struct LeicaGlassTemplate_Previews: PreviewProvider {
    static var previews: some View {
        LeicaGlassTemplate(image: UIImage(named: "sample_mountain") ?? UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
