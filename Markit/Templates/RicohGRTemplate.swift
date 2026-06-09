import SwiftUI

// Ricoh GR III style: minimal black bar + boxed GR logo + monospaced params.
struct RicohGRTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var barHeight: CGFloat { max(image.size.height * 0.085, 44) }

    var body: some View {
        VStack(spacing: 0) {
            WatermarkPhotoFrame(
                image: image,
                borderColor: Color.white.opacity(0.10),
                shadowColor: Color.black.opacity(0.25),
                shadowRadius: 8,
                shadowY: 3
            )

            HStack(spacing: barHeight * 0.3) {
                Image("brand_ricoh")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: barHeight * 1.65, height: barHeight * 0.30, alignment: .leading)

                VStack(alignment: .leading, spacing: barHeight * 0.04) {
                    Text(L10n.text(meta.cameraDisplayName == "未知相机" ? "RICOH GR III" : meta.cameraDisplayName))
                        .font(.system(size: barHeight * 0.26, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    if !meta.lensDisplayName.isEmpty {
                        Text(meta.lensDisplayName)
                            .font(.system(size: barHeight * 0.16))
                            .foregroundColor(.white.opacity(0.55))
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: barHeight * 0.04) {
                    Text(meta.paramsLine)
                        .font(.system(size: barHeight * 0.22, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    if let date = meta.dateText {
                        Text(date)
                            .font(.system(size: barHeight * 0.16, design: .monospaced))
                            .foregroundColor(.white.opacity(0.55))
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, barHeight * 0.4)
            .frame(height: barHeight)
            .frame(maxWidth: .infinity)
            .background(Color.black)
        }
    }
}

struct RicohGRTemplate_Previews: PreviewProvider {
    static var previews: some View {
        RicohGRTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
