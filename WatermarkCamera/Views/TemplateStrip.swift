import SwiftUI

/// 编辑页底部横向滚动的模板选择条。
/// 缩略图直接用原图小图 + 模板特征条，无需为每个模板单独画 thumbnail。
struct TemplateStrip: View {
    @Binding var selected: WatermarkTemplate
    let thumbnail: UIImage

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(WatermarkTemplate.allCases) { tpl in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selected = tpl
                        }
                    } label: {
                        VStack(spacing: 6) {
                            ZStack(alignment: .bottom) {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 64, height: 64)
                                    .clipped()
                                accentStrip(for: tpl)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(
                                        selected == tpl ? Color.black : Color.clear,
                                        lineWidth: 2
                                    )
                            )

                            Text(tpl.displayName)
                                .font(.caption2.weight(selected == tpl ? .semibold : .regular))
                                .foregroundColor(selected == tpl ? .black : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(.thinMaterial)
    }

    @ViewBuilder
    private func accentStrip(for tpl: WatermarkTemplate) -> some View {
        switch tpl {
        case .leica:
            Rectangle().fill(Color.white).frame(height: 12).overlay(
                Rectangle().fill(Color.red).frame(width: 16, height: 6),
                alignment: .leading
            )
        case .fujifilm:
            Rectangle().fill(Color.black).frame(height: 12)
        case .sony:
            EmptyView()
        case .hasselblad:
            Rectangle().fill(Color.white).frame(height: 14)
        case .minimal:
            Rectangle().fill(Color.white).frame(height: 8)
        }
    }
}
