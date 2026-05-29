import SwiftUI

struct TemplateCard: View {
    let template: WatermarkTemplate
    var width: CGFloat = 130
    var height: CGFloat = 160

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TemplatePreviewArtwork(template: template)
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.30), radius: 12, y: 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(template.displayName)
                    .font(AppTheme.Font.small)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Palette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
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
}

private struct TemplatePreviewArtwork: View {
    let template: WatermarkTemplate

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Color(red: 0.08, green: 0.08, blue: 0.09)
                preview(width: w, height: h)
            }
        }
    }

    @ViewBuilder
    private func preview(width: CGFloat, height: CGFloat) -> some View {
        switch template {
        case .leica:
            barLayout(width: width, height: height, barColor: .white, textColor: .black, logo: "brand_leica")
        case .leica_mono:
            barLayout(width: width, height: height, barColor: Color(white: 0.04), textColor: .white, logo: "brand_leica", bw: true)
        case .film_border:
            filmBorder(width: width, height: height)
        case .gallery_frame:
            galleryFrame(width: width, height: height)
        case .leica_frame:
            paperLayout(width: width, height: height, logo: "brand_leica", title: "LEICA")
        case .leica_compact:
            leicaCompact(width: width, height: height)
        case .leica_gallery:
            leicaGallery(width: width, height: height)
        case .fujifilm:
            barLayout(width: width, height: height, barColor: Color(white: 0.06), textColor: Color(red: 0.94, green: 0.92, blue: 0.86), logo: "brand_fujifilm")
        case .fuji_strip:
            filmStrip(width: width, height: height)
        case .sony:
            overlayCard(width: width, height: height, logo: "brand_sony")
        case .hasselblad:
            paperLayout(width: width, height: height, logo: "brand_hasselblad", title: "HASSELBLAD")
        case .ricoh_gr:
            barLayout(width: width, height: height, barColor: .black, textColor: .white, logo: "brand_ricoh")
        case .iphone:
            barLayout(width: width, height: height, barColor: .white, textColor: .black, logo: "brand_apple", title: "由 iPhone 拍摄")
        case .polaroid:
            polaroid(width: width, height: height)
        case .minimal:
            minimal(width: width, height: height, dark: false)
        case .minimal_dark:
            minimal(width: width, height: height, dark: true)
        case .date_stamp:
            dateStamp(width: width, height: height)
        case .soft_journal:
            journal(width: width, height: height)
        case .clean_instagram:
            clean(width: width, height: height)
        case .magazine_cover:
            magazine(width: width, height: height)
        case .receipt_memo:
            receipt(width: width, height: height)
        }
    }

    // Artistic sample photo: warm golden-hour landscape with mountain silhouette
    private func samplePhoto(cornerRadius: CGFloat = 0) -> some View {
        ZStack {
            // Sky gradient: deep blue → warm amber → orange horizon
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.18, blue: 0.38),
                    Color(red: 0.55, green: 0.35, blue: 0.18),
                    Color(red: 0.88, green: 0.52, blue: 0.22),
                    Color(red: 0.95, green: 0.72, blue: 0.38)
                ],
                startPoint: .top, endPoint: .bottom
            )
            // Horizon glow
            Ellipse()
                .fill(Color(red: 1.0, green: 0.78, blue: 0.30).opacity(0.42))
                .frame(width: 160, height: 40)
                .offset(y: 8)
            // Mountain silhouette left
            Path { p in
                p.move(to: .init(x: -60, y: 60))
                p.addLine(to: .init(x: -10, y: -12))
                p.addLine(to: .init(x: 30, y: 60))
                p.closeSubpath()
            }
            .fill(Color(red: 0.07, green: 0.08, blue: 0.14))
            .offset(x: -22, y: 0)
            // Mountain silhouette right
            Path { p in
                p.move(to: .init(x: 10, y: 60))
                p.addLine(to: .init(x: 52, y: -6))
                p.addLine(to: .init(x: 90, y: 60))
                p.closeSubpath()
            }
            .fill(Color(red: 0.05, green: 0.06, blue: 0.12))
            .offset(x: 18, y: 4)
            // Foreground trees line
            Rectangle()
                .fill(Color(red: 0.04, green: 0.05, blue: 0.10))
                .frame(height: 24)
                .offset(y: 40)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    // Monochrome sample for dark templates
    private func samplePhotoBW(cornerRadius: CGFloat = 0) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(white: 0.85), Color(white: 0.55), Color(white: 0.25)],
                startPoint: .top, endPoint: .bottom
            )
            // Window light shadow
            Rectangle()
                .fill(Color(white: 0.18).opacity(0.55))
                .frame(width: 55, height: 120)
                .rotationEffect(.degrees(15))
                .offset(x: -22, y: 10)
            // Figure silhouette
            Ellipse()
                .fill(Color(white: 0.08))
                .frame(width: 36, height: 48)
                .offset(x: 28, y: 22)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private func barLayout(width: CGFloat, height: CGFloat, barColor: Color, textColor: Color, logo: String, title: String = "f/2.8  1/250  ISO 200", bw: Bool = false) -> some View {
        VStack(spacing: 0) {
            if bw { samplePhotoBW() } else { samplePhoto() }
            HStack(spacing: 6) {
                Image(logo)
                    .renderingMode(logo == "brand_leica" ? .original : .template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(textColor)
                    .frame(width: logo == "brand_leica" ? 18 : 42, height: 16)
                Spacer(minLength: 0)
                Text(title)
                    .font(.system(size: 7, weight: .semibold, design: .monospaced))
                    .foregroundColor(textColor.opacity(0.82))
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
            }
            .padding(.horizontal, 8)
            .frame(height: max(height * 0.22, 34))
            .background(barColor)
        }
    }

    private func filmStrip(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            perforation(height: 12)
            samplePhoto()
            perforation(height: 12)
            HStack {
                Image("brand_fujifilm").resizable().scaledToFit().frame(width: 46, height: 12)
                Spacer()
                Text("1/250  ISO 200")
                    .font(.system(size: 7, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.86))
            }
            .padding(.horizontal, 8)
            .frame(height: 28)
            .background(Color(white: 0.06))
        }
        .background(Color(white: 0.06))
    }

    private func perforation(height: CGFloat) -> some View {
        HStack(spacing: 7) {
            ForEach(0..<9, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 5, height: 7)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(Color(white: 0.06))
    }

    private func overlayCard(width: CGFloat, height: CGFloat, logo: String) -> some View {
        ZStack(alignment: .bottomTrailing) {
            samplePhoto()
            VStack(alignment: .leading, spacing: 3) {
                Image(logo).renderingMode(.template).resizable().scaledToFit()
                    .foregroundColor(.white).frame(width: 42, height: 10, alignment: .leading)
                Text("f/2.8  ISO 200")
                    .font(.system(size: 7, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.88))
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.58)))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.14), lineWidth: 1))
            .padding(9)
        }
    }

    private func paperLayout(width: CGFloat, height: CGFloat, logo: String, title: String) -> some View {
        VStack(spacing: 8) {
            samplePhoto(cornerRadius: 4)
                .padding(.horizontal, 12)
                .padding(.top, 12)
            HStack {
                Image(logo).renderingMode(.template).resizable().scaledToFit()
                    .foregroundColor(.black).frame(width: 68, height: 12)
                Spacer()
                Text("f/2.8")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(.black.opacity(0.58))
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color.white)
    }

    private func leicaCompact(width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            samplePhoto()
            HStack(spacing: 6) {
                Image("brand_leica").resizable().scaledToFit().frame(width: 20, height: 20)
                VStack(alignment: .leading, spacing: 1) {
                    Text("LEICA Q3")
                        .font(.system(size: 8, weight: .semibold))
                    Text("f/2.8  ISO 200")
                        .font(.system(size: 7, weight: .medium, design: .monospaced))
                        .opacity(0.72)
                }
            }
            .foregroundColor(.white)
            .padding(7)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.68)))
            .padding(9)
        }
    }

    private func leicaGallery(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image("brand_leica").resizable().scaledToFit().frame(width: 18, height: 18)
                Text("LEICA MOMENT")
                    .font(.system(size: 9, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            samplePhoto(cornerRadius: 3)
                .padding(.horizontal, 12)
            HStack {
                Text("LEICA Q3")
                Spacer()
                Text("f/2.8 ISO 200")
            }
            .font(.system(size: 7, weight: .medium, design: .monospaced))
            .foregroundColor(.black.opacity(0.62))
            .padding(.horizontal, 12)
            Spacer(minLength: 8)
        }
        .background(Color(red: 0.965, green: 0.953, blue: 0.925))
    }

    private func polaroid(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 8) {
            samplePhoto()
                .padding(.horizontal, 12)
                .padding(.top, 12)
            Image("brand_polaroid")
                .resizable()
                .scaledToFit()
                .frame(width: 74, height: 18)
            Text("夏日照片")
                .font(.system(size: 12, weight: .semibold, design: .serif))
                .foregroundColor(.black.opacity(0.78))
            Spacer(minLength: 10)
        }
        .background(Color.white)
    }

    private func minimal(width: CGFloat, height: CGFloat, dark: Bool) -> some View {
        VStack(spacing: 0) {
            samplePhoto()
            Text("35mm  f/2.8  1/250  ISO 200")
                .font(.system(size: 7, weight: .medium, design: .monospaced))
                .foregroundColor(dark ? .white.opacity(0.74) : .black.opacity(0.62))
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .padding(.horizontal, 7)
                .frame(maxWidth: .infinity)
                .frame(height: 24)
                .background(dark ? Color.black : Color.white)
        }
    }

    private func dateStamp(width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .bottomTrailing) {
            samplePhoto()
            Text("2026 05 29")
                .font(.custom("Courier", size: 11).weight(.bold))
                .foregroundColor(Color(red: 1.0, green: 0.70, blue: 0.18))
                .shadow(color: .black.opacity(0.65), radius: 3)
                .padding(12)
        }
    }

    private func journal(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 8) {
            samplePhoto(cornerRadius: 12)
                .padding(.horizontal, 12)
                .padding(.top, 12)
            Text("安静的一刻")
                .font(.system(size: 11, weight: .semibold, design: .serif))
                .foregroundColor(Color(red: 0.25, green: 0.19, blue: 0.14))
            Text("f/2.8 / ISO 200")
                .font(.system(size: 7, design: .monospaced))
                .foregroundColor(Color(red: 0.46, green: 0.39, blue: 0.32))
            Spacer(minLength: 8)
        }
        .background(Color(red: 0.97, green: 0.94, blue: 0.88))
    }

    private func clean(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 8) {
            samplePhoto()
                .padding(.horizontal, 12)
                .padding(.top, 12)
            HStack {
                Text("@lumaframe")
                Spacer()
                Text("ISO 200")
            }
            .font(.system(size: 8, weight: .semibold))
            .foregroundColor(.black.opacity(0.72))
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color.white)
    }

    private func magazine(width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            samplePhoto()
            LinearGradient(colors: [.black.opacity(0.42), .clear, .black.opacity(0.45)], startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 2) {
                Text("光影手记")
                    .font(.system(size: 15, weight: .black, design: .serif))
                Text("周末影像")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                Spacer()
                Text("f/2.8  ISO 200")
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
            }
            .foregroundColor(.white)
            .padding(12)
        }
    }

    private func receipt(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 8) {
            samplePhoto()
                .frame(height: height * 0.58)
            VStack(spacing: 5) {
                Text("光影小票")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                Rectangle().fill(Color.black.opacity(0.18)).frame(height: 1)
                Text("相机  RICOH GR")
                Text("参数  f/2.8  ISO 200")
            }
            .font(.system(size: 7, weight: .medium, design: .monospaced))
            .foregroundColor(.black.opacity(0.70))
            .padding(.horizontal, 10)
            Spacer(minLength: 4)
        }
        .background(Color(red: 0.98, green: 0.96, blue: 0.90))
    }

    // ── Leica 胶片边框 preview ──────────────────────────────────────────────
    private func filmBorder(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            // Top sprocket
            filmSprocket(w: width, h: 10)
            // Photo between side strips
            HStack(spacing: 0) {
                Color(white: 0.05).frame(width: 8)
                samplePhotoBW()
                Color(white: 0.05).frame(width: 8)
            }
            // Bottom sprocket
            filmSprocket(w: width, h: 10)
            // Info bar
            HStack(spacing: 5) {
                Circle().fill(Color(red: 0.86, green: 0.03, blue: 0.05))
                    .frame(width: 12, height: 12)
                    .overlay(Text("Leica").font(.system(size: 4, weight: .bold, design: .serif)).foregroundColor(.white))
                Text("M11  35mm  f/1.4")
                    .font(.system(size: 6.5, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.80))
                Spacer()
                Text("ISO 200")
                    .font(.system(size: 6.5, design: .monospaced))
                    .foregroundColor(.white.opacity(0.55))
            }
            .padding(.horizontal, 8)
            .frame(height: 22)
        }
        .background(Color(white: 0.03))
    }

    private func filmSprocket(w: CGFloat, h: CGFloat) -> some View {
        HStack(spacing: w * 0.045) {
            ForEach(0..<Int(w / (h * 1.4)), id: \.self) { _ in
                RoundedRectangle(cornerRadius: 1.2, style: .continuous)
                    .fill(Color.white.opacity(0.13))
                    .frame(width: h * 0.58, height: h * 0.65)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: h)
        .background(Color(white: 0.05))
    }

    // ── Leica 画廊边框 preview ──────────────────────────────────────────────
    private func galleryFrame(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            Color(red: 0.960, green: 0.952, blue: 0.940).frame(height: 14)
            HStack(spacing: 0) {
                Color(red: 0.960, green: 0.952, blue: 0.940).frame(width: 12)
                samplePhoto(cornerRadius: 2)
                    .shadow(color: .black.opacity(0.18), radius: 4, y: 2)
                Color(red: 0.960, green: 0.952, blue: 0.940).frame(width: 12)
            }
            HStack(spacing: 5) {
                Circle().fill(Color(red: 0.86, green: 0.03, blue: 0.05))
                    .frame(width: 11, height: 11)
                    .overlay(Text("Leica").font(.system(size: 3.5, weight: .bold, design: .serif)).foregroundColor(.white))
                Text("M11  f/1.4  1/250s")
                    .font(.system(size: 6.5, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(white: 0.25))
                Spacer()
                Text("ISO 200")
                    .font(.system(size: 6.5, design: .monospaced))
                    .foregroundColor(Color(white: 0.50))
            }
            .padding(.horizontal, 12)
            .frame(height: 22)
            .background(Color(red: 0.960, green: 0.952, blue: 0.940))
            Color(red: 0.960, green: 0.952, blue: 0.940).frame(height: 8)
        }
    }
}
