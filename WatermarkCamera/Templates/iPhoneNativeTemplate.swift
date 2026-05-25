import SwiftUI

// iPhone native style: white bar, single line "Shot on iPhone XX".
struct iPhoneNativeTemplate: View {
    let image: UIImage
    let meta: PhotoMetadata

    private var barHeight: CGFloat { max(image.size.height * 0.075, 40) }

    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)

            HStack(spacing: 6) {
                Image("brand_apple")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.black)
                    .frame(width: barHeight * 0.34, height: barHeight * 0.34)
                Text("Shot on ")
                    .font(.system(size: barHeight * 0.30, weight: .regular))
                    .foregroundColor(.black)
                Text(meta.cameraModel ?? "iPhone")
                    .font(.system(size: barHeight * 0.32, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: barHeight)
            .background(Color.white)
        }
    }
}

struct iPhoneNativeTemplate_Previews: PreviewProvider {
    static var previews: some View {
        iPhoneNativeTemplate(image: UIImage(systemName: "photo")!, meta: .preview)
            .frame(width: 600)
    }
}
