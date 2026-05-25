import SwiftUI

// Watermark template cover card used in DiscoverTab + WatermarkTab.
// Because we don't have a real preview at this point (no photo picked yet),
// we synthesize a brand-flavored gradient + an accent bar that hints at the
// template's look (red Leica block, FUJIFILM stripe, Polaroid white border, etc.)
struct TemplateCard: View {
    let template: WatermarkTemplate
    var width: CGFloat = 130
    var height: CGFloat = 160

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cover
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(template.displayName)
                    .font(AppTheme.Font.small)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Palette.textPrimary)
                    .lineLimit(1)
                Text(template.brandLabel)
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
        ZStack {
            LinearGradient(
                colors: gradient,
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            VStack {
                Spacer()
                accentBar
            }
        }
    }

    private var gradient: [Color] {
        switch template {
        case .leica:        return [Color(white: 0.18), Color(white: 0.08)]
        case .leica_mono:   return [Color(white: 0.10), Color(white: 0.02)]
        case .fujifilm:     return [Color(red: 0.18, green: 0.13, blue: 0.10), Color(white: 0.05)]
        case .fuji_strip:   return [Color(white: 0.10), Color(white: 0.04)]
        case .sony:         return [Color(red: 0.10, green: 0.13, blue: 0.20), Color(red: 0.04, green: 0.05, blue: 0.10)]
        case .hasselblad:   return [Color(white: 0.92), Color(white: 0.75)]
        case .ricoh_gr:     return [Color(white: 0.12), Color(white: 0.02)]
        case .iphone:       return [Color(white: 0.95), Color(white: 0.82)]
        case .polaroid:     return [Color(white: 1.0), Color(white: 0.88)]
        case .minimal:      return [Color(white: 0.96), Color(white: 0.85)]
        case .minimal_dark: return [Color(white: 0.15), Color(white: 0.04)]
        case .date_stamp:   return [Color(red: 0.32, green: 0.16, blue: 0.06), Color(red: 0.12, green: 0.07, blue: 0.04)]
        }
    }

    @ViewBuilder
    private var accentBar: some View {
        switch template {
        case .leica:
            HStack {
                Image("brand_leica").resizable().scaledToFit().frame(width: 18, height: 18)
                Spacer()
            }
            .padding(.horizontal, 6)
            .background(Color.white)
            .frame(height: 18)

        case .leica_mono:
            HStack {
                Image("brand_leica").resizable().scaledToFit().frame(width: 18, height: 18)
                Spacer()
            }
            .padding(.horizontal, 6)
            .background(Color.black)
            .frame(height: 18).overlay(Rectangle().stroke(Color.white.opacity(0.2), lineWidth: 0.5))

        case .fujifilm, .fuji_strip:
            HStack(spacing: 4) {
                Image("brand_fujifilm").resizable().scaledToFit().frame(width: 52, height: 10)
                Spacer()
            }
            .padding(.horizontal, 8).frame(height: 18).background(Color.black)

        case .sony:
            HStack {
                Spacer()
                Image("brand_sony").renderingMode(.template).resizable().scaledToFit()
                    .foregroundColor(.white).frame(width: 34, height: 8)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Color.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .padding(6)
            }

        case .hasselblad:
            HStack(spacing: 4) {
                Image("brand_hasselblad").renderingMode(.template).resizable().scaledToFit()
                    .foregroundColor(.black).frame(width: 68, height: 8)
                Spacer()
            }
            .padding(.horizontal, 8).frame(height: 22).background(Color.white)

        case .ricoh_gr:
            HStack {
                Image("brand_ricoh").renderingMode(.template).resizable().scaledToFit()
                    .foregroundColor(.white).frame(width: 44, height: 10)
                Spacer()
            }
            .padding(.horizontal, 8).frame(height: 22).background(Color.black)

        case .iphone:
            HStack(spacing: 4) {
                Image("brand_apple").renderingMode(.template).resizable().scaledToFit()
                    .foregroundColor(.black).frame(width: 8, height: 10)
                Text("Shot on iPhone").font(.system(size: 9, weight: .medium)).foregroundColor(.black)
            }
            .frame(maxWidth: .infinity).frame(height: 22).background(Color.white)

        case .polaroid:
            Image("brand_polaroid").resizable().scaledToFit()
                .frame(width: 70, height: 18)
                .frame(maxWidth: .infinity).frame(height: 32).background(Color.white)

        case .minimal:
            HStack(spacing: 4) {
                Text("28mm  f/1.7").font(.system(size: 7, weight: .light, design: .monospaced)).foregroundColor(.black)
            }
            .padding(.horizontal, 8).frame(maxWidth: .infinity).frame(height: 16).background(Color.white)

        case .minimal_dark:
            HStack(spacing: 4) {
                Text("28mm  f/1.7").font(.system(size: 7, weight: .light, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 8).frame(maxWidth: .infinity).frame(height: 16).background(Color.black)

        case .date_stamp:
            HStack {
                Spacer()
                Text("2026 05 25")
                    .font(.custom("Courier", size: 9).weight(.bold))
                    .foregroundColor(Color(red: 1.0, green: 0.71, blue: 0.21))
                    .padding(.trailing, 8)
                    .padding(.bottom, 6)
            }
        }
    }
}
