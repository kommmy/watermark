import SwiftUI

// Leica Mono: same layout as LeicaTemplate but black background with white text.
// Pairs well with low-key / night photography.
struct LeicaMonoTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var barHeight: CGFloat { max(image.size.height * 0.11, 56) }

    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)

            HStack(alignment: .center, spacing: 0) {
                HStack(spacing: barHeight * 0.22) {
                    Image("brand_leica")
                        .resizable()
                        .scaledToFit()
                        .frame(width: barHeight * 0.74, height: barHeight * 0.74)

                    VStack(alignment: .leading, spacing: barHeight * 0.05) {
                        Text(meta.cameraModel ?? meta.brand.displayName)
                            .font(.system(size: barHeight * 0.28, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        if let lens = meta.lensModel, !lens.isEmpty {
                            Text(lens)
                                .font(.system(size: barHeight * 0.16))
                                .foregroundColor(.white.opacity(0.55))
                                .lineLimit(1)
                        }
                    }
                }

                Spacer(minLength: barHeight * 0.3)

                Rectangle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 1, height: barHeight * 0.6)
                    .padding(.horizontal, barHeight * 0.2)

                VStack(alignment: .trailing, spacing: barHeight * 0.05) {
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
            .background(Color(white: 0.04))
        }
    }
}

struct LeicaMonoTemplate_Previews: PreviewProvider {
    static var previews: some View {
        LeicaMonoTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
