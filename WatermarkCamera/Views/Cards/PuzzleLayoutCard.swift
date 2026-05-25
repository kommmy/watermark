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
                Text("\(layout.slotCount) photos - \(layout.hint)")
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
            VStack(spacing: gap) {
                ZStack {
                    Rectangle().fill(Color.white)
                    Image(systemName: "camera")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.black.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .frame(height: height * 0.32)
                .cornerRadius(4)
                slot.cornerRadius(4)
            }
            .padding(pad)
        }
    }

    private var slot: some View {
        Rectangle().fill(AppTheme.Palette.surface)
    }
}
