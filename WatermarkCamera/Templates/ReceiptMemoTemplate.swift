import SwiftUI

// Cafe receipt memo: useful for food, coffee, shop visits and daily logs.
struct ReceiptMemoTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var pad: CGFloat { max(image.size.width * 0.045, 24) }
    private var rowSize: CGFloat { max(image.size.width * 0.022, 12) }
    private var titleSize: CGFloat { max(image.size.width * 0.032, 17) }

    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)

            VStack(spacing: pad * 0.28) {
                Text("LUMA CAFE")
                    .font(.system(size: titleSize, weight: .bold, design: .monospaced))
                    .tracking(titleSize * 0.10)
                    .foregroundColor(Color(white: 0.12))

                dashedLine

                receiptRow("DATE", meta.dateText ?? "2026.05.25")
                receiptRow("MOOD", "SUNNY")
                receiptRow("SHOT", meta.paramsLine.isEmpty ? "35MM / FILM" : meta.paramsLine)

                dashedLine

                Text("THANK YOU FOR THE MEMORY")
                    .font(.system(size: rowSize * 0.82, weight: .medium, design: .monospaced))
                    .tracking(rowSize * 0.08)
                    .foregroundColor(Color(white: 0.42))
            }
            .padding(pad)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.980, green: 0.956, blue: 0.905))
        }
    }

    private var dashedLine: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 1)
            .overlay(
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 5]))
                    .foregroundColor(Color.black.opacity(0.22))
            )
    }

    private func receiptRow(_ key: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(key)
                .font(.system(size: rowSize, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(white: 0.25))
            Spacer()
            Text(value)
                .font(.system(size: rowSize, weight: .regular, design: .monospaced))
                .foregroundColor(Color(white: 0.18))
                .lineLimit(1)
        }
    }
}

struct ReceiptMemoTemplate_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptMemoTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
