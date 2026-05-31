import SwiftUI

/// 全 App 共用的设计 token。所有 View 都通过这里的常量来取色/字号/圆角，
/// 不要硬编码。改主题只需改这一个文件。
enum AppTheme {

    // MARK: - Colors

    enum Palette {
        /// 主背景：接近相纸的暖白。
        static let background = Color(hex: 0xF8F6F1)
        /// 一级卡片背景
        static let card       = Color(hex: 0xFFFFFF)
        /// 二级卡片 / 输入框 / chip 背景
        static let surface    = Color(hex: 0xECE9E2)
        /// 选中态 / 高亮卡片
        static let elevated   = Color(hex: 0xDEDAD1)
        /// 编辑页预览背板：暖调深炭灰，让成片浮起又不像纯黑那样和米白主题割裂。
        static let previewBackdrop = Color(hex: 0x201C18)

        /// 主要文字
        static let textPrimary    = Color(hex: 0x171717)
        /// 次要文字
        static let textSecondary  = Color.black.opacity(0.58)
        /// 弱化文字
        static let textTertiary   = Color.black.opacity(0.34)

        /// PRO 橙
        static let proOrange   = Color(hex: 0xFF8A3D)
        /// 系统蓝（iOS Tint）
        static let accentBlue  = Color(hex: 0x0A84FF)
        /// 危险红
        static let danger      = Color(hex: 0xFF453A)

        /// 分隔线
        static let separator   = Color.black.opacity(0.08)
    }

    // MARK: - Radius

    enum Radius {
        static let small: CGFloat   = 8
        static let medium: CGFloat  = 12
        static let card: CGFloat    = 18
        static let large: CGFloat   = 24
        static let capsule: CGFloat = 999
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat  = 4
        static let s: CGFloat   = 8
        static let m: CGFloat   = 12
        static let l: CGFloat   = 16
        static let xl: CGFloat  = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - Typography

    enum Font {
        static let largeTitle   = SwiftUI.Font.system(size: 34, weight: .bold, design: .default)
        static let title        = SwiftUI.Font.system(size: 24, weight: .semibold, design: .default)
        static let sectionTitle = SwiftUI.Font.system(size: 20, weight: .semibold, design: .default)
        static let body         = SwiftUI.Font.system(size: 15, weight: .regular, design: .default)
        static let bodyBold     = SwiftUI.Font.system(size: 15, weight: .semibold, design: .default)
        static let small        = SwiftUI.Font.system(size: 13, weight: .regular, design: .default)
        static let caption      = SwiftUI.Font.system(size: 11, weight: .regular, design: .default)
        static let mono         = SwiftUI.Font.system(size: 13, weight: .medium, design: .monospaced)
    }

    // MARK: - Shadow

    enum Shadow {
        static let card = (color: Color.black.opacity(0.10), radius: CGFloat(14), x: CGFloat(0), y: CGFloat(8))
        static let elevated = (color: Color.black.opacity(0.16), radius: CGFloat(22), x: CGFloat(0), y: CGFloat(12))
    }
}

// MARK: - Color hex init

extension Color {
    /// 0xRRGGBB 形式初始化，不支持 alpha；要带 alpha 用 `.opacity(_:)`。
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
