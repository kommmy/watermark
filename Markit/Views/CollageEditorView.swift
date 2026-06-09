import SwiftUI
import PhotosUI

/// Collage editor: fill a `CollageFrame` with photos, pinch/drag each photo inside
/// its cell, tune ratio / background / gap, then save or share.
struct CollageEditorView: View {
    let frame: CollageFrame

    @State private var images: [UIImage?]
    @State private var edits: [CollageSlotEdit]
    @State private var options = PuzzleOptions()

    // One photos picker drives both flows. `pickerTargetSlot == nil` means
    // "fill all empty slots in order"; a non-nil value means "replace just that
    // slot". It is kept separate from `pickerPresented` so it survives the
    // picker's dismissal and is still readable when `pickerItems` changes.
    @State private var pickerPresented = false
    @State private var pickerTargetSlot: Int?
    @State private var pickerItems: [PhotosPickerItem] = []

    @State private var isLoadingImage = false
    @State private var isExporting = false
    @State private var toast: String?

    init(frame: CollageFrame) {
        self.frame = frame
        _images = State(initialValue: Array(repeating: nil, count: frame.slotCount))
        _edits = State(initialValue: Array(repeating: CollageSlotEdit(), count: frame.slotCount))
    }

    var body: some View {
        VStack(spacing: 0) {
            preview
            slotPickerBar
            optionsBar
            actionBar
        }
        .appBackground()
        .navigationTitle(L10n.collageTitle(slotCount: frame.slotCount))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.Palette.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("选择照片") { presentPicker(target: nil) }
                    .disabled(isLoadingImage || isExporting)
            }
        }
        .photosPicker(
            isPresented: $pickerPresented,
            selection: $pickerItems,
            maxSelectionCount: pickerTargetSlot == nil ? frame.slotCount : 1,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: pickerItems) { items in
            guard !items.isEmpty else { return }
            let target = pickerTargetSlot
            Task { await handlePicked(items, target: target) }
        }
        .overlay(alignment: .top) {
            if let toast {
                Text(toast)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Capsule().fill(Color.black.opacity(0.85)))
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .overlay {
            if isLoadingImage { LoadingOverlay(message: "正在载入照片...") }
        }
    }

    // MARK: - Preview

    // No ScrollView here on purpose: it would steal the drag gesture used to
    // reposition a photo inside its cell. The collage aspect-fits the area.
    private var preview: some View {
        VStack(spacing: 10) {
            CollageGridView(
                frame: frame,
                images: images,
                options: options,
                edits: edits,
                onSlotChange: { idx, edit in
                    if idx < edits.count { edits[idx] = edit }
                },
                onSlotTap: { idx in presentPicker(target: idx) }
            )

            Text("双指缩放 · 拖动可调整框内照片")
                .font(AppTheme.Font.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Palette.previewBackdrop)
    }

    // MARK: - Slot picker bar

    private var slotPickerBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(0..<frame.slotCount, id: \.self) { idx in
                    Button {
                        presentPicker(target: idx)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(AppTheme.Palette.surface)
                                .frame(width: 56, height: 56)
                            if let img = images[idx] {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            } else {
                                VStack(spacing: 2) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("\(idx + 1)")
                                        .font(AppTheme.Font.caption)
                                }
                                .foregroundColor(AppTheme.Palette.textSecondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isLoadingImage || isExporting)
                    .opacity(isLoadingImage ? 0.55 : 1)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    // MARK: - Options bar (ratio / background / gap)

    private var optionsBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(PuzzleOptions.Ratio.allCases) { ratio in
                        chip(label: ratio.displayName, selected: ratio == options.aspect) {
                            options.aspect = ratio
                        }
                    }
                    Divider().frame(height: 18).padding(.horizontal, 2)
                    ForEach(PuzzleOptions.Background.allCases) { bg in
                        chip(label: bg.displayName, selected: bg == options.background) {
                            options.background = bg
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            HStack(spacing: 10) {
                Image(systemName: "square.dashed")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.Palette.textSecondary)
                Slider(value: $options.gap, in: 0...28)
                    .tint(.black)
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
        .background(AppTheme.Palette.background)
    }

    @ViewBuilder
    private func chip(label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(L10n.text(label))
                .font(AppTheme.Font.small.weight(.semibold))
                .foregroundColor(selected ? .black : AppTheme.Palette.textPrimary)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Capsule().fill(selected ? Color.white : AppTheme.Palette.surface))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Action bar

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                Task { await share() }
            } label: {
                actionLabel(title: "分享", system: "square.and.arrow.up", filled: false)
            }
            .disabled(isExporting || !isComplete)

            Button {
                Task { await save() }
            } label: {
                actionLabel(
                    title: actionTitle,
                    system: "square.and.arrow.down",
                    filled: true
                )
            }
            .disabled(isExporting || !isComplete)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private func actionLabel(title: String, system: String, filled: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: system)
            Text(L10n.text(title)).font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(filled ? Color.white : Color.clear)
        .foregroundColor(filled ? .black : .white)
        .overlay(Capsule().stroke(Color.white.opacity(filled ? 0 : 0.25), lineWidth: 1))
        .clipShape(Capsule())
    }

    // MARK: - Helpers

    private var filledCount: Int { images.compactMap { $0 }.count }
    private var isComplete: Bool { filledCount == frame.slotCount }
    private var actionTitle: String {
        if isExporting { return "处理中..." }
        if !isComplete { return L10n.remainingPhotos(frame.slotCount - filledCount) }
        return "保存到相册"
    }

    private func presentPicker(target: Int?) {
        guard !isLoadingImage, !isExporting else { return }
        pickerTargetSlot = target
        pickerPresented = true
    }

    /// `target == nil` → fill empty slots in order; otherwise replace one slot.
    private func handlePicked(_ items: [PhotosPickerItem], target: Int?) async {
        isLoadingImage = true
        defer {
            isLoadingImage = false
            pickerItems = []
            pickerTargetSlot = nil
        }

        if let slot = target {
            if let first = items.first, let img = await loadImage(first), slot < images.count {
                images[slot] = img
                edits[slot] = CollageSlotEdit()   // reset zoom/pan for the new photo
            }
            return
        }

        // Fill empty slots first, in order; if none empty, refill from the start.
        var targets = (0..<frame.slotCount).filter { images[$0] == nil }
        if targets.isEmpty { targets = Array(0..<frame.slotCount) }
        for (item, slot) in zip(items, targets) {
            if let img = await loadImage(item) {
                images[slot] = img
                edits[slot] = CollageSlotEdit()
            }
        }
    }

    private func loadImage(_ item: PhotosPickerItem) async -> UIImage? {
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let img = UIImage(data: data) else {
                showToast("无法读取照片")
                return nil
            }
            return img
        } catch {
            showToast(error.localizedDescription)
            return nil
        }
    }

    private func save() async {
        guard let out = renderOutput() else { return }
        do {
            try await PhotoSaver.save(out)
            showToast("已保存到相册")
        } catch {
            showToast(error.localizedDescription)
        }
    }

    private func share() async {
        guard let out = renderOutput() else { return }
        presentShareSheet(image: out)
    }

    private func renderOutput() -> UIImage? {
        isExporting = true
        defer { isExporting = false }
        // Export only when every slot is filled, so `filled` stays index-aligned
        // with `edits` (and the frame's cells).
        let filled = images.compactMap { $0 }
        guard let out = CollageComposer.render(
            images: filled, frame: frame, options: options, edits: edits
        ) else {
            showToast("渲染失败")
            return nil
        }
        return out
    }

    private func presentShareSheet(image: UIImage) {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        guard let root = (windows.first(where: \.isKeyWindow) ?? windows.first)?.rootViewController
        else { return }
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        var top = root
        while let presented = top.presentedViewController { top = presented }
        top.present(vc, animated: true)
    }

    private func showToast(_ message: String) {
        withAnimation { toast = L10n.text(message) }
        Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            withAnimation { toast = nil }
        }
    }
}

struct CollageEditorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CollageEditorView(frame: CollageFrame.all[6])
        }
    }
}
