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
            title: "Watermarks",
            subtitle: "Real camera logos and metadata cards",
            destination: .watermark,
            items: [
                .watermark(.soft_journal),
                .watermark(.clean_instagram),
                .watermark(.magazine_cover),
                .watermark(.leica),
                .watermark(.fujifilm)
            ]
        ),
        BrowseSection(
            id: "camera-vs-photo",
            title: "Camera vs Photo",
            subtitle: "Pair gear details with the final shot",
            destination: .puzzle,
            items: [
                .puzzle(.cameraDetail),
                .puzzle(.horizontal2),
                .watermark(.ricoh_gr),
                .watermark(.iphone)
            ]
        ),
        BrowseSection(
            id: "minimal-frames",
            title: "Minimal Frames",
            subtitle: "Quiet borders for portraits and daily posts",
            destination: .watermark,
            items: [
                .watermark(.minimal),
                .watermark(.minimal_dark),
                .watermark(.polaroid),
                .watermark(.clean_instagram)
            ]
        ),
        BrowseSection(
            id: "film-vintage",
            title: "Film Vintage",
            subtitle: "Film strip, date stamp, instant print",
            destination: .watermark,
            items: [
                .watermark(.fuji_strip),
                .watermark(.date_stamp),
                .watermark(.polaroid),
                .watermark(.leica_mono)
            ]
        ),
        BrowseSection(
            id: "color-walk",
            title: "Color Walk",
            subtitle: "Warm journal layouts for Xiaohongshu",
            destination: .watermark,
            items: [
                .watermark(.soft_journal),
                .watermark(.receipt_memo),
                .watermark(.magazine_cover),
                .watermark(.hasselblad)
            ]
        ),
        BrowseSection(
            id: "free-collage",
            title: "Free Collage",
            subtitle: "Before/after, series and detail layouts",
            destination: .puzzle,
            items: PuzzleLayout.allCases.map { .puzzle($0) }
        )
    ]

    static let watermarkSections: [BrowseSection] = [
        BrowseSection(
            id: "editorial",
            title: "Editorial & Lifestyle",
            subtitle: "Soft, magazine and Instagram-friendly cards",
            destination: .watermark,
            items: [
                .watermark(.soft_journal),
                .watermark(.clean_instagram),
                .watermark(.magazine_cover),
                .watermark(.receipt_memo)
            ]
        ),
        BrowseSection(
            id: "camera-brands",
            title: "Camera Logos",
            subtitle: "Leica, Fuji, Sony, Ricoh and Hasselblad styles",
            destination: .watermark,
            items: [
                .watermark(.leica),
                .watermark(.leica_mono),
                .watermark(.fujifilm),
                .watermark(.sony),
                .watermark(.hasselblad),
                .watermark(.ricoh_gr),
                .watermark(.iphone)
            ]
        ),
        BrowseSection(
            id: "frames",
            title: "Borders",
            subtitle: "Minimal white space, dark frame and instant print",
            destination: .watermark,
            items: [
                .watermark(.minimal),
                .watermark(.minimal_dark),
                .watermark(.polaroid),
                .watermark(.clean_instagram)
            ]
        ),
        BrowseSection(
            id: "film",
            title: "Film & Retro",
            subtitle: "Film strip and date stamp looks",
            destination: .watermark,
            items: [
                .watermark(.fuji_strip),
                .watermark(.date_stamp),
                .watermark(.polaroid)
            ]
        )
    ]

    static let puzzleSections: [BrowseSection] = [
        BrowseSection(
            id: "before-after",
            title: "Before After",
            subtitle: "Compare two frames clearly",
            destination: .puzzle,
            items: [
                .puzzle(.horizontal2),
                .puzzle(.vertical2)
            ]
        ),
        BrowseSection(
            id: "camera-photo",
            title: "Camera vs Photo",
            subtitle: "Show the camera and the final image together",
            destination: .puzzle,
            items: [
                .puzzle(.cameraDetail),
                .puzzle(.vertical2)
            ]
        ),
        BrowseSection(
            id: "series",
            title: "Photo Series",
            subtitle: "Build a small story from multiple images",
            destination: .puzzle,
            items: [
                .puzzle(.grid4),
                .puzzle(.vertical2),
                .puzzle(.horizontal2)
            ]
        )
    ]
}
