import SwiftUI

// Warm journal-style frame for lifestyle / Xiaohongshu posts.
struct SoftJournalTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var pad: CGFloat { max(image.size.width * 0.055, 28) }
    private var titleSize: CGFloat { max(image.size.width * 0.030, 16) }
    private var bodySize: CGFloat { max(image.size.width * 0.020, 11) }

    var body: some View {
        VStack(spacing: pad * 0.42) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: pad * 0.34, style: .continuous))
                .padding(.top, pad)
                .padding(.horizontal, pad)

            VStack(spacing: pad * 0.18) {
                Text("a quiet little moment")
                    .font(.system(size: titleSize, weight: .semibold, design: .serif))
                    .foregroundColor(Color(red: 0.22, green: 0.18, blue: 0.14))
                Text(metaLine)
                    .font(.system(size: bodySize, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(red: 0.46, green: 0.39, blue: 0.32))
            }
            .padding(.bottom, pad * 0.9)
        }
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.968, green: 0.937, blue: 0.878))
    }

    private var metaLine: String {
        [meta.dateText, meta.placeName ?? "Shanghai", meta.focalLengthText]
            .compactMap { $0 }
            .joined(separator: " / ")
    }
}

struct SoftJournalTemplate_Previews: PreviewProvider {
    static var previews: some View {
        SoftJournalTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
