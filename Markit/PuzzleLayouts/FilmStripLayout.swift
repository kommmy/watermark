import SwiftUI

/// 胶片条：深色 35mm 胶片机身，两侧打孔，中间 3 帧照片，带暖色漏光。
/// 复古 ins 风。
struct FilmStripLayout: View {
    let images: [UIImage]
    let options: PuzzleOptions

    private func img(_ i: Int) -> UIImage? { i < images.count ? images[i] : nil }
    private let body07 = Color(white: 0.07)

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let sprocketW = w * 0.105
            let frameGap = h * 0.014

            ZStack {
                body07

                HStack(spacing: 0) {
                    sprockets(width: sprocketW, height: h)
                    VStack(spacing: frameGap) {
                        ForEach(0..<3, id: \.self) { i in
                            frame(img(i), index: i)
                        }
                    }
                    .padding(.vertical, h * 0.022)
                    .padding(.horizontal, w * 0.016)
                    sprockets(width: sprocketW, height: h)
                }

                // 暖色漏光
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.55, blue: 0.2).opacity(0.22), .clear],
                    startPoint: .topTrailing, endPoint: .center
                )
                .blendMode(.screen)
                .allowsHitTesting(false)
            }
            .frame(width: w, height: h)
            .clipped()
        }
        .aspectRatio(options.aspect.value, contentMode: .fit)
    }

    private func frame(_ image: UIImage?, index: Int) -> some View {
        GeometryReader { g in
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let image {
                        Image(uiImage: image).resizable().scaledToFill()
                    } else {
                        Color(white: 0.16)
                    }
                }
                .frame(width: g.size.width, height: g.size.height)
                .clipped()

                Text(String(format: "%02d", index * 6 + 5) + "A")
                    .font(.system(size: g.size.height * 0.12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.62, blue: 0.2))
                    .padding(g.size.height * 0.06)
                    .shadow(color: .black.opacity(0.6), radius: 2)
            }
        }
    }

    private func sprockets(width: CGFloat, height: CGFloat) -> some View {
        let hole = width * 0.5
        let count = max(Int(height / (hole * 1.85)), 4)
        let spacing = (height - CGFloat(count) * hole) / CGFloat(count)
        return VStack(spacing: spacing) {
            ForEach(0..<count, id: \.self) { _ in
                RoundedRectangle(cornerRadius: hole * 0.28, style: .continuous)
                    .fill(Color(white: 0.93))
                    .frame(width: hole, height: hole)
            }
        }
        .frame(width: width, height: height)
        .padding(.vertical, spacing / 2)
    }
}

struct FilmStripLayout_Previews: PreviewProvider {
    static var previews: some View {
        let s = UIImage(named: "sample_mountain") ?? UIImage(systemName: "photo")!
        FilmStripLayout(images: [s, s, s], options: PuzzleOptions())
            .frame(width: 360, height: 480)
    }
}
