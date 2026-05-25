import SwiftUI
import PhotosUI

// Watermark tab: a 2-col grid of all 12 templates. Tap a card to pick a photo,
// then jump into EditorView with the chosen template + image.
struct WatermarkTab: View {
    var preselectedTemplate: WatermarkTemplate? = nil

    @State private var selectedTemplate: WatermarkTemplate?
    @State private var pickerItem: PhotosPickerItem?
    @State private var loadedImage: UIImage?
    @State private var metadata: PhotoMetadata = .empty
    @State private var isLoading = false
    @State private var navigate = false
    @State private var errorMessage: String?

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.m),
        GridItem(.flexible(), spacing: AppTheme.Spacing.m),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: AppTheme.Spacing.l) {
                    ForEach(WatermarkTemplate.allCases) { tpl in
                        Button {
                            selectedTemplate = tpl
                        } label: {
                            TemplateCard(template: tpl, width: 160, height: 200)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(AppTheme.Spacing.l)
            }
            .navigationTitle("Watermarks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.Palette.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .appBackground()
            .navigationDestination(isPresented: $navigate) {
                if let img = loadedImage, let tpl = selectedTemplate {
                    EditorView(image: img, initialMetadata: metadata, initialTemplate: tpl)
                }
            }
            .photosPicker(
                isPresented: Binding(
                    get: { selectedTemplate != nil && loadedImage == nil && !isLoading },
                    set: { if !$0 { selectedTemplate = nil } }
                ),
                selection: $pickerItem,
                matching: .images,
                photoLibrary: .shared()
            )
            .onAppear {
                if let pre = preselectedTemplate {
                    selectedTemplate = pre
                }
            }
            .onChange(of: pickerItem) { newItem in
                guard let newItem else { return }
                Task { await load(newItem) }
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

    private func load(_ item: PhotosPickerItem) async {
        isLoading = true
        defer { isLoading = false }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let img = UIImage(data: data)
            else {
                errorMessage = "Cannot read this photo."
                selectedTemplate = nil
                pickerItem = nil
                return
            }
            loadedImage = img
            metadata = ExifReader.read(from: data)
            navigate = true
            pickerItem = nil
        } catch {
            errorMessage = error.localizedDescription
            selectedTemplate = nil
            pickerItem = nil
        }
    }
}

struct WatermarkTab_Previews: PreviewProvider {
    static var previews: some View {
        WatermarkTab().preferredColorScheme(.dark)
    }
}
