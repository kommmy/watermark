import SwiftUI

/// 一个水印模板就是一段 SwiftUI View。新增模板：
///   1. 在 Templates/ 下新建 `XxxTemplate.swift`，实现 `View`，参数 `(image: UIImage, meta: PhotoMetadata)`。
///   2. 在下面的 enum 里加一个 case。
///   3. 在 `makeView(image:meta:)` 里加一条 switch 分支即可。
enum WatermarkTemplate: String, CaseIterable, Identifiable, Hashable {
    case leica
    case fujifilm
    case sony
    case hasselblad
    case minimal

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .leica:       return "Leica"
        case .fujifilm:    return "Fujifilm"
        case .sony:        return "Sony"
        case .hasselblad:  return "Hasselblad"
        case .minimal:     return "Minimal"
        }
    }

    @ViewBuilder
    func makeView(image: UIImage, meta: PhotoMetadata) -> some View {
        switch self {
        case .leica:       LeicaTemplate(image: image, meta: meta)
        case .fujifilm:    FujiTemplate(image: image, meta: meta)
        case .sony:        SonyTemplate(image: image, meta: meta)
        case .hasselblad:  HasselbladTemplate(image: image, meta: meta)
        case .minimal:     MinimalTemplate(image: image, meta: meta)
        }
    }

    /// 根据照片品牌挑选一个最合适的默认模板。
    static func recommended(for meta: PhotoMetadata) -> WatermarkTemplate {
        switch meta.brand {
        case .leica:       return .leica
        case .fujifilm:    return .fujifilm
        case .sony:        return .sony
        case .hasselblad:  return .hasselblad
        default:           return .minimal
        }
    }
}
