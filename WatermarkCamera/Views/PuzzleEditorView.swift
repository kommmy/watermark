import SwiftUI
import PhotosUI

// Puzzle editor: live preview of the chosen layout + toolbar to switch layout,
// ratio, background, caption, and to re-pick any slot image.
struct PuzzleEditorView: View {
    let layout: PuzzleLayout

    @State private var currentLayout: PuzzleLayout
    @State private var images: [UIImage?] = []
    @State private var options: PuzzleOptions = PuzzleOptions()

    @State private var pickerSlot: Int? = nil
    @State private var pickerItem: PhotosPickerItem?
    @State private var isExporting = false
    @State private var toast: String?

    init(layout: PuzzleLayout) {
        self.layout = layout
        self._currentLayout = State(initialValue: layout)
        let empty: [UIImage?] = Array(repeating: nil, count: max(layout.slotCount, 4))
        self._images = State(initialValue: empty)
    }

    var body: some View {
        VStack(spacing: 0) {
            preview
            slotPickerBar
            optionsBar
            actionBar
        }
        .appBackground()
        .navigationTitle(currentLayout.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.Palette.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .photosPicker(
            isPresented: Binding(
                get: { pickerSlot != nil },
                set: { if !$0 { pickerSlot = nil } }
            ),
            selection: $pickerItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: pickerItem) { newItem in
            guard let newItem, let slot = pickerSlot else { return }
            Task { await loadImage(newItem, into: slot) }
        }
        .onChange(of: currentLayout) { newLayout in
            if images.count < newLayout.slotCount {
                let extra: [UIImage?] = Array(repeating: nil, count: newLayout.slotCount - images.count)
                images.append(contentsOf: extra)
            }
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
    }

    // MARK: - Preview

    private var preview: some View {
        ScrollView {
            currentLayout
                .makeView(images: images.compactMap { $0 }, options: options)
                .frame(maxWidth: .infinity)
                .padding(20)
        }
        .background(Color.black)
    }

    // MARK: - Slot picker bar (lets user pick each slot's image)

    private var slotPickerBar: some View {
        HStack(spacing: 10) {
            ForEach(0..<currentLayout.slotCount, id: \.self) { idx in
                Button {
                    pickerSlot = idx
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
                                Text("Slot \(idx + 1)")
                                    .font(AppTheme.Font.caption)
                            }
                            .foregroundColor(AppTheme.Palette.textSecondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    // MARK: - Options bar (layout / ratio / background / caption)

    private var optionsBar: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
                optionsRow(title: "Layout") {
                    HStack(spacing: 6) {
                        ForEach(PuzzleLayout.allCases) { lyt in
                            chip(label: lyt.displayName, selected: lyt == currentLayout) {
                                currentLayout = lyt
                            }
                        }
                    }
                }
                optionsRow(title: "Ratio") {
                    HStack(spacing: 6) {
                        ForEach(PuzzleOptions.Ratio.allCases) { ratio in
                            chip(label: ratio.displayName, selected: ratio == options.aspect) {
                                options.aspect = ratio
                            }
                        }
                    }
                }
                optionsRow(title: "Background") {
                    HStack(spacing: 8) {
                        ForEach(PuzzleOptions.Background.allCases) { bg in
                            Button { options.background = bg } label: {
                                Circle()
                                    .fill(swatchColor(for: bg))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle().stroke(
                                            options.background == bg ? Color.white : Color.white.opacity(0.15),
                                            lineWidth: options.background == bg ? 2 : 1
                                        )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Caption")
                        .font(AppTheme.Font.caption)
                        .foregroundColor(AppTheme.Palette.textSecondary)
                    TextField("e.g. Ricoh GR 3", text: $options.caption)
                        .font(AppTheme.Font.body)
                        .foregroundColor(AppTheme.Palette.textPrimary)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(AppTheme.Palette.surface)
                        )
                }
            }
            .padding(16)
        }
        .frame(maxHeight: 220)
        .background(AppTheme.Palette.background)
    }

    @ViewBuilder
    private func optionsRow<C: View>(title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppTheme.Font.caption)
                .foregroundColor(AppTheme.Palette.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                content()
            }
        }
    }

    @ViewBuilder
    private func chip(label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppTheme.Font.small.weight(.semibold))
                .foregroundColor(selected ? .black : AppTheme.Palette.textPrimary)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(
                    Capsule().fill(selected ? Color.white : AppTheme.Palette.surface)
                )
        }
        .buttonStyle(.plain)
    }

    private func swatchColor(for bg: PuzzleOptions.Background) -> Color {
        switch bg {
        case .white:    return .white
        case .black:    return .black
        case .warm:     return Color(red: 0.965, green: 0.937, blue: 0.890)
        case .gradient: return Color(red: 1.0, green: 0.831, blue: 0.678)
        }
    }

    // MARK: - Action bar

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                Task { await share() }
            } label: {
                actionLabel(title: "Share", system: "square.and.arrow.up", filled: false)
            }
            .disabled(isExporting || filledImages.isEmpty)

            Button {
                Task { await save() }
            } label: {
                actionLabel(
                    title: isExporting ? "Working..." : "Save to Photos",
                    system: "square.and.arrow.down",
                    filled: true
                )
            }
            .disabled(isExporting || filledImages.isEmpty)
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
            Text(title).font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(filled ? Color.white : Color.clear)
        .foregroundColor(filled ? .black : .white)
        .overlay(
            Capsule().stroke(Color.white.opacity(filled ? 0 : 0.25), lineWidth: 1)
        )
        .clipShape(Capsule())
    }

    // MARK: - Helpers

    private var filledImages: [UIImage] {
        images.compactMap { $0 }
    }

    private func loadImage(_ item: PhotosPickerItem, into slot: Int) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let img = UIImage(data: data) else {
                showToast("Cannot read photo")
                return
            }
            if slot < images.count {
                images[slot] = img
            }
            pickerItem = nil
        } catch {
            showToast(error.localizedDescription)
        }
    }

    private func save() async {
        isExporting = true
        defer { isExporting = false }
        guard let out = PuzzleComposer.render(
            images: filledImages, layout: currentLayout, options: options
        ) else {
            showToast("Render failed"); return
        }
        do {
            try await PhotoSaver.save(out)
            showToast("Saved to Photos")
        } catch {
            showToast(error.localizedDescription)
        }
    }

    private func share() async {
        isExporting = true
        defer { isExporting = false }
        guard let out = PuzzleComposer.render(
            images: filledImages, layout: currentLayout, options: options
        ) else {
            showToast("Render failed"); return
        }
        presentShareSheet(image: out)
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
        withAnimation { toast = message }
        Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            withAnimation { toast = nil }
        }
    }
}

struct PuzzleEditorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PuzzleEditorView(layout: .cameraDetail)
        }
        .preferredColorScheme(.dark)
    }
}
