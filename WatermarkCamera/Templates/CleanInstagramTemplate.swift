import SwiftUI

// Minimal Instagram-style white border with tiny account/date caption.
struct CleanInstagramTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var pad: CGFloat { max(image.size.width * 0.065, 34) }
    private var captionSize: CGFloat { max(image.size.width * 0.020, 11) }

    var body: some View {
        VStack(spacing: pad * 0.42) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top, pad)
                .padding(.horizontal, pad)

            HStack {
                Text("@lumaframe")
                    .font(.system(size: captionSize, weight: .semibold, design: .rounded))
                Spacer()
                Text(meta.dateText ?? "25 MAY 2026")
                    .font(.system(size: captionSize, weight: .regular, design: .monospaced))
            }
            .foregroundColor(Color(white: 0.20))
            .padding(.horizontal, pad)
            .padding(.bottom, pad * 0.75)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

struct CleanInstagramTemplate_Previews: PreviewProvider {
    static var previews: some View {
        CleanInstagramTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
