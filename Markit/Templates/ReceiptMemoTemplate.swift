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
            WatermarkPhotoFrame(
                image: image,
                borderColor: Color.black.opacity(0.08),
                shadowColor: Color.black.opacity(0.10),
                shadowRadius: 8,
                shadowY: 3
            )

            VStack(spacing: pad * 0.28) {
                Text("光影小票")
                    .font(.system(size: titleSize, weight: .bold, design: .monospaced))
                    .tracking(titleSize * 0.10)
                    .foregroundColor(Color(white: 0.12))

                dashedLine

                receiptRow("日期", meta.dateText ?? "2026.05.25")
                receiptRow("相机", meta.cameraDisplayName)
                receiptRow("参数", meta.paramsLine)

                dashedLine

                Text("感谢这次回忆")
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
            Text(L10n.text(key))
                .font(.system(size: rowSize, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(white: 0.25))
            Spacer()
            Text(L10n.text(value))
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
