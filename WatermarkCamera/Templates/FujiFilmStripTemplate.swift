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
            Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)
            perforationStrip

            HStack(spacing: barHeight * 0.3) {
                Text("FUJIFILM \(meta.cameraModel ?? "")")
                    .font(.system(size: barHeight * 0.28, weight: .bold))
                    .tracking(barHeight * 0.04)
                    .foregroundColor(Color(white: 0.94))
                    .lineLimit(1)
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
