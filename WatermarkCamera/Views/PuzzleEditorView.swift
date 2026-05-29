import SwiftUI
import PhotosUI

// Puzzle editor for the focused Leica camera collage.
struct PuzzleEditorView: View {
    let layout: PuzzleLayout

    @State private var currentLayout: PuzzleLayout
    @State private var images: [UIImage?] = []
    @State private var options: PuzzleOptions = PuzzleOptions()

    @State private var pickerSlot: Int? = nil
    @State private var pendingPickerSlot: Int? = nil
    @State private var pickerItem: PhotosPickerItem?
    @State private var isLoadingImage = false
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
            guard let newItem, let slot = pickerSlot ?? pendingPickerSlot else { return }
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
        .overlay {
            if isLoadingImage {
                LoadingOverlay(message: "正在载入照片...")
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
                    pendingPickerSlot = idx
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
                                Text("选择照片")
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
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    // MARK: - Options bar (layout / ratio / background / caption)

    // Aspect ratio bar only — background and caption removed
    private var optionsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(PuzzleOptions.Ratio.allCases) { ratio in
                    chip(label: ratio.displayName, selected: ratio == options.aspect) {
                        options.aspect = ratio
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
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

    // MARK: - Action bar

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                Task { await share() }
            } label: {
                actionLabel(title: "分享", system: "square.and.arrow.up", filled: false)
            }
            .disabled(isExporting || filledImages.isEmpty)

            Button {
                Task { await save() }
            } label: {
                actionLabel(
                    title: isExporting ? "处理中..." : "保存到相册",
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
        isLoadingImage = true
        defer {
            isLoadingImage = false
            pickerItem = nil
            pickerSlot = nil
            pendingPickerSlot = nil
        }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let img = UIImage(data: data) else {
                showToast("无法读取照片")
                return
            }
            if slot < images.count {
                images[slot] = img
            }
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
            showToast("渲染失败"); return
        }
        do {
            try await PhotoSaver.save(out)
            showToast("已保存到相册")
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
            showToast("渲染失败"); return
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
