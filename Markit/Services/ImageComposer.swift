import SwiftUI
import UIKit

/// 用 SwiftUI `ImageRenderer` 把"原图 + 水印模板 View"渲染成单张 UIImage。
///
/// 设计要点：
/// - 模板内部用 `image.size.width` 作为布局基准（即 1pt = 1px）。
/// - 在这里通过 `proposedSize.width = renderWidth` 限定 View 宽度，使得 1pt 对应 1 个输出像素。
/// - `renderer.scale = 1` 保持像素 1:1，避免 2x/3x 屏环境下出现放大。
/// - `maxLongEdge` 控制输出长边像素上限（>5000 万像素的图渲染内存与耗时会爆炸）。
@MainActor
enum ImageComposer {

    /// 导出长边像素上限：按设备物理内存自适应。
    /// `ImageRenderer` 渲染 5000 万像素级图片瞬时内存可达数百 MB，
    /// 低内存机型直接渲染全分辨率有被系统强杀的风险，故分档限制；
    /// 高内存机型则尽量保留原图分辨率，避免水印导出后照片明显变小。
    static var defaultMaxLongEdge: CGFloat {
        let gb = Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824
        if gb >= 6 { return 8192 }   // 覆盖 iPhone 48MP 直出（8064 长边）
        if gb >= 4 { return 6144 }
        return 4096
    }

    /// `maxLongEdge` 传 `nil` 时使用 `defaultMaxLongEdge`（自适应）；
    /// 预览等场景可显式传入较小值以加快渲染。
    static func render(
        image: UIImage,
        meta: PhotoMetadata,
        template: WatermarkTemplate,
        maxLongEdge: CGFloat? = nil
    ) -> UIImage? {
        let originalSize = image.pixelSize
        guard originalSize.width > 0, originalSize.height > 0 else { return nil }

        let ceiling = maxLongEdge ?? defaultMaxLongEdge
        let longEdge = max(originalSize.width, originalSize.height)
        let downscale = longEdge > ceiling ? ceiling / longEdge : 1.0
        let renderWidth = floor(originalSize.width * downscale)

        // 把原图缩到目标渲染尺寸，模板里直接 Image(uiImage:).resizable() 即可保真。
        let scaledImage = image.resized(toWidth: renderWidth) ?? image

        let content = template
            .makeView(image: scaledImage, meta: meta)
            .frame(width: renderWidth)
            .fixedSize(horizontal: false, vertical: true)
            .environment(\.colorScheme, .light)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 1.0
        renderer.isOpaque = true
        renderer.proposedSize = ProposedViewSize(width: renderWidth, height: nil)
        return renderer.uiImage
    }
}

// MARK: - UIImage helpers

extension UIImage {
    /// 返回以像素为单位的真实尺寸（`size` 是逻辑尺寸，需乘以 scale）。
    var pixelSize: CGSize {
        CGSize(width: size.width * scale, height: size.height * scale)
    }

    /// 等比缩放到目标宽度，保留方向。
    func resized(toWidth targetWidth: CGFloat) -> UIImage? {
        guard size.width > 0, targetWidth > 0 else { return nil }
        // 已经比目标更小，直接复用原图，避免无谓重采样。
        if pixelSize.width <= targetWidth { return self }

        let ratio = targetWidth / pixelSize.width
        let newSize = CGSize(
            width: pixelSize.width * ratio,
            height: pixelSize.height * ratio
        )
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
