import Foundation

enum L10n {
    static func text(_ key: String) -> String {
        NSLocalizedString(key, bundle: .main, value: key, comment: "")
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), locale: Locale.current, arguments: arguments)
    }

    static func photoCount(_ count: Int) -> String {
        if usesEnglish {
            return "\(count) \(count == 1 ? "photo" : "photos")"
        }
        return "\(count) 张照片"
    }

    static func photoCountHint(_ count: Int, hint: String) -> String {
        "\(photoCount(count)) · \(hint)"
    }

    static func photoCollageLabel(_ count: Int) -> String {
        if usesEnglish { return "\(photoCount(count)) collage" }
        return "\(count) 张照片拼图"
    }

    static func collageTitle(slotCount: Int) -> String {
        if usesEnglish { return "Collage · \(photoCount(slotCount))" }
        return "拼图 · \(slotCount) 张"
    }

    static func remainingPhotos(_ count: Int) -> String {
        if usesEnglish { return "\(count) more \(count == 1 ? "photo" : "photos")" }
        return "还需 \(count) 张"
    }

    private static var usesEnglish: Bool {
        Bundle.main.preferredLocalizations.first?.hasPrefix("en") == true
    }
}
