import SwiftUI

// Date Stamp: orange Kodak-style date burned in the bottom right corner.
struct DateStampTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var fontSize: CGFloat { max(image.size.height * 0.038, 22) }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)

            Text(stampText)
                .font(.custom("Courier", size: fontSize).weight(.bold))
                .tracking(fontSize * 0.04)
                .foregroundColor(Color(red: 1.0, green: 0.71, blue: 0.21))
                .shadow(color: .black.opacity(0.6), radius: fontSize * 0.2, x: 0, y: 0)
                .shadow(color: .red.opacity(0.35), radius: fontSize * 0.3, x: 0, y: 0)
                .padding(.trailing, fontSize * 0.8)
                .padding(.bottom, fontSize * 0.8)
        }
    }

    private var stampText: String {
        if let date = meta.captureDate {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy MM dd"
            return fmt.string(from: date)
        }
        return "2026 05 25"
    }
}

struct DateStampTemplate_Previews: PreviewProvider {
    static var previews: some View {
        DateStampTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
