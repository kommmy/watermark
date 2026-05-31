import Foundation
import CoreLocation

/// GPS 反查城市名（可选，不开 NSLocationWhenInUseUsageDescription 也能用，
/// CLGeocoder 走的是 Apple 网络服务而非定位权限）。
///
/// 失败时返回 nil，调用方应做兜底处理。
enum PlaceLookup {

    private static let geocoder = CLGeocoder()

    static func reverse(_ coord: CLLocationCoordinate2D) async -> String? {
        let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(
                loc, preferredLocale: Locale(identifier: "zh_CN")
            )
            guard let p = placemarks.first else { return nil }
            // 优先：城市 + 区/县；次选：行政区；最后：国家
            let city = p.locality ?? p.administrativeArea
            let area = p.subLocality
            switch (city, area) {
            case let (c?, a?): return "\(c)·\(a)"
            case let (c?, nil): return c
            case let (nil, a?): return a
            case (nil, nil): return p.country
            }
        } catch {
            return nil
        }
    }
}
