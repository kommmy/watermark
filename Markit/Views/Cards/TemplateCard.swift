import SwiftUI
import UIKit

struct TemplateCard: View {
    let template: WatermarkTemplate
    var width: CGFloat = 130
    var height: CGFloat = 160

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TemplatePreviewArtwork(template: template)
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 12, y: 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(template.displayName)
                    .font(AppTheme.Font.small)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Palette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Text(template.brandLabel)
                    .font(AppTheme.Font.caption)
                    .foregroundColor(AppTheme.Palette.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
            .padding(.top, 8)
            .frame(width: width, alignment: .leading)
        }
    }
}

/// 封面 = 用真实模板渲染一张缩略图，保证"所见即所得"，
/// 不再用一套独立的手画近似图（那会和真实水印对不上）。
private struct TemplatePreviewArtwork: View {
    let template: WatermarkTemplate
    @State private var rendered: UIImage?

    var body: some View {
        ZStack {
            Color.white
            if let rendered {
                Image(uiImage: rendered)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .tint(AppTheme.Palette.textTertiary)
            }
        }
        .task(id: template) {
            rendered = TemplatePreviewRenderer.image(for: template)
        }
    }
}

/// 把真实模板渲染成缩略图并缓存，避免列表滚动时反复渲染。
enum TemplatePreviewRenderer {
    @MainActor private static var cache: [String: UIImage] = [:]

    @MainActor
    static func image(for template: WatermarkTemplate) -> UIImage? {
        if let cached = cache[template.id] { return cached }
        guard let base = UIImage(named: sampleName(for: template)) else { return nil }
        // 裁成竖构图，模板渲染后更贴合竖向封面卡。
        let source = base.croppedToAspect(0.8) ?? base
        let image = ImageComposer.render(
            image: source,
            meta: .preview,
            template: template,
            maxLongEdge: 520
        )
        if let image { cache[template.id] = image }
        return image
    }

    private static func sampleName(for template: WatermarkTemplate) -> String {
        switch template {
        case .leica_mono, .leica_compact:
            return "sample_portrait_bw"
        case .leica_gallery, .minimal, .clean_instagram:
            return "sample_flowers"
        case .leica_frame, .gallery_frame, .soft_journal, .polaroid:
            return "sample_book"
        default:
            return "sample_mountain"
        }
    }
}

private extension UIImage {
    /// 居中裁剪到目标宽高比（width / height）。
    func croppedToAspect(_ aspect: CGFloat) -> UIImage? {
        guard let cg = cgImage, aspect > 0 else { return nil }
        let w = CGFloat(cg.width), h = CGFloat(cg.height)
        var cw = w, ch = h
        if w / h > aspect { cw = h * aspect } else { ch = w / aspect }
        let rect = CGRect(x: (w - cw) / 2, y: (h - ch) / 2, width: cw, height: ch)
        guard let cropped = cg.cropping(to: rect.integral) else { return nil }
        return UIImage(cgImage: cropped)
    }
}
