import Foundation

enum BrowseItem: Identifiable, Hashable {
    case watermark(WatermarkTemplate)
    case puzzle(PuzzleLayout)

    var id: String {
        switch self {
        case .watermark(let template): return "watermark-\(template.id)"
        case .puzzle(let layout): return "puzzle-\(layout.id)"
        }
    }
}

struct BrowseSection: Identifiable, Hashable {
    enum Destination: Hashable {
        case watermark
        case puzzle
    }

    let id: String
    let title: String
    let subtitle: String
    let destination: Destination
    let items: [BrowseItem]
}

enum BrowseCatalog {
    static let discoverSections: [BrowseSection] = [
        BrowseSection(
            id: "watermark",
            title: L10n.text("照片水印"),
            subtitle: L10n.text("自动读取照片参数，生成干净作品卡"),
            destination: .watermark,
            items: WatermarkTemplate.leicaTemplates.map { .watermark($0) }
        ),
        BrowseSection(
            id: "camera-vs-photo",
            title: L10n.text("相机拼图"),
            subtitle: L10n.text("取景框里是照片，下方是成片"),
            destination: .puzzle,
            items: [
                .puzzle(.cameraDetail)
            ]
        )
    ]

    static let watermarkSections: [BrowseSection] = [
        BrowseSection(
            id: "photo-watermark",
            title: L10n.text("照片水印"),
            subtitle: L10n.text("选择一张照片，自动读取 ISO、光圈、快门和机型"),
            destination: .watermark,
            items: WatermarkTemplate.leicaTemplates.map { .watermark($0) }
        )
    ]

    static let puzzleSections: [BrowseSection] = [
        BrowseSection(
            id: "camera-collage",
            title: L10n.text("相机拼图"),
            subtitle: L10n.text("上方相机取景框嵌入照片，下方展示原片"),
            destination: .puzzle,
            items: [
                .puzzle(.cameraDetail),
                .puzzle(.cameraDetailQ3)
            ]
        ),
        BrowseSection(
            id: "creative-collage",
            title: L10n.text("小红书 / Ins 风"),
            subtitle: L10n.text("拍立得、胶片、杂志封面，几张照片拼成有质感的封面"),
            destination: .puzzle,
            items: [
                .puzzle(.polaroidStack),
                .puzzle(.filmStrip),
                .puzzle(.magazineCover)
            ]
        )
    ]
}
