import Foundation
import ImageIO
import CoreLocation
import UniformTypeIdentifiers

/// 用 ImageIO 解析照片二进制中的 EXIF / TIFF / GPS 字典，输出强类型 `PhotoMetadata`。
enum ExifReader {

    /// 从原始图片字节中读取元数据。任何字段读不到都返回 nil，不会抛错。
    static func read(from data: Data) -> PhotoMetadata {
        guard
            let src = CGImageSourceCreateWithData(data as CFData, nil),
            let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any]
        else {
            return .empty
        }

        let tiff = props[kCGImagePropertyTIFFDictionary] as? [CFString: Any] ?? [:]
        let exif = props[kCGImagePropertyExifDictionary] as? [CFString: Any] ?? [:]
        let exifAux = props[kCGImagePropertyExifAuxDictionary] as? [CFString: Any] ?? [:]
        let gps = props[kCGImagePropertyGPSDictionary] as? [CFString: Any] ?? [:]

        let width = (props[kCGImagePropertyPixelWidth] as? Double) ?? 0
        let height = (props[kCGImagePropertyPixelHeight] as? Double) ?? 0

        let make = tiff[kCGImagePropertyTIFFMake] as? String
        let model = tiff[kCGImagePropertyTIFFModel] as? String

        let lensMake = (exif[kCGImagePropertyExifLensMake] as? String)
            ?? (exifAux["LensMake" as CFString] as? String)
        let lensModel = (exif[kCGImagePropertyExifLensModel] as? String)
            ?? (exifAux["LensModel" as CFString] as? String)

        let focal = exif[kCGImagePropertyExifFocalLength] as? Double
        let focal35: Int? = {
            if let v = exif[kCGImagePropertyExifFocalLenIn35mmFilm] as? Int { return v }
            if let v = exif[kCGImagePropertyExifFocalLenIn35mmFilm] as? Double { return Int(v) }
            return nil
        }()

        let fnumber = exif[kCGImagePropertyExifFNumber] as? Double
        let exposure = exif[kCGImagePropertyExifExposureTime] as? Double
        let iso: Int? = {
            if let arr = exif[kCGImagePropertyExifISOSpeedRatings] as? [Int] { return arr.first }
            if let v = exif[kCGImagePropertyExifISOSpeedRatings] as? Int { return v }
            return nil
        }()

        let dateStr = (exif[kCGImagePropertyExifDateTimeOriginal] as? String)
            ?? (tiff[kCGImagePropertyTIFFDateTime] as? String)
        let date = dateStr.flatMap(parseExifDate)

        let coord = parseGPS(gps)

        return PhotoMetadata(
            cameraMake: make,
            cameraModel: model,
            lensMake: lensMake,
            lensModel: lensModel,
            focalLength: focal,
            focalLength35mm: focal35,
            aperture: fnumber,
            shutter: exposure.flatMap(formatShutter),
            iso: iso,
            captureDate: date,
            coordinate: coord,
            placeName: nil,
            pixelSize: CGSize(width: width, height: height)
        )
    }

    // MARK: - Formatting

    /// EXIF 中 ExposureTime 是浮点秒数，>=1 显示 "1.3s"，否则显示 "1/250s"。
    private static func formatShutter(_ seconds: Double) -> String {
        guard seconds > 0 else { return "" }
        if seconds >= 1 {
            return String(format: "%gs", seconds)
        }
        let denom = max(1, Int((1.0 / seconds).rounded()))
        return "1/\(denom)s"
    }

    private static let exifDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy:MM:dd HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        return f
    }()

    private static func parseExifDate(_ s: String) -> Date? {
        exifDateFormatter.date(from: s)
    }

    private static func parseGPS(_ gps: [CFString: Any]) -> CLLocationCoordinate2D? {
        guard
            let lat = gps[kCGImagePropertyGPSLatitude] as? Double,
            let lon = gps[kCGImagePropertyGPSLongitude] as? Double
        else { return nil }
        let latRef = (gps[kCGImagePropertyGPSLatitudeRef] as? String) ?? "N"
        let lonRef = (gps[kCGImagePropertyGPSLongitudeRef] as? String) ?? "E"
        let signedLat = latRef == "S" ? -lat : lat
        let signedLon = lonRef == "W" ? -lon : lon
        guard CLLocationCoordinate2DIsValid(
            CLLocationCoordinate2D(latitude: signedLat, longitude: signedLon)
        ) else { return nil }
        return CLLocationCoordinate2D(latitude: signedLat, longitude: signedLon)
    }
}
