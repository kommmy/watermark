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
            title: "徕卡水印",
            subtitle: "4 个徕卡样式，自动读取照片参数",
            destination: .watermark,
            items: WatermarkTemplate.leicaTemplates.map { .watermark($0) }
        ),
        BrowseSection(
            id: "camera-vs-photo",
            title: "徕卡相机拼图",
            subtitle: "取景框里是照片，下方是成片",
            destination: .puzzle,
            items: [
                .puzzle(.cameraDetail)
            ]
        )
    ]

    static let watermarkSections: [BrowseSection] = [
        BrowseSection(
            id: "leica",
            title: "徕卡水印",
            subtitle: "选择一张照片，自动读取 ISO、光圈、快门和机型",
            destination: .watermark,
            items: WatermarkTemplate.leicaTemplates.map { .watermark($0) }
        )
    ]

    static let puzzleSections: [BrowseSection] = [
        BrowseSection(
            id: "leica-camera",
            title: "徕卡相机拼图",
            subtitle: "上方徕卡相机取景框嵌入照片，下方展示原片",
            destination: .puzzle,
            items: [
                .puzzle(.cameraDetail)
            ]
        )
    ]
}
