import SwiftUI

// Puzzle layout cover card: pure geometric shapes hint at the layout.
struct PuzzleLayoutCard: View {
    let layout: PuzzleLayout
    var width: CGFloat = 130
    var height: CGFloat = 160

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cover
                .frame(width: width, height: height)
                .background(AppTheme.Palette.card)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(layout.displayName)
                    .font(AppTheme.Font.small)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Palette.textPrimary)
                    .lineLimit(1)
                Text("\(layout.slotCount) 张照片 · \(layout.hint)")
                    .font(AppTheme.Font.caption)
                    .foregroundColor(AppTheme.Palette.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
            .padding(.top, 8)
            .frame(width: width, alignment: .leading)
        }
    }

    @ViewBuilder
    private var cover: some View {
        let pad: CGFloat = 14
        let gap: CGFloat = 6
        switch layout {
        case .vertical2:
            VStack(spacing: gap) {
                slot.cornerRadius(4)
                slot.cornerRadius(4)
            }
            .padding(pad)

        case .horizontal2:
            HStack(spacing: gap) {
                slot.cornerRadius(4)
                slot.cornerRadius(4)
            }
            .padding(pad)

        case .grid4:
            VStack(spacing: gap) {
                HStack(spacing: gap) {
                    slot.cornerRadius(4)
                    slot.cornerRadius(4)
                }
                HStack(spacing: gap) {
                    slot.cornerRadius(4)
                    slot.cornerRadius(4)
                }
            }
            .padding(pad)

        case .cameraDetail:
            VStack(spacing: 0) {
                // Real M11 back photo thumbnail
                ZStack {
                    Color.white
                    Image("camera_m11_back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.68)
                        .shadow(color: .black.opacity(0.16), radius: 5, y: 2)
                }
                .frame(height: height * 0.46)
                .frame(maxWidth: .infinity)

                // Photo section placeholder gradient
                LinearGradient(
                    colors: [Color(white: 0.65), Color(white: 0.78)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    private var slot: some View {
        Rectangle().fill(AppTheme.Palette.surface)
    }

    private var leicaCameraPreview: some View {
        ZStack {
            Color.white
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(red: 0.70, green: 0.69, blue: 0.63))
                .frame(width: 96, height: 46)
                .offset(y: 8)
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color.black.opacity(0.84))
                .frame(width: 76, height: 23)
                .offset(y: 14)
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.70, green: 0.86, blue: 0.94), Color(red: 0.22, green: 0.42, blue: 0.38)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 30, height: 18)
                .offset(x: 20, y: 1)
            Circle()
                .fill(Color.black)
                .frame(width: 34, height: 34)
                .offset(x: -12, y: 16)
            Circle()
                .fill(Color(red: 0.86, green: 0.03, blue: 0.05))
                .frame(width: 14, height: 14)
                .offset(x: -35, y: -4)
        }
    }
}
