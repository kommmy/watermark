import SwiftUI
import UIKit

/// 一张照片提取出的配色：主色块 + 其上可读的文字色。
struct PhotoPalette {
    let main: Color        // 照片中最具代表性的颜色（色卡背景）
    let onMain: Color      // 压在主色上仍清晰的文字色

    static let fallback = PhotoPalette(
        main: Color(red: 0.45, green: 0.5, blue: 0.42),
        onMain: .white
    )
}

extension UIImage {

    /// 提取照片的「主色」并配好文字色。
    ///
    /// 做法：把图缩成小图 → 每像素按通道量化分桶（5bit/通道）→ 统计每桶像素数 →
    /// 取得分最高的桶，用桶内均值作为代表色。
    /// 评分在「出现次数」基础上对**有彩度**的颜色略微加权、对近白/近黑/近灰降权，
    /// 这样色卡更接近肉眼记得的「这张照片的颜色」，而不是大片惨白的背景。
    func colorWalkPalette(sampleEdge: CGFloat = 48) -> PhotoPalette {
        guard let main = dominantColor(sampleEdge: sampleEdge) else { return .fallback }
        return PhotoPalette(main: Color(uiColor: main), onMain: Self.readableText(on: main))
    }

    /// 返回量化直方图加权后的代表色（UIColor）。失败返回 nil。
    func dominantColor(sampleEdge: CGFloat = 48) -> UIColor? {
        guard let cg = cgImage, cg.width > 0, cg.height > 0 else { return nil }

        let w = max(1, Int(sampleEdge))
        let h = max(1, Int(sampleEdge * CGFloat(cg.height) / CGFloat(cg.width)))
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * w
        var data = [UInt8](repeating: 0, count: bytesPerRow * h)
        let space = CGColorSpaceCreateDeviceRGB()
        let info = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let ctx = CGContext(
            data: &data, width: w, height: h, bitsPerComponent: 8,
            bytesPerRow: bytesPerRow, space: space, bitmapInfo: info
        ) else { return nil }
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))

        // 桶 key = 每通道高 5 位拼接；同时累加桶内 RGB 之和以便取均值。
        var counts: [Int: Int] = [:]
        var sums: [Int: (r: Int, g: Int, b: Int)] = [:]
        var i = 0
        while i < data.count {
            if data[i + 3] < 16 { i += bytesPerPixel; continue }   // 跳过近透明
            let r = Int(data[i]), g = Int(data[i + 1]), b = Int(data[i + 2])
            let key = ((r >> 3) << 10) | ((g >> 3) << 5) | (b >> 3)
            counts[key, default: 0] += 1
            var s = sums[key] ?? (0, 0, 0)
            s.r += r; s.g += g; s.b += b
            sums[key] = s
            i += bytesPerPixel
        }
        guard !counts.isEmpty else { return nil }

        var bestKey = -1
        var bestScore = -1.0
        for (key, count) in counts {
            guard let s = sums[key] else { continue }
            let r = CGFloat(s.r) / CGFloat(count) / 255
            let g = CGFloat(s.g) / CGFloat(count) / 255
            let b = CGFloat(s.b) / CGFloat(count) / 255
            let hi = max(r, g, b), lo = min(r, g, b)
            let saturation = hi > 0 ? (hi - lo) / hi : 0
            // 基础分 = 出现次数；彩度高的略加权。
            var score = Double(count) * (0.4 + 0.6 * Double(saturation))
            // 近白/近黑/近灰降权，避免整块色卡发白发灰。
            if (hi > 0.93 && saturation < 0.08) || hi < 0.07 { score *= 0.25 }
            if score > bestScore { bestScore = score; bestKey = key }
        }
        guard bestKey >= 0, let s = sums[bestKey], let n = counts[bestKey], n > 0 else { return nil }
        return UIColor(
            red: CGFloat(s.r) / CGFloat(n) / 255,
            green: CGFloat(s.g) / CGFloat(n) / 255,
            blue: CGFloat(s.b) / CGFloat(n) / 255,
            alpha: 1
        )
    }

    /// 主色之上可读的文字色：亮背景给深字，暗背景给白字。
    private static func readableText(on color: UIColor) -> Color {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.62 ? Color.black.opacity(0.80) : Color.white.opacity(0.95)
    }
}
