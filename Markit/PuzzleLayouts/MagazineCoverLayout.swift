import SwiftUI

/// 杂志封面：大图 hero + 衬线大标题压底，下面两张小图，页脚刊号 / 日期。
/// 很有 ins / 小红书"封面感"。3 张照片。
struct MagazineCoverLayout: View {
    let images: [UIImage]
    let options: PuzzleOptions

    private func img(_ i: Int) -> UIImage? { i < images.count ? images[i] : nil }

    private var masthead: String {
        options.caption.isEmpty ? "MOMENTS" : options.caption.uppercased()
    }

    private var dateText: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM"
        return f.string(from: Date())
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let margin = w * 0.05
            let gap = w * 0.022
            let content = h - margin * 2
            let heroH = content * 0.60
            let smallH = content * 0.30

            VStack(spacing: gap) {
                // Hero + masthead
                ZStack(alignment: .bottomLeading) {
                    fill(img(0))
                        .frame(width: w - margin * 2, height: heroH)
                        .clipped()
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.55)],
                        startPoint: .center, endPoint: .bottom
                    )
                    VStack(alignment: .leading, spacing: w * 0.012) {
                        Text(masthead)
                            .font(.system(size: w * 0.115, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Text("PHOTO JOURNAL · \(dateText)")
                            .font(.system(size: w * 0.026, weight: .semibold))
                            .tracking(w * 0.004)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(w * 0.045)
                }
                .frame(height: heroH)
                .clipShape(RoundedRectangle(cornerRadius: w * 0.012, style: .continuous))

                // Two small photos
                HStack(spacing: gap) {
                    fill(img(1)).frame(maxWidth: .infinity)
                    fill(img(2)).frame(maxWidth: .infinity)
                }
                .frame(height: smallH)
                .clipShape(RoundedRectangle(cornerRadius: w * 0.012, style: .continuous))

                // Footer
                HStack {
                    Text("EDITION Nº 01")
                    Spacer()
                    Text("SHOT ON FILM")
                }
                .font(.system(size: w * 0.024, weight: .semibold, design: .monospaced))
                .tracking(w * 0.003)
                .foregroundColor(Color(white: 0.35))
            }
            .padding(margin)
            .frame(width: w, height: h)
            .background(Color(red: 0.97, green: 0.965, blue: 0.952))
        }
        .aspectRatio(options.aspect.value, contentMode: .fit)
    }

    @ViewBuilder
    private func fill(_ image: UIImage?) -> some View {
        if let image {
            Image(uiImage: image).resizable().scaledToFill()
        } else {
            Color(white: 0.85)
        }
    }
}

struct MagazineCoverLayout_Previews: PreviewProvider {
    static var previews: some View {
        let s = UIImage(named: "sample_mountain") ?? UIImage(systemName: "photo")!
        MagazineCoverLayout(images: [s, s, s], options: PuzzleOptions())
            .frame(width: 360, height: 480)
    }
}
