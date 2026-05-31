import SwiftUI

// Fujifilm film-strip: perforation strips above and below the photo,
// then a black info bar with brand + params.
struct FujiFilmStripTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var stripHeight: CGFloat { max(image.size.height * 0.04, 24) }
    private var barHeight: CGFloat { max(image.size.height * 0.085, 44) }

    var body: some View {
        VStack(spacing: 0) {
            perforationStrip
            WatermarkPhotoFrame(
                image: image,
                borderColor: Color.white.opacity(0.12),
                shadowColor: Color.black.opacity(0.25),
                shadowRadius: 8,
                shadowY: 3
            )
            perforationStrip

            HStack(spacing: barHeight * 0.3) {
                HStack(spacing: barHeight * 0.18) {
                    Image("brand_fujifilm")
                        .resizable()
                        .scaledToFit()
                        .frame(width: barHeight * 1.65, height: barHeight * 0.30, alignment: .leading)
                    Text(meta.cameraDisplayName == "未知相机" ? "X SERIES" : meta.cameraDisplayName)
                        .font(.system(size: barHeight * 0.22, weight: .bold))
                        .foregroundColor(Color(white: 0.94))
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Text(meta.paramsLine)
                    .font(.system(size: barHeight * 0.26, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(white: 0.94))
                    .lineLimit(1)
            }
            .padding(.horizontal, barHeight * 0.4)
            .frame(height: barHeight)
            .frame(maxWidth: .infinity)
            .background(Color(white: 0.09))
        }
        .background(Color(white: 0.09))
    }

    private var perforationStrip: some View {
        GeometryReader { geo in
            HStack(spacing: stripHeight * 0.45) {
                ForEach(0..<Int(geo.size.width / max(stripHeight * 0.8, 1)) + 1, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: stripHeight * 0.12)
                        .fill(Color.white.opacity(0.12))
                        .frame(width: stripHeight * 0.4, height: stripHeight * 0.55)
                }
            }
            .padding(.horizontal, stripHeight * 0.3)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
        }
        .frame(height: stripHeight)
        .background(Color(white: 0.09))
    }
}

struct FujiFilmStripTemplate_Previews: PreviewProvider {
    static var previews: some View {
        FujiFilmStripTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
