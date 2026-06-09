import SwiftUI

/// Per-slot photo transform inside its cell. `offset` is stored as a fraction of
/// the cell size so it survives the small-preview → full-export resolution jump;
/// `scale` (>= 1) is a zoom on top of the base `scaledToFill` that already covers
/// the cell.
struct CollageSlotEdit: Equatable {
    var scale: CGFloat = 1
    var offset: CGSize = .zero
}

/// Generic collage renderer: lays photos into a `CollageFrame`'s normalized cells,
/// honouring the shared `PuzzleOptions` (background / gap; aspect is fixed by the
/// caller). Used identically for the editor preview and the export pipeline.
///
/// When `onSlotChange` is supplied the cells become interactive (pinch to zoom,
/// drag to reposition); when it's nil the view renders statically for export.
struct CollageGridView: View {
    let frame: CollageFrame
    /// Positional slots; `nil` renders as an empty placeholder.
    let images: [UIImage?]
    let options: PuzzleOptions
    var edits: [CollageSlotEdit] = []
    var onSlotChange: ((Int, CollageSlotEdit) -> Void)? = nil
    var onSlotTap: ((Int) -> Void)? = nil

    /// `options.gap` is calibrated against this design width (≈ a phone's preview
    /// width). The actual gap scales with the rendered canvas, so the border keeps
    /// the same proportion on screen and in the high-res export.
    private static let gapDesignWidth: CGFloat = 360

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            // Both gap and corner radius scale with the canvas so they read the
            // same in the small preview and at full export resolution.
            let gap = options.gap / Self.gapDesignWidth * size.width
            let radius = min(size.width, size.height) * 0.018
            ZStack(alignment: .topLeading) {
                ForEach(Array(frame.cells.enumerated()), id: \.offset) { idx, cell in
                    let rect = CollageFrame.cellRect(cell, in: size, gap: gap)
                    CollageCell(
                        image: images[safe: idx] ?? nil,
                        cornerRadius: radius,
                        edit: edits[safe: idx] ?? CollageSlotEdit(),
                        onChange: onSlotChange.map { cb in { edit in cb(idx, edit) } },
                        onTap: onSlotTap.map { cb in { cb(idx) } }
                    )
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                }
            }
            .frame(width: size.width, height: size.height)
            .background(options.background.view)
        }
        .aspectRatio(options.aspect.value, contentMode: .fit)
    }
}

/// A single collage cell. Sizes the photo to fill the cell, clips it, and — when
/// interactive — lets the user pinch/drag it within the cell (gap-free, clamped).
private struct CollageCell: View {
    let image: UIImage?
    let cornerRadius: CGFloat
    let edit: CollageSlotEdit
    var onChange: ((CollageSlotEdit) -> Void)?
    var onTap: (() -> Void)?

    @GestureState private var pinch: CGFloat = 1
    @GestureState private var drag: CGSize = .zero

    private var interactive: Bool { onChange != nil }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let liveScale = edit.scale * (interactive ? pinch : 1)
            let offX = edit.offset.width * size.width + (interactive ? drag.width : 0)
            let offY = edit.offset.height * size.height + (interactive ? drag.height : 0)

            let cell = ZStack {
                AppTheme.Palette.surface
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width, height: size.height)
                        .scaleEffect(liveScale)
                        .offset(x: offX, y: offY)
                }
            }
            // Size THEN clip, so the photo can never spill outside the cell
            // (the previous bug clipped at the photo's natural size).
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

            if interactive, image != nil {
                cell.gesture(editGesture(size: size))
            } else if interactive {
                cell.onTapGesture { onTap?() }
            } else {
                cell
            }
        }
    }

    // MARK: - Gesture

    private func editGesture(size: CGSize) -> some Gesture {
        let magnify = MagnificationGesture()
            .updating($pinch) { value, state, _ in state = value }
            .onEnded { value in commit(scaleFactor: value, translation: .zero, size: size) }
        let pan = DragGesture()
            .updating($drag) { value, state, _ in state = value.translation }
            .onEnded { value in commit(scaleFactor: 1, translation: value.translation, size: size) }
        return magnify.simultaneously(with: pan)
    }

    private func commit(scaleFactor: CGFloat, translation: CGSize, size: CGSize) {
        var next = edit
        next.scale = min(max(edit.scale * scaleFactor, 1), 5)
        let px = CGSize(
            width:  edit.offset.width  * size.width  + translation.width,
            height: edit.offset.height * size.height + translation.height
        )
        let clamped = clampOffset(px, scale: next.scale, size: size)
        next.offset = CGSize(width: clamped.width / size.width, height: clamped.height / size.height)
        onChange?(next)
    }

    /// Clamp the photo offset (in points) so it always covers the cell — no gaps.
    private func clampOffset(_ off: CGSize, scale: CGFloat, size: CGSize) -> CGSize {
        guard let image, image.size.width > 0, image.size.height > 0 else { return .zero }
        let imgAspect = image.size.width / image.size.height
        let cellAspect = size.width / size.height
        var baseW = size.width
        var baseH = size.height
        if imgAspect > cellAspect {
            baseH = size.height
            baseW = size.height * imgAspect
        } else {
            baseW = size.width
            baseH = size.width / imgAspect
        }
        let slackX = max((baseW * scale - size.width) / 2, 0)
        let slackY = max((baseH * scale - size.height) / 2, 0)
        return CGSize(
            width:  min(max(off.width,  -slackX), slackX),
            height: min(max(off.height, -slackY), slackY)
        )
    }
}
