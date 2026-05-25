import SwiftUI

// Polaroid instant frame: thick white border + handwritten title + tiny mono params.
struct PolaroidTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var paddingSide: CGFloat { max(image.size.width * 0.045, 24) }
    private var paddingBottom: CGFloat { max(image.size.width * 0.12, 60) }
    private var captionSize: CGFloat { max(image.size.width * 0.048, 24) }
    private var paramSize: CGFloat { max(image.size.width * 0.022, 12) }

    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)
                .padding(.top, paddingSide)
                .padding(.horizontal, paddingSide)

            VStack(spacing: paddingSide * 0.18) {
                Text(meta.cameraModel ?? "untitled")
                    .font(.custom("Snell Roundhand", size: captionSize))
                    .foregroundColor(Color(white: 0.13))
                    .lineLimit(1)
                Text(meta.dateText ?? "")
                    .font(.system(size: paramSize, design: .monospaced))
                    .foregroundColor(Color(white: 0.45))
                    .lineLimit(1)
            }
            .padding(.top, paddingSide * 0.6)
            .padding(.bottom, paddingBottom)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

struct PolaroidTemplate_Previews: PreviewProvider {
    static var previews: some View {
        PolaroidTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
