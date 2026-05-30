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
                ZStack {
                    Color.white
                    // Reuse the real screen component so the card preview stays
                    // in sync with the actual layout's LCD alignment.
                    LeicaM11Screen(image: UIImage(named: "sample_mountain"))
                        .frame(width: width * 0.70)
                }
                .frame(height: height * 0.46)
                .frame(maxWidth: .infinity)

                Image("sample_mountain")
                    .resizable()
                    .scaledToFill()
            }
        }
    }

    private var slot: some View {
        Rectangle().fill(AppTheme.Palette.surface)
    }
}
