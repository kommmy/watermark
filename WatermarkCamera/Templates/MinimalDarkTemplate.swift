import SwiftUI

// Minimal Dark: a single thin black bar, white text. Good for night shots.
struct MinimalDarkTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var barHeight: CGFloat { max(image.size.height * 0.05, 28) }

    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)

            HStack(spacing: 10) {
                if let model = preferredModel {
                    Text(model)
                        .font(.system(size: barHeight * 0.34, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 1, height: barHeight * 0.4)
                }
                Text(infoLine)
                    .font(.system(size: barHeight * 0.30, weight: .light, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            .padding(.horizontal, barHeight * 0.4)
            .frame(maxWidth: .infinity)
            .frame(height: barHeight)
            .background(Color.black)
        }
    }

    private var preferredModel: String? {
        if let m = meta.cameraModel, !m.isEmpty { return m }
        let brand = meta.brand.displayName
        return brand.isEmpty ? nil : brand
    }

    private var infoLine: String {
        [meta.focalLengthText, meta.apertureText, meta.shutter, meta.isoText, meta.dateText]
            .compactMap { $0 }
            .joined(separator: "  -  ")
    }
}

struct MinimalDarkTemplate_Previews: PreviewProvider {
    static var previews: some View {
        MinimalDarkTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
