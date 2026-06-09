import SwiftUI
import CoreGraphics

/// A data-driven photo collage frame.
///
/// A frame is just a set of normalized cell rectangles (origin top-left, both
/// axes in 0...1) that tile the canvas. Rendering (`CollageGridView`), gallery
/// thumbnails (`CollageFrameThumbnail`), and the editor all derive from this one
/// description — so adding a new shape is a single entry in `all`, no new View.
struct CollageFrame: Identifiable, Hashable {
    let id: String
    let cells: [CGRect]

    var slotCount: Int { cells.count }

    /// Pixel rect for a normalized cell inside a `size` canvas, applying a
    /// uniform `gap` both between cells and around the outer edge. Edges that sit
    /// on the canvas border (0 or 1) get a full `gap`; interior edges share a
    /// `gap/2` with their neighbour, so every seam ends up the same width.
    static func cellRect(_ r: CGRect, in size: CGSize, gap: CGFloat) -> CGRect {
        let eps: CGFloat = 0.0001
        let left   = r.minX <= eps       ? gap : gap / 2
        let top    = r.minY <= eps       ? gap : gap / 2
        let right  = r.maxX >= 1 - eps   ? gap : gap / 2
        let bottom = r.maxY >= 1 - eps   ? gap : gap / 2
        return CGRect(
            x: r.minX * size.width + left,
            y: r.minY * size.height + top,
            width:  max(r.width  * size.width  - left - right,  1),
            height: max(r.height * size.height - top  - bottom, 1)
        )
    }
}

// MARK: - Catalog

extension CollageFrame {

    /// All frames, ordered by photo count. The gallery groups on `slotCount`.
    static let all: [CollageFrame] = [
        // 2 photos
        CollageFrame(id: "2-h",          cells: cols(2)),
        CollageFrame(id: "2-v",          cells: rows(2)),
        CollageFrame(id: "2-h-62",       cells: [r(0, 0, 0.62, 1), r(0.62, 0, 0.38, 1)]),
        CollageFrame(id: "2-v-62",       cells: [r(0, 0, 1, 0.62), r(0, 0.62, 1, 0.38)]),

        // 3 photos
        CollageFrame(id: "3-h",          cells: cols(3)),
        CollageFrame(id: "3-v",          cells: rows(3)),
        CollageFrame(id: "3-left-2",     cells: [r(0, 0, 0.6, 1), r(0.6, 0, 0.4, 0.5), r(0.6, 0.5, 0.4, 0.5)]),
        CollageFrame(id: "3-right-2",    cells: [r(0, 0, 0.4, 0.5), r(0, 0.5, 0.4, 0.5), r(0.4, 0, 0.6, 1)]),
        CollageFrame(id: "3-top-2",      cells: [r(0, 0, 1, 0.6), r(0, 0.6, 0.5, 0.4), r(0.5, 0.6, 0.5, 0.4)]),
        CollageFrame(id: "3-bottom-2",   cells: [r(0, 0, 0.5, 0.4), r(0.5, 0, 0.5, 0.4), r(0, 0.4, 1, 0.6)]),

        // 4 photos
        CollageFrame(id: "4-grid",       cells: grid(2, 2)),
        CollageFrame(id: "4-h",          cells: cols(4)),
        CollageFrame(id: "4-v",          cells: rows(4)),
        CollageFrame(id: "4-left-3",     cells: [r(0, 0, 0.55, 1)] + colsIn(rect: r(0.55, 0, 0.45, 1), rows: 3)),
        CollageFrame(id: "4-top-3",      cells: [r(0, 0, 1, 0.55)] + rowAcross(rect: r(0, 0.55, 1, 0.45), count: 3)),

        // 5 photos
        CollageFrame(id: "5-top2-bot3",  cells: [r(0, 0, 0.5, 0.5), r(0.5, 0, 0.5, 0.5)]
            + rowAcross(rect: r(0, 0.5, 1, 0.5), count: 3)),
        CollageFrame(id: "5-left-4",     cells: [r(0, 0, 0.5, 1)] + grid(2, 2, in: r(0.5, 0, 0.5, 1))),
        CollageFrame(id: "5-top-4",      cells: [r(0, 0, 1, 0.6)] + rowAcross(rect: r(0, 0.6, 1, 0.4), count: 4)),

        // 6 photos
        CollageFrame(id: "6-3x2",        cells: grid(3, 2)),
        CollageFrame(id: "6-2x3",        cells: grid(2, 3))
    ]

    /// Frames grouped by photo count, ascending — for the gallery's sections.
    static var groups: [(count: Int, frames: [CollageFrame])] {
        Dictionary(grouping: all, by: \.slotCount)
            .sorted { $0.key < $1.key }
            .map { (count: $0.key, frames: $0.value) }
    }

    static func frame(id: String) -> CollageFrame? {
        all.first { $0.id == id }
    }
}

// MARK: - Builders

private extension CollageFrame {
    static func r(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
        CGRect(x: x, y: y, width: w, height: h)
    }

    /// `n` equal full-height columns.
    static func cols(_ n: Int) -> [CGRect] {
        (0..<n).map { r(CGFloat($0) / CGFloat(n), 0, 1 / CGFloat(n), 1) }
    }

    /// `n` equal full-width rows.
    static func rows(_ n: Int) -> [CGRect] {
        (0..<n).map { r(0, CGFloat($0) / CGFloat(n), 1, 1 / CGFloat(n)) }
    }

    /// `c` columns × `rs` rows grid over the unit square.
    static func grid(_ c: Int, _ rs: Int) -> [CGRect] {
        grid(c, rs, in: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    /// `c` columns × `rs` rows grid mapped inside `rect`.
    static func grid(_ c: Int, _ rs: Int, in rect: CGRect) -> [CGRect] {
        var out: [CGRect] = []
        for row in 0..<rs {
            for col in 0..<c {
                out.append(r(
                    rect.minX + CGFloat(col) / CGFloat(c) * rect.width,
                    rect.minY + CGFloat(row) / CGFloat(rs) * rect.height,
                    rect.width / CGFloat(c),
                    rect.height / CGFloat(rs)
                ))
            }
        }
        return out
    }

    /// `rows` stacked rows filling `rect` vertically.
    static func colsIn(rect: CGRect, rows: Int) -> [CGRect] {
        (0..<rows).map {
            r(rect.minX,
              rect.minY + CGFloat($0) / CGFloat(rows) * rect.height,
              rect.width,
              rect.height / CGFloat(rows))
        }
    }

    /// `count` side-by-side columns filling `rect` horizontally.
    static func rowAcross(rect: CGRect, count: Int) -> [CGRect] {
        (0..<count).map {
            r(rect.minX + CGFloat($0) / CGFloat(count) * rect.width,
              rect.minY,
              rect.width / CGFloat(count),
              rect.height)
        }
    }
}
