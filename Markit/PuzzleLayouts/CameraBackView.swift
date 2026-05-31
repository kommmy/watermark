import SwiftUI

/// 可插拔的相机背板：M11 用实拍透明图,Q3 用矢量绘制。
/// 照片画在屏幕区域之上(实心屏幕/实心背板,不依赖透明抠洞)。
enum CameraBackModel: String, Hashable {
    case m11
    case q3

    var displayName: String {
        switch self {
        case .m11: return "徕卡 M11"
        case .q3:  return "徕卡 Q3"
        }
    }

    /// 背板宽高比 (width / height)。
    var bodyAspect: CGFloat {
        switch self {
        case .m11: return 1.6233          // 1284 / 791,实拍图实测
        case .q3:  return 1.6224          // 696 / 429,去背后补足留白使相机与 M11 等大
        }
    }

    /// LCD 玻璃区,相对背板的比例 (x, y, w, h)。
    var lcdRect: CGRect {
        switch self {
        case .m11: return CGRect(x: 395.0 / 1284, y: 263.0 / 791,
                                 width: 447.0 / 1284, height: 339.0 / 791)
        case .q3:  return CGRect(x: 152.0 / 696, y: 177.0 / 429,
                                 width: 248.0 / 696, height: 166.0 / 429)
        }
    }
}

struct CameraBackView: View {
    let model: CameraBackModel
    var image: UIImage?

    var body: some View {
        Color.clear
            .aspectRatio(model.bodyAspect, contentMode: .fit)
            .overlay(alignment: .topLeading) {
                GeometryReader { geo in
                    ZStack(alignment: .topLeading) {
                        cameraBody(size: geo.size)
                        screenPhoto(in: geo.size)
                    }
                }
            }
            // Grounded contact shadow so the camera sits on the page.
            .shadow(color: Color.black.opacity(0.22), radius: 18, x: 0, y: 12)
    }

    @ViewBuilder
    private func cameraBody(size: CGSize) -> some View {
        switch model {
        case .m11:
            Image("camera_m11_back")
                .resizable()
                .scaledToFit()
                .frame(width: size.width, height: size.height)
        case .q3:
            Image("camera_q3_back")
                .resizable()
                .scaledToFit()
                .frame(width: size.width, height: size.height)
        }
    }

    @ViewBuilder
    private func screenPhoto(in size: CGSize) -> some View {
        let w = size.width
        let h = size.height
        let r = model.lcdRect
        let bleed = w * 0.004
        let screenW = w * r.width + bleed * 2
        let screenH = h * r.height + bleed * 2

        ZStack {
            Color.black
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenW, height: screenH)
            }
        }
        .frame(width: screenW, height: screenH)
        .clipShape(RoundedRectangle(cornerRadius: w * 0.008, style: .continuous))
        .offset(x: w * r.minX - bleed, y: h * r.minY - bleed)
    }
}
