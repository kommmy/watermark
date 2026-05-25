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
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                    intro
                    ForEach(BrowseCatalog.watermarkSections) { section in
                        watermarkSection(section)
                    }

                    Text("Pick a style first, then choose a photo. You can still change metadata in the editor.")
                        .font(AppTheme.Font.caption)
                        .foregroundColor(AppTheme.Palette.textTertiary)
                        .padding(.horizontal, AppTheme.Spacing.l)
                        .padding(.bottom, 104)
                }
                .padding(.vertical, AppTheme.Spacing.m)
            }
            .navigationTitle("Watermarks")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .bottom) {
                FloatingCreateButton { begin(.soft_journal) }
                    .padding(.bottom, AppTheme.Spacing.xl)
            }
            .overlay {
                if isLoading {
                    LoadingOverlay(message: "Preparing photo...")
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
                "Cannot read photo",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: { Text(errorMessage ?? "") }
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choose a look")
                .font(AppTheme.Font.title)
                .foregroundColor(AppTheme.Palette.textPrimary)
            Text("Brand watermarks, quiet borders, film notes and Xiaohongshu-friendly cards.")
                .font(AppTheme.Font.small)
                .foregroundColor(AppTheme.Palette.textSecondary)
        }
        .padding(.horizontal, AppTheme.Spacing.l)
    }

    private func watermarkSection(_ section: BrowseSection) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
            SectionHeader(title: section.title, trailing: nil)
            Text(section.subtitle)
                .font(AppTheme.Font.caption)
                .foregroundColor(AppTheme.Palette.textSecondary)
                .padding(.horizontal, AppTheme.Spacing.l)
                .padding(.top, -AppTheme.Spacing.s)

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
                            .accessibilityLabel("Use \(template.displayName)")
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.l)
            }
        }
    }

    private func begin(_ template: WatermarkTemplate) {
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
                errorMessage = "Cannot read this photo."
                resetFlow()
                return
            }
            loadedImage = img
            metadata = ExifReader.read(from: data)
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
