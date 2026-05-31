import SwiftUI

/// 拍立得散落：3 张照片做成宝丽来卡片，轻微旋转、错落叠放在暖色纸面上。
/// 很 ins / 小红书的随手拼贴感。
struct PolaroidStackLayout: View {
    let images: [UIImage]
    let options: PuzzleOptions

    private func img(_ i: Int) -> UIImage? { i < images.count ? images[i] : nil }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cardW = w * 0.52

            ZStack {
                // 暖色纸面 + 轻微暗角
                LinearGradient(
                    colors: [Color(red: 0.957, green: 0.933, blue: 0.886),
                             Color(red: 0.910, green: 0.871, blue: 0.804)],
                    startPoint: .top, endPoint: .bottom
                )
                RadialGradient(
                    colors: [.clear, Color.black.opacity(0.08)],
                    center: .center, startRadius: w * 0.25, endRadius: w * 0.78
                )

                polaroid(img(0), width: cardW)
                    .rotationEffect(.degrees(-9))
                    .offset(x: -w * 0.16, y: -h * 0.15)
                polaroid(img(1), width: cardW)
                    .rotationEffect(.degrees(7))
                    .offset(x: w * 0.17, y: -h * 0.015)
                polaroid(img(2), width: cardW)
                    .rotationEffect(.degrees(-4))
                    .offset(x: -w * 0.04, y: h * 0.17)

                if !options.caption.isEmpty {
                    VStack {
                        Spacer()
                        Text(options.caption)
                            .font(.system(size: w * 0.05, weight: .regular, design: .serif))
                            .italic()
                            .foregroundColor(Color(white: 0.25))
                            .padding(.bottom, h * 0.03)
                    }
                }
            }
            .frame(width: w, height: h)
            .clipped()
        }
        .aspectRatio(options.aspect.value, contentMode: .fit)
    }

    private func polaroid(_ image: UIImage?, width: CGFloat) -> some View {
        let frame = width * 0.055
        let bottom = width * 0.22
        let side = width - frame * 2
        return Group {
            if let image {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Color(white: 0.85)
            }
        }
        .frame(width: side, height: side)
        .clipped()
        .padding(EdgeInsets(top: frame, leading: frame, bottom: bottom, trailing: frame))
        .background(Color.white)
        .overlay(
            Rectangle().stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.24), radius: width * 0.04, x: 0, y: width * 0.022)
    }
}

struct PolaroidStackLayout_Previews: PreviewProvider {
    static var previews: some View {
        let s = UIImage(named: "sample_mountain") ?? UIImage(systemName: "photo")!
        PolaroidStackLayout(images: [s, s, s], options: PuzzleOptions())
            .frame(width: 360, height: 480)
    }
}
