import SwiftUI

// Bottom horizontal template selector inside EditorView.
// Each thumbnail = a small crop of the user's photo plus a tiny accent bar that
// hints at the template look (red Leica block, FUJIFILM stripe, etc.).
struct TemplateStrip: View {
    @Binding var selected: WatermarkTemplate
    let thumbnail: UIImage

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(WatermarkTemplate.leicaTemplates) { tpl in
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
                                        selected == tpl ? Color.white : Color.clear,
                                        lineWidth: 2
                                    )
                            )

                            Text(tpl.displayName)
                                .font(.caption2.weight(selected == tpl ? .semibold : .regular))
                                .foregroundColor(selected == tpl ? AppTheme.Palette.textPrimary : AppTheme.Palette.textSecondary)
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private func accentStrip(for tpl: WatermarkTemplate) -> some View {
        switch tpl {
        case .leica:
            HStack(spacing: 0) {
                Rectangle().fill(Color(red: 0.86, green: 0.07, blue: 0.13)).frame(width: 12)
                Rectangle().fill(Color.white)
            }
            .frame(height: 12)

        case .leica_mono:
            HStack(spacing: 0) {
                Rectangle().fill(Color(red: 0.86, green: 0.07, blue: 0.13)).frame(width: 12)
                Rectangle().fill(Color.black)
            }
            .frame(height: 12)

        case .leica_frame:
            Rectangle().fill(Color.white).frame(height: 18)

        case .leica_compact:
            HStack {
                Image("brand_leica").resizable().scaledToFit().frame(width: 16, height: 16)
                Spacer()
            }
            .padding(.horizontal, 5)
            .frame(height: 20)
            .background(Color.black.opacity(0.72))

        case .leica_gallery:
            Rectangle().fill(Color(red: 0.965, green: 0.953, blue: 0.925)).frame(height: 18)

        case .leica_glass:
            HStack(spacing: 0) {
                Rectangle().fill(Color(red: 0.86, green: 0.07, blue: 0.13)).frame(width: 10)
                Rectangle().fill(Color.white.opacity(0.55))
            }
            .frame(height: 16)
            .background(.ultraThinMaterial)

        case .leica_white_space:
            Rectangle()
                .fill(Color(red: 0.985, green: 0.982, blue: 0.973))
                .frame(height: 18)

        case .fujifilm:
            Rectangle().fill(Color.black).frame(height: 12)

        case .fuji_strip:
            VStack(spacing: 1) {
                Rectangle().fill(Color.black.opacity(0.85)).frame(height: 3)
                Rectangle().fill(Color.black).frame(height: 7)
            }
            .frame(height: 12)

        case .sony:
            EmptyView()

        case .hasselblad:
            Rectangle().fill(Color.white).frame(height: 14)

        case .ricoh_gr:
            Rectangle().fill(Color.black).frame(height: 12)

        case .iphone:
            Rectangle().fill(Color.white).frame(height: 12)

        case .polaroid:
            Rectangle().fill(Color.white).frame(height: 18)

        case .minimal:
            Rectangle().fill(Color.white).frame(height: 8)

        case .minimal_dark:
            Rectangle().fill(Color.black).frame(height: 8)

        case .date_stamp:
            EmptyView()

        case .soft_journal:
            Rectangle().fill(Color(red: 0.96, green: 0.91, blue: 0.82)).frame(height: 10)

        case .clean_instagram:
            Rectangle().fill(Color.white).frame(height: 14)

        case .magazine_cover:
            LinearGradient(
                colors: [Color.black.opacity(0.05), Color.black.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 64)

        case .receipt_memo:
            Rectangle().fill(Color(red: 0.98, green: 0.95, blue: 0.88)).frame(height: 18)

        case .film_border:
            Color.black.frame(height: 18)

        case .gallery_frame:
            Color(red: 0.960, green: 0.952, blue: 0.940).frame(height: 18)
        }
    }
}
