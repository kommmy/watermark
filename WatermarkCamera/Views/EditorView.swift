import SwiftUI
import Photos

/// 编辑页：预览 + 模板切换 + 保存/分享。
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

    init(image: UIImage, initialMetadata: PhotoMetadata) {
        self.image = image
        self._metadata = State(initialValue: initialMetadata)
        self._template = State(initialValue: .recommended(for: initialMetadata))
        self.thumbnail = image.resized(toWidth: 200) ?? image
    }

    var body: some View {
        VStack(spacing: 0) {
            previewArea

            TemplateStrip(selected: $template, thumbnail: thumbnail)

            actionBar
        }
        .background(Color(white: 0.96).ignoresSafeArea())
        .navigationTitle(metadata.cameraModel ?? "编辑")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showMetadataSheet = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .accessibilityLabel("编辑参数")
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
        ScrollView {
            ZStack {
                if let previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFit()
                        .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 240)
                }
            }
            .padding(20)
        }
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
                    title: isExporting ? "处理中…" : "保存到相册",
                    system: "square.and.arrow.down",
                    filled: true
                )
            }
            .disabled(isExporting)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .padding(.bottom, 8)
        .background(.thinMaterial)
    }

    @ViewBuilder
    private func actionLabel(title: String, system: String, filled: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: system)
            Text(title).font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(filled ? Color.black : Color.clear)
        .foregroundColor(filled ? .white : .black)
        .overlay(
            Capsule().stroke(Color.black.opacity(filled ? 0 : 0.25), lineWidth: 1)
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

    /// 直接弹系统分享面板（UIActivityViewController），免 iOS 16 上 ShareLink 对 UIImage 类型的限制。
    private func presentShareSheet(image: UIImage) {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        guard let root = (windows.first(where: \.isKeyWindow) ?? windows.first)?.rootViewController
        else { return }
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        // 找到最上层 controller 来 present，避免被 NavigationStack 拦截。
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

