import SwiftUI

/// 半屏弹窗：允许用户手动覆盖 EXIF 字段。
///
/// 典型用法：相机机型字段写错了想改一下、隐藏 GPS、自己加一行镜头描述等。
struct MetadataEditorSheet: View {
    @Binding var metadata: PhotoMetadata
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("相机") {
                    TextField("品牌（如 LEICA CAMERA AG）",
                              text: optional($metadata.cameraMake))
                    TextField("型号（如 Q3）",
                              text: optional($metadata.cameraModel))
                }
                Section("镜头") {
                    TextField("镜头型号", text: optional($metadata.lensModel))
                }
                Section("参数") {
                    TextField("光圈（如 1.7）", value: $metadata.aperture, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("快门（如 1/250s）", text: optional($metadata.shutter))
                    TextField("ISO", value: $metadata.iso, format: .number)
                        .keyboardType(.numberPad)
                    TextField("焦距 mm", value: $metadata.focalLength35mm, format: .number)
                        .keyboardType(.numberPad)
                }
                Section("地点") {
                    TextField("自定义地点（覆盖 GPS）", text: optional($metadata.placeName))
                    if let coord = metadata.coordinateText {
                        HStack {
                            Text("原始 GPS").foregroundColor(.secondary)
                            Spacer()
                            Text(coord).font(.system(.footnote, design: .monospaced))
                        }
                        Button(role: .destructive) {
                            metadata.coordinate = nil
                        } label: {
                            Label("清除 GPS 信息", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("编辑参数")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    /// `String?` -> `Binding<String>` 的桥，TextField 直接绑。
    private func optional(_ source: Binding<String?>) -> Binding<String> {
        Binding(
            get: { source.wrappedValue ?? "" },
            set: { source.wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}
