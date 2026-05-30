import SwiftUI

// Minimal Leica white-space frame: thin photo margin, quiet bottom space, centered red logo.
struct LeicaWhiteSpaceTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var isPortrait: Bool { image.size.height > image.size.width * 1.08 }
    private var edgeInset: CGFloat { max(image.size.width * 0.010, 8) }
    private var bottomHeight: CGFloat {
        let ratio = isPortrait ? 0.100 : 0.056
        return max(image.size.width * ratio, 58)
    }
    private var logoSize: CGFloat { max(image.size.width * 0.038, 28) }

    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay(
                    Rectangle()
                        .stroke(Color.black.opacity(0.045), lineWidth: 1)
                )
                .padding(.horizontal, edgeInset)
                .padding(.top, edgeInset)

            ZStack {
                Image("brand_leica")
                    .resizable()
                    .scaledToFit()
                    .frame(width: logoSize, height: logoSize)
            }
            .frame(maxWidth: .infinity)
            .frame(height: bottomHeight)
        }
        .background(Color(red: 0.985, green: 0.982, blue: 0.973))
    }
}

struct LeicaWhiteSpaceTemplate_Previews: PreviewProvider {
    static var previews: some View {
        LeicaWhiteSpaceTemplate(
            image: UIImage(named: "sample_mountain") ?? UIImage(systemName: "photo")!,
            meta: .preview
        )
        .frame(width: 600)
    }
}
