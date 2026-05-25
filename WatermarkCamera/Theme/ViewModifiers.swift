import SwiftUI

// MARK: - Card style

struct CardStyle: ViewModifier {
    var background: Color = AppTheme.Palette.card
    var radius: CGFloat = AppTheme.Radius.card

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(background)
            )
            .shadow(
                color: AppTheme.Shadow.card.color,
                radius: AppTheme.Shadow.card.radius,
                x: AppTheme.Shadow.card.x,
                y: AppTheme.Shadow.card.y
            )
    }
}

// MARK: - Capsule button

enum CapsuleStyleVariant {
    case primary    // 白底黑字
    case secondary  // 透明 + 描边
    case dark       // 黑底白字
}

struct CapsuleButtonStyle: ButtonStyle {
    let variant: CapsuleStyleVariant

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Font.bodyBold)
            .padding(.vertical, 14)
            .padding(.horizontal, 22)
            .frame(maxWidth: .infinity)
            .foregroundColor(foreground)
            .background(background)
            .overlay(
                Capsule().stroke(borderColor, lineWidth: borderWidth)
            )
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.75 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private var foreground: Color {
        switch variant {
        case .primary:   return .black
        case .secondary: return AppTheme.Palette.textPrimary
        case .dark:      return .white
        }
    }
    private var background: Color {
        switch variant {
        case .primary:   return .white
        case .secondary: return .clear
        case .dark:      return AppTheme.Palette.surface
        }
    }
    private var borderColor: Color {
        switch variant {
        case .secondary: return AppTheme.Palette.separator
        default:         return .clear
        }
    }
    private var borderWidth: CGFloat {
        switch variant {
        case .secondary: return 1
        default:         return 0
        }
    }
}

// MARK: - Section header

struct SectionHeader: View {
    let title: String
    var trailing: String? = nil
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(AppTheme.Font.sectionTitle)
                .foregroundColor(AppTheme.Palette.textPrimary)
            Spacer()
            if let trailing {
                Button(action: { trailingAction?() }) {
                    Text(trailing)
                        .font(AppTheme.Font.small)
                        .foregroundColor(AppTheme.Palette.textSecondary)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.l)
    }
}

// MARK: - Floating create button

struct FloatingCreateButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 62, height: 62)
                .background(Circle().fill(.white))
                .shadow(color: Color.black.opacity(0.32), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Quick create")
    }
}

// MARK: - View extensions

extension View {
    func cardStyle(
        background: Color = AppTheme.Palette.card,
        radius: CGFloat = AppTheme.Radius.card
    ) -> some View {
        modifier(CardStyle(background: background, radius: radius))
    }

    /// 给整个屏幕铺设主背景。一般用在每个 Tab 的根 View 上。
    func appBackground() -> some View {
        background(AppTheme.Palette.background.ignoresSafeArea())
    }
}
