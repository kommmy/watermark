import SwiftUI

/// 4 puzzle layouts. IDs are aligned with docs/script.js LAYOUTS to keep
/// iOS app and Web demo in lockstep.
enum PuzzleLayout: String, CaseIterable, Identifiable, Hashable {
    case vertical2
    case horizontal2
    case grid4
    case cameraDetail
    case cameraDetailQ3
    case polaroidStack
    case filmStrip
    case magazineCover

    static let allCases: [PuzzleLayout] = [
        .cameraDetail, .cameraDetailQ3, .polaroidStack, .filmStrip, .magazineCover
    ]

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .vertical2:    return L10n.text("上下双图")
        case .horizontal2:  return L10n.text("左右对比")
        case .grid4:        return L10n.text("四宫格")
        case .cameraDetail: return L10n.text("经典相机拼图")
        case .cameraDetailQ3: return L10n.text("轻便相机拼图")
        case .polaroidStack: return L10n.text("拍立得散落")
        case .filmStrip:    return L10n.text("胶片条")
        case .magazineCover: return L10n.text("杂志封面")
        }
    }

    var slotCount: Int {
        switch self {
        case .vertical2, .horizontal2: return 2
        case .cameraDetail, .cameraDetailQ3: return 1
        case .grid4: return 4
        case .polaroidStack, .filmStrip, .magazineCover: return 3
        }
    }

    var hint: String {
        switch self {
        case .vertical2:    return L10n.text("主图与细节")
        case .horizontal2:  return L10n.text("前后对比")
        case .grid4:        return L10n.text("照片系列")
        case .cameraDetail: return L10n.text("取景框 + 成片")
        case .cameraDetailQ3: return L10n.text("取景框 + 成片")
        case .polaroidStack: return L10n.text("随手拼贴")
        case .filmStrip:    return L10n.text("复古胶片")
        case .magazineCover: return L10n.text("封面感")
        }
    }

    @ViewBuilder
    func makeView(images: [UIImage], options: PuzzleOptions) -> some View {
        switch self {
        case .vertical2:    Vertical2Layout(images: images, options: options)
        case .horizontal2:  Horizontal2Layout(images: images, options: options)
        case .grid4:        Grid4Layout(images: images, options: options)
        case .cameraDetail: CameraDetailLayout(images: images, options: options, camera: .m11)
        case .cameraDetailQ3: CameraDetailLayout(images: images, options: options, camera: .q3)
        case .polaroidStack: PolaroidStackLayout(images: images, options: options)
        case .filmStrip:    FilmStripLayout(images: images, options: options)
        case .magazineCover: MagazineCoverLayout(images: images, options: options)
        }
    }
}

struct PuzzleOptions {
    enum Background: String, CaseIterable, Identifiable {
        case white, black, warm, gradient
        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .white:    return L10n.text("白色")
            case .black:    return L10n.text("黑色")
            case .warm:     return L10n.text("暖色")
            case .gradient: return L10n.text("渐变")
            }
        }
    }

    enum Ratio: String, CaseIterable, Identifiable {
        case r3_4    // swiftlint:disable:this identifier_name
        case r1_1    // swiftlint:disable:this identifier_name
        case r4_5    // swiftlint:disable:this identifier_name
        case r9_16   // swiftlint:disable:this identifier_name

        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .r3_4:  return "3:4"
            case .r1_1:  return "1:1"
            case .r4_5:  return "4:5"
            case .r9_16: return "9:16"
            }
        }
        /// width / height
        var value: CGFloat {
            switch self {
            case .r3_4:  return 3.0 / 4.0
            case .r1_1:  return 1.0
            case .r4_5:  return 4.0 / 5.0
            case .r9_16: return 9.0 / 16.0
            }
        }
    }

    var aspect: Ratio = .r3_4
    var background: Background = .white
    var caption: String = ""
    var gap: CGFloat = 8
}

extension PuzzleOptions.Background {
    @ViewBuilder
    var view: some View {
        switch self {
        case .white: Color.white
        case .black: Color.black
        case .warm:  Color(red: 0.965, green: 0.937, blue: 0.890)
        case .gradient:
            LinearGradient(
                colors: [
                    Color(red: 0.996, green: 0.953, blue: 0.882),
                    Color(red: 1.0,   green: 0.831, blue: 0.678)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }
    var captionColor: Color {
        switch self {
        case .white, .warm, .gradient: return Color(white: 0.2)
        case .black: return Color(white: 0.9)
        }
    }
}
