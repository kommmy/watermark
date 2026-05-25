import SwiftUI

/// 一个水印模板就是一段 SwiftUI View。新增模板：
///   1. 在 Templates/ 下新建 `<Name>Template.swift`，实现一个 `View`
///   2. 在下面的 enum 里加一个 case
///   3. 在 `displayName` 和 `makeView(image:meta:)` switch 里补对应分支
///
/// 12 套模板的 id 与 docs/script.js TEMPLATES 一一对应，确保 Web 与 iOS 设计完全对齐。
enum WatermarkTemplate: String, CaseIterable, Identifiable, Hashable {
    case leica
    case leica_mono       // swiftlint:disable:this identifier_name
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

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .leica:        return "Leica White"
        case .leica_mono:   return "Leica Mono"
        case .fujifilm:     return "Fuji Dark"
        case .fuji_strip:   return "Fuji Film"
        case .sony:         return "Sony Alpha"
        case .hasselblad:   return "Hasselblad"
        case .ricoh_gr:     return "Ricoh GR"
        case .iphone:       return "iPhone Shot"
        case .polaroid:     return "Polaroid"
        case .minimal:      return "Minimal Light"
        case .minimal_dark: return "Minimal Dark"
        case .date_stamp:   return "Date Stamp"
        }
    }

    var brandLabel: String {
        switch self {
        case .leica, .leica_mono:   return "LEICA"
        case .fujifilm, .fuji_strip:return "FUJIFILM"
        case .sony:                 return "SONY"
        case .hasselblad:           return "HASSELBLAD"
        case .ricoh_gr:             return "RICOH"
        case .iphone:               return "iPhone"
        case .polaroid:             return "Polaroid"
        case .minimal, .minimal_dark: return "Minimal"
        case .date_stamp:           return "Kodak"
        }
    }

    @ViewBuilder
    func makeView(image: UIImage, meta: PhotoMetadata) -> some View {
        switch self {
        case .leica:        LeicaTemplate(image: image, meta: meta)
        case .leica_mono:   LeicaMonoTemplate(image: image, meta: meta)
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
        }
    }

    /// 根据照片品牌挑选最合适的默认模板。
    static func recommended(for meta: PhotoMetadata) -> WatermarkTemplate {
        switch meta.brand {
        case .leica:       return .leica
        case .fujifilm:    return .fujifilm
        case .sony:        return .sony
        case .hasselblad:  return .hasselblad
        case .apple:       return .iphone
        default:           return .minimal
        }
    }
}
