import SwiftUI
import PhotosUI

/// 首页：选图入口 + 简介。选好图后跳转到 `EditorView`。
struct HomeView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var loadedImage: UIImage?
    @State private var metadata: PhotoMetadata = .empty
    @State private var isLoading = false
    @State private var navigate = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(white: 0.97), Color(white: 0.92)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 36) {
                    Spacer().frame(height: 40)

                    Image(systemName: "camera.aperture")
                        .font(.system(size: 96, weight: .ultraLight))
                        .foregroundStyle(.black)

                    VStack(spacing: 10) {
                        Text("相机水印")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.black)
                        Text("一键给照片打上相机风格水印")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack(spacing: 10) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Image(systemName: "photo.on.rectangle.angled")
                            }
                            Text(isLoading ? "正在读取 EXIF…" : "选择照片")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 32)

                    Text("支持 JPEG / HEIC / RAW，全程本地处理")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 32)
                }
            }
            .navigationDestination(isPresented: $navigate) {
                if let img = loadedImage {
                    EditorView(image: img, initialMetadata: metadata)
                }
            }
            .onChange(of: selectedItem) { newItem in
                guard let newItem else { return }
                Task { await load(newItem) }
            }
            .alert(
                "无法读取照片",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("好的", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func load(_ item: PhotosPickerItem) async {
        isLoading = true
        defer { isLoading = false }

        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                errorMessage = "无法读取该照片的数据。"
                return
            }
            guard let img = UIImage(data: data) else {
                errorMessage = "图片格式不被支持。"
                return
            }
            loadedImage = img
            metadata = ExifReader.read(from: data)
            navigate = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    HomeView()
}
