import SwiftUI

// Editorial cover overlay for striking Xiaohongshu cover images.
struct MagazineCoverTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var unit: CGFloat { max(min(image.size.width, image.size.height) * 0.026, 16) }

    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)

            LinearGradient(
                colors: [.black.opacity(0.42), .clear, .black.opacity(0.38)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading) {
                Text("LUMA JOURNAL")
                    .font(.system(size: unit * 1.25, weight: .black, design: .serif))
                    .tracking(unit * 0.10)
                    .foregroundColor(.white)

                Text("WEEKEND NOTES")
                    .font(.system(size: unit * 0.48, weight: .medium, design: .monospaced))
                    .tracking(unit * 0.12)
                    .foregroundColor(.white.opacity(0.82))

                Spacer()

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: unit * 0.14) {
                        Text("No. 025")
                            .font(.system(size: unit * 0.56, weight: .semibold, design: .monospaced))
                        Text(meta.placeName ?? "Shanghai")
                            .font(.system(size: unit * 0.88, weight: .semibold, design: .serif))
                    }
                    Spacer()
                    Text(meta.paramsLine)
                        .font(.system(size: unit * 0.46, weight: .medium, design: .monospaced))
                        .lineLimit(1)
                }
                .foregroundColor(.white)
            }
            .padding(unit * 1.2)
        }
    }
}

struct MagazineCoverTemplate_Previews: PreviewProvider {
    static var previews: some View {
        MagazineCoverTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
