import SwiftUI
import PhotosUI

// Watermark tab: grouped browse rows for all 16 templates. Tap a card to pick a photo,
// then jump into EditorView with the chosen template + image.
struct WatermarkTab: View {
    var preselectedTemplate: WatermarkTemplate? = nil

    @State private var selectedTemplate: WatermarkTemplate?
    @State private var pickerItem: PhotosPickerItem?
    @State private var loadedImage: UIImage?
    @State private var metadata: PhotoMetadata = .empty
    @State private var showPhotoPicker = false
    @State private var isLoading = false
    @State private var navigate = false
    @State private var errorMessage: String?
    @State private var didApplyPreselection = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.l) {
                    intro
                    ForEach(BrowseCatalog.watermarkSections) { section in
                        watermarkSection(section)
                    }
                }
                .padding(.top, AppTheme.Spacing.m)
                .padding(.bottom, 104)
            }
            .navigationTitle("徕卡水印")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .bottomTrailing) {
                FloatingCreateButton { begin() }
                    .padding(.trailing, AppTheme.Spacing.l)
                    .padding(.bottom, AppTheme.Spacing.xl)
            }
            .overlay {
                if isLoading {
                    LoadingOverlay(message: "正在读取照片信息...")
                }
            }
            .toolbarBackground(AppTheme.Palette.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .appBackground()
            .navigationDestination(isPresented: $navigate) {
                if let img = loadedImage, let tpl = selectedTemplate {
                    EditorView(image: img, initialMetadata: metadata, initialTemplate: tpl)
                }
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $pickerItem,
                matching: .images,
                photoLibrary: .shared()
            )
            .onAppear {
                if !didApplyPreselection, let pre = preselectedTemplate {
                    didApplyPreselection = true
                    begin(pre)
                }
            }
            .onChange(of: pickerItem) { newItem in
                guard let newItem else { return }
                Task { await load(newItem) }
            }
            .onChange(of: showPhotoPicker) { isPresented in
                if !isPresented && pickerItem == nil && loadedImage == nil && !isLoading {
                    selectedTemplate = nil
                }
            }
            .onChange(of: navigate) { isActive in
                if !isActive {
                    resetFlow()
                }
            }
            .alert(
                "无法读取照片",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("好", role: .cancel) {}
            } message: { Text(errorMessage ?? "") }
        }
    }

    private var intro: some View {
        Button {
            begin()
        } label: {
            Label("选择照片，智能匹配", systemImage: "sparkles")
                .font(AppTheme.Font.small.weight(.semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.white))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppTheme.Spacing.l)
    }

    private func watermarkSection(_ section: BrowseSection) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.m) {
                    ForEach(section.items) { item in
                        if case .watermark(let template) = item {
                            Button {
                                begin(template)
                            } label: {
                                TemplateCard(template: template, width: 142, height: 178)
                            }
                            .buttonStyle(.plain)
                            .disabled(isLoading)
                            .opacity(isLoading ? 0.6 : 1)
                            .accessibilityLabel("使用\(template.displayName)")
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.l)
            }
        }
    }

    private func begin(_ template: WatermarkTemplate? = nil) {
        guard !isLoading else { return }
        resetFlow()
        selectedTemplate = template
        showPhotoPicker = true
    }

    private func load(_ item: PhotosPickerItem) async {
        isLoading = true
        defer { isLoading = false }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let img = UIImage(data: data)
            else {
                errorMessage = "这张照片读取失败，请换一张试试。"
                resetFlow()
                return
            }
            loadedImage = img
            let photoMetadata = ExifReader.read(from: data)
            metadata = photoMetadata
            selectedTemplate = WatermarkTemplate.resolved(initial: selectedTemplate, for: photoMetadata)
            showPhotoPicker = false
            navigate = true
            pickerItem = nil
        } catch {
            errorMessage = error.localizedDescription
            resetFlow()
        }
    }

    private func resetFlow() {
        selectedTemplate = nil
        pickerItem = nil
        loadedImage = nil
        metadata = .empty
        showPhotoPicker = false
    }
}

struct WatermarkTab_Previews: PreviewProvider {
    static var previews: some View {
        WatermarkTab().preferredColorScheme(.dark)
    }
}
