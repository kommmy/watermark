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
        placeName: "上海",
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
        iso.map { "ISO\($0)" }
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

    /// 一行参数串："28mm  f/1.7  1/500s  ISO200"
    var paramsLine: String {
        [focalLengthText, apertureText, shutter, isoText]
            .compactMap { $0 }
            .joined(separator: "  ")
    }
}

/// 相机品牌识别，影响默认模板选择与 logo 显示。
enum CameraBrand: String {
    case leica, fujifilm, sony, hasselblad, canon, nikon, apple, other

    static func detect(make: String?, model: String?) -> CameraBrand {
        let s = ((make ?? "") + " " + (model ?? "")).uppercased()
        if s.contains("LEICA") { return .leica }
        if s.contains("FUJIFILM") || s.contains("FUJI") { return .fujifilm }
        if s.contains("SONY") || s.contains("ILCE") { return .sony }
        if s.contains("HASSELBLAD") { return .hasselblad }
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
        case .canon: return "Canon"
        case .nikon: return "Nikon"
        case .apple: return "iPhone"
        case .other: return ""
        }
    }
}
