import SwiftUI
import UIKit

// Same idea as ImageComposer, but for the puzzle module: takes N input images,
// renders them inside a chosen layout + options via SwiftUI ImageRenderer, and
// returns one UIImage at the requested long-edge pixel count.
@MainActor
enum PuzzleComposer {

    static func render(
        images: [UIImage],
        layout: PuzzleLayout,
        options: PuzzleOptions,
        maxLongEdge: CGFloat = 4096
    ) -> UIImage? {
        guard !images.isEmpty else { return nil }

        // Target canvas size = longest edge clamped to maxLongEdge, preserving the chosen aspect ratio.
        // For tall ratios we cap by height; for wide ratios we cap by width.
        let aspect = options.aspect.value          // width / height
        let (canvasW, canvasH): (CGFloat, CGFloat)
        if aspect >= 1 {
            canvasW = maxLongEdge
            canvasH = floor(canvasW / aspect)
        } else {
            canvasH = maxLongEdge
            canvasW = floor(canvasH * aspect)
        }

        // Pre-downscale each input image so we don't OOM with 4 raw inputs.
        // Use the larger of (canvas long edge / sqrt(slots), 2048) as a safe per-slot cap.
        let perSlotCap = max(canvasW, canvasH) / max(CGFloat(layout.slotCount).squareRoot(), 1)
        let downsampled: [UIImage] = images.prefix(layout.slotCount).map { img in
            img.resized(toWidth: perSlotCap) ?? img
        }

        let content = layout
            .makeView(images: downsampled, options: options)
            .frame(width: canvasW, height: canvasH)
            .environment(\.colorScheme, .light)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 1.0
        renderer.isOpaque = true
        renderer.proposedSize = ProposedViewSize(width: canvasW, height: canvasH)
        return renderer.uiImage
    }
}
