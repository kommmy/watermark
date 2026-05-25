import SwiftUI

// Ricoh GR III style: minimal black bar + boxed GR logo + monospaced params.
struct RicohGRTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var barHeight: CGFloat { max(image.size.height * 0.085, 44) }

    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)

            HStack(spacing: barHeight * 0.3) {
                Text("GR")
                    .font(.system(size: barHeight * 0.34, weight: .heavy))
                    .tracking(barHeight * 0.04)
                    .foregroundColor(.white)
                    .padding(.horizontal, barHeight * 0.18)
                    .padding(.vertical, barHeight * 0.06)
                    .overlay(
                        Rectangle().stroke(Color.white, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: barHeight * 0.04) {
                    Text(meta.cameraModel ?? "RICOH GR III")
                        .font(.system(size: barHeight * 0.26, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    if let lens = meta.lensModel, !lens.isEmpty {
                        Text(lens)
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
