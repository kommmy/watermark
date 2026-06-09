import SwiftUI
import UIKit

/// Renders a `CollageFrame` + photos into one exported `UIImage`, mirroring
/// `PuzzleComposer`: target canvas is the chosen aspect clamped to `maxLongEdge`,
/// and each input is pre-downscaled to roughly its cell size to avoid OOM.
@MainActor
enum CollageComposer {

    static func render(
        images: [UIImage],
        frame: CollageFrame,
        options: PuzzleOptions,
        edits: [CollageSlotEdit] = [],
        maxLongEdge: CGFloat = 4096
    ) -> UIImage? {
        guard !images.isEmpty else { return nil }

        let aspect = options.aspect.value          // width / height
        let canvasW: CGFloat
        let canvasH: CGFloat
        if aspect >= 1 {
            canvasW = maxLongEdge
            canvasH = floor(canvasW / aspect)
        } else {
            canvasH = maxLongEdge
            canvasW = floor(canvasH * aspect)
        }

        // Pre-downscale each input to its cell's pixel footprint (with a little
        // headroom for scaledToFill cropping) so 6 raw photos don't blow memory.
        let downsampled: [UIImage?] = images.prefix(frame.slotCount).enumerated().map { idx, img in
            let cell = frame.cells[safe: idx] ?? CGRect(x: 0, y: 0, width: 1, height: 1)
            // Keep zoomed-in slots sharp: allow up to 3× the cell footprint.
            let zoom = min(max(edits[safe: idx]?.scale ?? 1, 1), 3)
            let cap = max(cell.width * canvasW, cell.height * canvasH) * 1.4 * zoom
            return img.resized(toWidth: max(cap, 256)) ?? img
        }

        let content = CollageGridView(frame: frame, images: downsampled, options: options, edits: edits)
            .frame(width: canvasW, height: canvasH)
            .environment(\.colorScheme, .light)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 1.0
        renderer.isOpaque = true
        renderer.proposedSize = ProposedViewSize(width: canvasW, height: canvasH)
        return renderer.uiImage
    }
}
