import Foundation
import CoreLocation
import CoreGraphics

/// 从 EXIF 中抽出的强类型摘要，水印模板的统一输入。
struct PhotoMetadata {
    var cameraMake: String?
    var cameraModel: String?
    var lensMake: String?
    var lensModel: String?
    var focalLength: Double?
    var focalLength35mm: Int?
    var aperture: Double?
    var shutter: String?
    var iso: Int?
    var captureDate: Date?
    var coordinate: CLLocationCoordinate2D?
    var placeName: String?
    /// 用户手写的点评/标题（色彩漫步模板用）。nil 时模板回退到艺术日期。
    var caption: String?
    var pixelSize: CGSize

    static let empty = PhotoMetadata(pixelSize: .zero)

    /// 用于演示/预览的伪数据，方便在 Xcode Preview 中预览模板。
    static let preview = PhotoMetadata(
        cameraMake: "LEICA CAMERA AG",
        cameraModel: "Q3",
        lensMake: "LEICA",
        lensModel: "SUMMICRON 28 f/1.7 ASPH.",
        focalLength: 28,
        focalLength35mm: 28,
        aperture: 1.7,
        shutter: "1/500s",
        iso: 200,
        captureDate: Date(),
        coordinate: CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737),
        placeName: L10n.text("上海"),
        pixelSize: CGSize(width: 6000, height: 4000)
    )

    var brand: CameraBrand {
        CameraBrand.detect(make: cameraMake, model: cameraModel)
    }

    var apertureText: String? {
        guard let aperture else { return nil }
        return String(format: "f/%g", aperture)
    }

    var focalLengthText: String? {
        if let f = focalLength35mm { return "\(f)mm" }
        if let f = focalLength { return String(format: "%gmm", f) }
        return nil
    }

    var isoText: String? {
        iso.map { "ISO \($0)" }
    }

    var dateText: String? {
        guard let date = captureDate else { return nil }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy.MM.dd HH:mm"
        return fmt.string(from: date)
    }

    var coordinateText: String? {
        guard let c = coordinate else { return nil }
        return String(format: "%.4f°, %.4f°", c.latitude, c.longitude)
    }

    /// 艺术风格日期，如 "January 29, 2026"。读不到拍摄日期则用今天。
    var artisticDate: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US")
        fmt.dateFormat = "MMMM d, yyyy"
        return fmt.string(from: captureDate ?? Date())
    }

    /// 色彩漫步模板展示的文字：优先用户输入的点评，否则用艺术日期。
    var colorWalkText: String {
        if let c = caption?.trimmingCharacters(in: .whitespacesAndNewlines), !c.isEmpty { return c }
        return artisticDate
    }

    var brandDisplayName: String {
        if !brand.displayName.isEmpty { return brand.displayName }
        if let make = cameraMake?.trimmedNonEmpty { return make }
        return L10n.text("未知品牌")
    }

    var cameraDisplayName: String {
        if let model = cameraModel?.trimmedNonEmpty { return model }
        if let make = cameraMake?.trimmedNonEmpty { return make }
        if !brand.displayName.isEmpty { return brand.displayName }
        return "M11"
    }

    // Returns empty string when lens info is unavailable — templates skip display rather than show ugly fallback.
    var lensDisplayName: String {
        lensModel?.trimmedNonEmpty ?? ""
    }

    var exposureSummary: String {
        [apertureText, shutter, isoText].compactMap { $0 }.joined(separator: "  ")
    }

    /// 水印中精简展示的一行曝光参数：只保留光圈、快门、ISO，避免和镜头/焦段重复。
    var compactExposureLine: String {
        let parts = [apertureText, shutter, isoText].compactMap { $0 }
        if !parts.isEmpty { return parts.joined(separator: "  ") }
        return "f/1.4  1/250s  ISO 200"
    }

    var hasCameraIdentity: Bool {
        brand != .other || cameraMake?.trimmedNonEmpty != nil || cameraModel?.trimmedNonEmpty != nil
    }

    /// 一行参数串："35mm  f/1.4  1/250s  ISO 200"。读不到 EXIF 时填充徕卡风格默认值。
    var paramsLine: String {
        let parts = [focalLengthText, apertureText, shutter, isoText].compactMap { $0 }
        if !parts.isEmpty { return parts.joined(separator: "  ") }
        // Auto-fill: return brand-appropriate placeholder so the frame always looks complete
        switch brand {
        case .leica:       return "35mm  f/1.4  1/250s  ISO 200"
        case .fujifilm:    return "23mm  f/2  1/500s  ISO 400"
        case .ricoh:       return "28mm  f/2.8  1/125s  ISO 800"
        case .sony:        return "50mm  f/1.8  1/320s  ISO 100"
        case .hasselblad:  return "80mm  f/2.8  1/500s  ISO 200"
        default:           return "50mm  f/2  1/250s  ISO 200"
        }
    }

    /// 日期，读不到时返回今天（确保边框始终有内容）。
    var paramsDate: String {
        if let d = dateText { return d }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy.MM.dd"
        return fmt.string(from: Date())
    }
}

/// 相机品牌识别，影响默认模板选择与 logo 显示。
enum CameraBrand: String {
    case leica, fujifilm, sony, hasselblad, ricoh, canon, nikon, apple, other

    static func detect(make: String?, model: String?) -> CameraBrand {
        let s = ((make ?? "") + " " + (model ?? "")).uppercased()
        if s.contains("LEICA") { return .leica }
        if s.contains("FUJIFILM") || s.contains("FUJI") { return .fujifilm }
        if s.contains("SONY") || s.contains("ILCE") { return .sony }
        if s.contains("HASSELBLAD") { return .hasselblad }
        if s.contains("RICOH") || s.contains("GR III") || s.contains("GR3") { return .ricoh }
        if s.contains("CANON") { return .canon }
        if s.contains("NIKON") { return .nikon }
        if s.contains("APPLE") || s.contains("IPHONE") { return .apple }
        return .other
    }

    var displayName: String {
        switch self {
        case .leica: return "LEICA"
        case .fujifilm: return "FUJIFILM"
        case .sony: return "SONY"
        case .hasselblad: return "HASSELBLAD"
        case .ricoh: return "RICOH"
        case .canon: return "Canon"
        case .nikon: return "Nikon"
        case .apple: return "iPhone"
        case .other: return ""
        }
    }

    var hasDedicatedTemplate: Bool {
        switch self {
        case .leica, .fujifilm, .sony, .hasselblad, .ricoh, .apple:
            return true
        case .canon, .nikon, .other:
            return false
        }
    }
}

private extension String {
    var trimmedNonEmpty: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
