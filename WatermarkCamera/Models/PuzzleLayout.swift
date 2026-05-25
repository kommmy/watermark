import SwiftUI

/// 4 puzzle layouts. IDs are aligned with docs/script.js LAYOUTS to keep
/// iOS app and Web demo in lockstep.
enum PuzzleLayout: String, CaseIterable, Identifiable, Hashable {
    case vertical2
    case horizontal2
    case grid4
    case cameraDetail

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .vertical2:    return "Stacked"
        case .horizontal2:  return "Side by Side"
        case .grid4:        return "Grid 2x2"
        case .cameraDetail: return "Camera + Shot"
        }
    }

    var slotCount: Int {
        switch self {
        case .vertical2, .horizontal2, .cameraDetail: return 2
        case .grid4: return 4
        }
    }

    var hint: String {
        switch self {
        case .vertical2:    return "Wide + detail"
        case .horizontal2:  return "Before & after"
        case .grid4:        return "Series"
        case .cameraDetail: return "Signature look"
        }
    }

    @ViewBuilder
    func makeView(images: [UIImage], options: PuzzleOptions) -> some View {
        switch self {
        case .vertical2:    Vertical2Layout(images: images, options: options)
        case .horizontal2:  Horizontal2Layout(images: images, options: options)
        case .grid4:        Grid4Layout(images: images, options: options)
        case .cameraDetail: CameraDetailLayout(images: images, options: options)
        }
    }
}

struct PuzzleOptions {
    enum Background: String, CaseIterable, Identifiable {
        case white, black, warm, gradient
        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .white:    return "White"
            case .black:    return "Black"
            case .warm:     return "Warm"
            case .gradient: return "Gradient"
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
