import SwiftUI
import Photos

// Watermark editor: preview + horizontal template strip + save/share.
struct EditorView: View {
    let image: UIImage

    @State private var metadata: PhotoMetadata
    @State private var template: WatermarkTemplate
    @State private var previewImage: UIImage?
    @State private var isRenderingPreview = false
    @State private var isExporting = false
    @State private var showMetadataSheet = false
    @State private var toast: ToastMessage?

    private let thumbnail: UIImage

    init(image: UIImage, initialMetadata: PhotoMetadata, initialTemplate: WatermarkTemplate? = nil) {
        self.image = image
        self._metadata = State(initialValue: initialMetadata)
        let startTpl = initialTemplate ?? .recommended(for: initialMetadata)
        self._template = State(initialValue: startTpl)
        self.thumbnail = image.resized(toWidth: 200) ?? image
    }

    var body: some View {
        VStack(spacing: 0) {
            previewArea
            MetadataSummaryBar(metadata: metadata)
            TemplateStrip(selected: $template, thumbnail: thumbnail)
            actionBar
        }
        .appBackground()
        .navigationTitle(metadata.cameraDisplayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.Palette.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showMetadataSheet = true } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .accessibilityLabel("编辑照片参数")
                .foregroundColor(AppTheme.Palette.textPrimary)
            }
        }
        .sheet(isPresented: $showMetadataSheet, onDismiss: renderPreview) {
            MetadataEditorSheet(metadata: $metadata)
                .presentationDetents([.medium, .large])
        }
        .task { renderPreview() }
        .onChange(of: template) { _ in renderPreview() }
        .overlay(alignment: .top) {
            if let toast {
                ToastView(message: toast)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Preview

    @ViewBuilder
    private var previewArea: some View {
        GeometryReader { geo in
            ZStack {
                AppTheme.Palette.previewBackdrop
                if let previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            maxWidth:  geo.size.width  - 40,
                            maxHeight: geo.size.height - 40
                        )
                        .shadow(color: Color.black.opacity(0.55), radius: 18, y: 8)
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
        }
        .background(AppTheme.Palette.previewBackdrop)
    }

    // MARK: - Action bar

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                Task { await share() }
            } label: {
                actionLabel(title: "分享", system: "square.and.arrow.up", filled: false)
            }
            .disabled(isExporting)

            Button {
                Task { await save() }
            } label: {
                actionLabel(
                    title: isExporting ? "处理中..." : "保存到相册",
                    system: "square.and.arrow.down",
                    filled: true
                )
            }
            .disabled(isExporting)
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

    // MARK: - Rendering

    private func renderPreview() {
        guard !isRenderingPreview else { return }
        isRenderingPreview = true
        Task { @MainActor in
            previewImage = ImageComposer.render(
                image: image,
                meta: metadata,
                template: template,
                maxLongEdge: 1600
            )
            isRenderingPreview = false
        }
    }

    // MARK: - Save / Share

    private func save() async {
        isExporting = true
        defer { isExporting = false }

        guard let full = await renderFull() else {
            showToast("渲染失败")
            return
        }
        do {
            try await PhotoSaver.save(full)
            showToast("已保存到相册")
        } catch {
            showToast(error.localizedDescription)
        }
    }

    private func share() async {
        isExporting = true
        defer { isExporting = false }
        guard let full = await renderFull() else {
            showToast("渲染失败")
            return
        }
        presentShareSheet(image: full)
    }

    @MainActor
    private func renderFull() async -> UIImage? {
        ImageComposer.render(
            image: image,
            meta: metadata,
            template: template,
            maxLongEdge: 4096
        )
    }

    // Present system share sheet directly (avoids iOS 16 ShareLink quirks for UIImage).
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
        withAnimation { toast = ToastMessage(text: message) }
        Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            withAnimation { toast = nil }
        }
    }
}

// MARK: - Toast

private struct ToastMessage: Identifiable {
    let id = UUID()
    let text: String
}

private struct ToastView: View {
    let message: ToastMessage
    var body: some View {
        Text(message.text)
            .font(.subheadline.weight(.medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color.black.opacity(0.85)))
    }
}

private struct MetadataSummaryBar: View {
    let metadata: PhotoMetadata

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Label(metadata.brandDisplayName, systemImage: "camera.aperture")
                    .font(AppTheme.Font.small.weight(.semibold))
                    .foregroundColor(AppTheme.Palette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 8)
                Text(metadata.cameraDisplayName)
                    .font(AppTheme.Font.caption)
                    .foregroundColor(AppTheme.Palette.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            HStack(spacing: 8) {
                metadataChip(metadata.apertureText ?? "f/--")
                metadataChip(metadata.shutter ?? "快门 --")
                metadataChip(metadata.isoText ?? "ISO --")
                if let focal = metadata.focalLengthText {
                    metadataChip(focal)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppTheme.Palette.background)
        .overlay(alignment: .top) {
            Rectangle().fill(AppTheme.Palette.separator).frame(height: 1)
        }
    }

    private func metadataChip(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.Font.caption.weight(.medium))
            .foregroundColor(AppTheme.Palette.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(
                Capsule().fill(AppTheme.Palette.surface)
            )
    }
}
