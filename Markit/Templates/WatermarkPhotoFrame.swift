import SwiftUI

struct WatermarkPhotoFrame: View {
    let image: UIImage
    var cornerRadius: CGFloat = 0
    var borderColor: Color = Color.black.opacity(0.10)
    var lineWidth: CGFloat = 1
    var shadowColor: Color = .clear
    var shadowRadius: CGFloat = 0
    var shadowY: CGFloat = 0

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: lineWidth)
            )
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
    }
}
