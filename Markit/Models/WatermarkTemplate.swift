import SwiftUI

/// 一个水印模板就是一段 SwiftUI View。新增模板：
///   1. 在 Templates/ 下新建 `<Name>Template.swift`，实现一个 `View`
///   2. 在下面的 enum 里加一个 case
///   3. 在 `displayName` 和 `makeView(image:meta:)` switch 里补对应分支
///
/// Template ids are aligned with docs/script.js TEMPLATES so Web and iOS stay in lockstep.
enum WatermarkTemplate: String, CaseIterable, Identifiable, Hashable {
    case leica
    case leica_mono       // swiftlint:disable:this identifier_name
    case leica_frame      // swiftlint:disable:this identifier_name
    case leica_compact    // swiftlint:disable:this identifier_name
    case leica_gallery    // swiftlint:disable:this identifier_name
    case leica_glass      // swiftlint:disable:this identifier_name
    case leica_white_space // swiftlint:disable:this identifier_name
    case fujifilm
    case fuji_strip       // swiftlint:disable:this identifier_name
    case sony
    case hasselblad
    case ricoh_gr         // swiftlint:disable:this identifier_name
    case iphone
    case polaroid
    case minimal
    case minimal_dark     // swiftlint:disable:this identifier_name
    case date_stamp       // swiftlint:disable:this identifier_name
    case soft_journal     // swiftlint:disable:this identifier_name
    case clean_instagram  // swiftlint:disable:this identifier_name
    case magazine_cover   // swiftlint:disable:this identifier_name
    case receipt_memo     // swiftlint:disable:this identifier_name
    case film_border      // swiftlint:disable:this identifier_name
    case gallery_frame    // swiftlint:disable:this identifier_name

    var id: String { rawValue }

    static let leicaTemplates: [WatermarkTemplate] = [
        .leica,
        .leica_white_space,
        .leica_compact,
        .leica_glass
    ]

    var displayName: String {
        switch self {
        case .leica:        return "白标作品卡"
        case .leica_mono:   return "黑白作品卡"
        case .leica_frame:  return "相纸边框"
        case .leica_compact:return "角标参数"
        case .leica_gallery:return "画廊留白"
        case .leica_glass:  return "毛玻璃"
        case .leica_white_space: return "留白相框"
        case .fujifilm:     return "富士暗调"
        case .fuji_strip:   return "富士胶片"
        case .sony:         return "索尼 Alpha"
        case .hasselblad:   return "哈苏相纸"
        case .ricoh_gr:     return "理光 GR"
        case .iphone:       return "iPhone 拍摄"
        case .polaroid:     return "宝丽来"
        case .minimal:      return "极简白框"
        case .minimal_dark: return "极简黑框"
        case .date_stamp:   return "日期戳"
        case .soft_journal: return "柔和手记"
        case .clean_instagram: return "干净社媒"
        case .magazine_cover: return "杂志封面"
        case .receipt_memo:   return "小票手记"
        case .film_border:    return "胶片边框"
        case .gallery_frame:  return "画廊边框"
        }
    }

    var brandLabel: String {
        switch self {
        case .leica, .leica_mono, .leica_frame, .leica_compact, .leica_gallery,
             .leica_glass, .leica_white_space, .film_border, .gallery_frame: return "作品卡"
        case .fujifilm, .fuji_strip:return "FUJIFILM"
        case .sony:                 return "SONY"
        case .hasselblad:           return "HASSELBLAD"
        case .ricoh_gr:             return "RICOH"
        case .iphone:               return "iPhone"
        case .polaroid:             return "宝丽来"
        case .minimal, .minimal_dark:  return "极简"
        case .date_stamp:           return "胶片日期"
        case .soft_journal:         return "生活手记"
        case .clean_instagram:      return "社媒卡片"
        case .magazine_cover:       return "杂志"
        case .receipt_memo:         return "小票"
        }
    }

    var isBrandSpecific: Bool {
        switch self {
        case .leica, .leica_mono, .leica_frame, .leica_compact, .leica_gallery,
             .leica_glass, .leica_white_space, .film_border, .gallery_frame,
             .fujifilm, .fuji_strip, .sony, .hasselblad, .ricoh_gr, .iphone:
            return true
        case .polaroid, .minimal, .minimal_dark, .date_stamp, .soft_journal,
             .clean_instagram, .magazine_cover, .receipt_memo:
            return false
        }
    }

    @ViewBuilder
    func makeView(image: UIImage, meta: PhotoMetadata) -> some View {
        switch self {
        case .leica:        LeicaTemplate(image: image, meta: meta)
        case .leica_mono:   LeicaMonoTemplate(image: image, meta: meta)
        case .leica_frame:  LeicaFrameTemplate(image: image, meta: meta)
        case .leica_compact: LeicaCompactTemplate(image: image, meta: meta)
        case .leica_gallery: LeicaGalleryTemplate(image: image, meta: meta)
        case .leica_glass:  LeicaGlassTemplate(image: image, meta: meta)
        case .leica_white_space: LeicaWhiteSpaceTemplate(image: image, meta: meta)
        case .fujifilm:     FujiTemplate(image: image, meta: meta)
        case .fuji_strip:   FujiFilmStripTemplate(image: image, meta: meta)
        case .sony:         SonyTemplate(image: image, meta: meta)
        case .hasselblad:   HasselbladTemplate(image: image, meta: meta)
        case .ricoh_gr:     RicohGRTemplate(image: image, meta: meta)
        case .iphone:       iPhoneNativeTemplate(image: image, meta: meta)
        case .polaroid:     PolaroidTemplate(image: image, meta: meta)
        case .minimal:      MinimalTemplate(image: image, meta: meta)
        case .minimal_dark: MinimalDarkTemplate(image: image, meta: meta)
        case .date_stamp:   DateStampTemplate(image: image, meta: meta)
        case .soft_journal: SoftJournalTemplate(image: image, meta: meta)
        case .clean_instagram: CleanInstagramTemplate(image: image, meta: meta)
        case .magazine_cover: MagazineCoverTemplate(image: image, meta: meta)
        case .receipt_memo:   ReceiptMemoTemplate(image: image, meta: meta)
        case .film_border:    FilmBorderTemplate(image: image, meta: meta)
        case .gallery_frame:  GalleryFrameTemplate(image: image, meta: meta)
        }
    }

    /// 根据照片品牌挑选最合适的默认模板。
    static func recommended(for meta: PhotoMetadata) -> WatermarkTemplate {
        .leica
    }

    static func resolved(initial: WatermarkTemplate?, for meta: PhotoMetadata) -> WatermarkTemplate {
        guard let initial, leicaTemplates.contains(initial) else { return .leica }
        return initial
    }
}
