import SwiftUI

struct LeicaFrameTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var pad: CGFloat { max(image.size.width * 0.052, 28) }
    private var footerHeight: CGFloat { max(min(image.size.width * 0.12, image.size.height * 0.085), 64) }
    private var isPortrait: Bool { image.size.height > image.size.width * 1.08 }

    var body: some View {
        VStack(spacing: 0) {
            WatermarkPhotoFrame(
                image: image,
                borderColor: Color.black.opacity(0.08),
                shadowColor: Color.black.opacity(0.10),
                shadowRadius: 12,
                shadowY: 5
            )
            .padding(.horizontal, pad)
            .padding(.top, pad)

            HStack(alignment: .center, spacing: footerHeight * 0.18) {
                Image("brand_leica")
                    .resizable()
                    .scaledToFit()
                    .frame(width: footerHeight * 0.68, height: footerHeight * 0.68)

                VStack(alignment: .leading, spacing: footerHeight * 0.08) {
                    Text(meta.cameraDisplayName)
                        .font(.system(size: footerHeight * 0.24, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: footerHeight * 0.08) {
                    Text(meta.compactExposureLine)
                        .font(.system(size: footerHeight * 0.20, weight: .medium, design: .monospaced))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(isPortrait ? 0.36 : 0.48)
                    if !isPortrait {
                        Text(meta.paramsDate)
                            .font(.system(size: footerHeight * 0.15, design: .monospaced))
                            .foregroundColor(Color(white: 0.48))
                            .lineLimit(1)
                            .minimumScaleFactor(0.55)
                    }
                }
            }
            .padding(.horizontal, pad)
            .frame(height: footerHeight)
        }
        .background(Color(red: 0.985, green: 0.976, blue: 0.948))
    }
}

struct LeicaCompactTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var unit: CGFloat { max(min(image.size.width, image.size.height) * 0.024, 14) }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            WatermarkPhotoFrame(
                image: image,
                borderColor: Color.white.opacity(0.18),
                shadowColor: Color.black.opacity(0.18),
                shadowRadius: 8,
                shadowY: 3
            )

            HStack(spacing: unit * 0.55) {
                Image("brand_leica")
                    .resizable()
                    .scaledToFit()
                    .frame(width: unit * 2.2, height: unit * 2.2)

                VStack(alignment: .leading, spacing: unit * 0.12) {
                    Text(meta.cameraDisplayName)
                        .font(.system(size: unit * 0.82, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                    Text(meta.compactExposureLine)
                        .font(.system(size: unit * 0.68, weight: .medium, design: .monospaced))
                        .opacity(0.72)
                        .lineLimit(1)
                        .minimumScaleFactor(0.48)
                }
            }
            .foregroundColor(.white)
            .padding(unit * 0.82)
            .background(
                RoundedRectangle(cornerRadius: unit * 0.75, style: .continuous)
                    .fill(Color.black.opacity(0.68))
                    .overlay(
                        RoundedRectangle(cornerRadius: unit * 0.75, style: .continuous)
                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    )
            )
            .padding(unit * 1.4)
        }
    }
}

struct LeicaGalleryTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var pad: CGFloat { max(image.size.width * 0.070, 36) }
    private var titleSize: CGFloat { max(image.size.width * 0.026, 16) }
    private var smallSize: CGFloat { max(image.size.width * 0.016, 10) }
    private var isPortrait: Bool { image.size.height > image.size.width * 1.08 }

    var body: some View {
        VStack(spacing: pad * 0.38) {
            HStack {
                Image("brand_leica")
                    .resizable()
                    .scaledToFit()
                    .frame(width: titleSize * 1.7, height: titleSize * 1.7)
                Text("LEICA MOMENT")
                    .font(.system(size: titleSize, weight: .bold, design: .serif))
                    .tracking(titleSize * 0.06)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, pad)
            .padding(.top, pad * 0.86)

            WatermarkPhotoFrame(
                image: image,
                borderColor: Color.black.opacity(0.10),
                shadowColor: Color.black.opacity(0.09),
                shadowRadius: 10,
                shadowY: 4
            )
            .padding(.horizontal, pad)

            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: pad * 0.10) {
                    Text(meta.cameraDisplayName)
                        .font(.system(size: titleSize * 0.78, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                }
                Spacer(minLength: pad * 0.4)
                Text(meta.compactExposureLine)
                    .font(.system(size: smallSize, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(white: 0.28))
                    .lineLimit(1)
                    .minimumScaleFactor(isPortrait ? 0.36 : 0.48)
            }
            .padding(.horizontal, pad)
            .padding(.bottom, pad)
        }
        .background(Color(red: 0.965, green: 0.953, blue: 0.925))
    }
}
