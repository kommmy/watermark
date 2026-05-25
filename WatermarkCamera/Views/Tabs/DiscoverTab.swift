import SwiftUI
import PhotosUI

// "For You" tab: prototype-inspired browse rows with direct entry into creation.
struct DiscoverTab: View {
    var switchTo: (HomeView.Tab) -> Void

    @State private var selectedTemplate: WatermarkTemplate?
    @State private var pickerItem: PhotosPickerItem?
    @State private var loadedImage: UIImage?
    @State private var metadata: PhotoMetadata = .empty
    @State private var showPhotoPicker = false
    @State private var isLoading = false
    @State private var navigateToEditor = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                    banner
                        .padding(.horizontal, AppTheme.Spacing.l)

                    ForEach(BrowseCatalog.discoverSections) { section in
                        browseSection(section)
                    }

                    Text("Tip: tap any card to start. The app will only ask for photos when it needs them.")
                        .font(AppTheme.Font.caption)
                        .foregroundColor(AppTheme.Palette.textTertiary)
                        .padding(.horizontal, AppTheme.Spacing.l)
                        .padding(.bottom, AppTheme.Spacing.xl)
                }
                .padding(.vertical, AppTheme.Spacing.m)
            }
            .navigationTitle("LumaFrame")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .bottom) {
                FloatingCreateButton { switchTo(.watermark) }
                    .padding(.bottom, AppTheme.Spacing.xl)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("PRO")
                        .font(AppTheme.Font.caption.weight(.bold))
                        .foregroundColor(AppTheme.Palette.proOrange)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(AppTheme.Palette.surface))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { } label: { Image(systemName: "gearshape") }
                    .foregroundColor(AppTheme.Palette.textPrimary)
                }
            }
            .toolbarBackground(AppTheme.Palette.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .appBackground()
            .navigationDestination(isPresented: $navigateToEditor) {
                if let image = loadedImage, let template = selectedTemplate {
                    EditorView(image: image, initialMetadata: metadata, initialTemplate: template)
                }
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $pickerItem,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: pickerItem) { newItem in
                guard let newItem else { return }
                Task { await load(newItem) }
            }
            .onChange(of: showPhotoPicker) { isPresented in
                if !isPresented && pickerItem == nil && loadedImage == nil && !isLoading {
                    selectedTemplate = nil
                }
            }
            .onChange(of: navigateToEditor) { isActive in
                if !isActive {
                    resetWatermarkFlow()
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

    @ViewBuilder
    private func browseSection(_ section: BrowseSection) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(section.title)
                        .font(AppTheme.Font.sectionTitle)
                        .foregroundColor(AppTheme.Palette.textPrimary)
                    Text(section.subtitle)
                        .font(AppTheme.Font.caption)
                        .foregroundColor(AppTheme.Palette.textSecondary)
                        .lineLimit(1)
                }
                Spacer()
                Button("More >") {
                    switch section.destination {
                    case .watermark: switchTo(.watermark)
                    case .puzzle: switchTo(.puzzle)
                    }
                }
                .font(AppTheme.Font.small)
                .foregroundColor(AppTheme.Palette.textSecondary)
            }
            .padding(.horizontal, AppTheme.Spacing.l)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.m) {
                    ForEach(section.items) { item in
                        card(for: item)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.l)
            }
        }
    }

    @ViewBuilder
    private func card(for item: BrowseItem) -> some View {
        switch item {
        case .watermark(let template):
            Button {
                beginWatermark(template)
            } label: {
                TemplateCard(template: template, width: 136, height: 172)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Use \(template.displayName)")
        case .puzzle(let layout):
            NavigationLink {
                PuzzleEditorView(layout: layout)
            } label: {
                PuzzleLayoutCard(layout: layout, width: 136, height: 172)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open \(layout.displayName)")
        }
    }

    private func beginWatermark(_ template: WatermarkTemplate) {
        resetWatermarkFlow()
        selectedTemplate = template
        showPhotoPicker = true
    }

    private func load(_ item: PhotosPickerItem) async {
        isLoading = true
        defer { isLoading = false }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data)
            else {
                errorMessage = "Cannot read this photo."
                resetWatermarkFlow()
                return
            }
            loadedImage = image
            metadata = ExifReader.read(from: data)
            pickerItem = nil
            showPhotoPicker = false
            navigateToEditor = true
        } catch {
            errorMessage = error.localizedDescription
            resetWatermarkFlow()
        }
    }

    private func resetWatermarkFlow() {
        selectedTemplate = nil
        pickerItem = nil
        loadedImage = nil
        metadata = .empty
        showPhotoPicker = false
    }

    private var banner: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: [Color(red: 0.27, green: 0.20, blue: 0.16), Color(red: 0.17, green: 0.15, blue: 0.13)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Make it a photo card")
                        .font(AppTheme.Font.bodyBold)
                        .foregroundColor(AppTheme.Palette.textPrimary)
                    Text("Choose a style first. We guide you to the next step.")
                        .font(AppTheme.Font.small)
                        .foregroundColor(AppTheme.Palette.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                Button {
                    switchTo(.watermark)
                } label: {
                    Text("Create")
                        .font(AppTheme.Font.small.weight(.semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Capsule().fill(.white))
                }
                .buttonStyle(.plain)
            }
            .padding(AppTheme.Spacing.l)
        }
        .frame(minHeight: 96)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
    }
}
