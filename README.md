# markit

> iOS 相机风格水印 + 拼图 App，纯本地，无后端。
> 选图后自动读取 EXIF（机型/镜头/光圈/快门/ISO/日期/GPS），套用徕卡、富士、索尼、哈苏、理光、iPhone、文艺/Ins 风等 **16 套水印模板**；或挑 **4 种拼图布局** 拼多张图，一键保存到相册或分享。

[![iOS Build](https://github.com/kommmy/watermark/actions/workflows/ios-build.yml/badge.svg)](https://github.com/kommmy/watermark/actions/workflows/ios-build.yml)
[![Deploy Pages](https://github.com/kommmy/watermark/actions/workflows/deploy-pages.yml/badge.svg)](https://github.com/kommmy/watermark/actions/workflows/deploy-pages.yml)

> **在线预览** （iPhone 模拟外壳 + 实时编辑）：[kommmy.github.io/watermark](https://kommmy.github.io/watermark/)
> 浏览器中即可体验 16 套水印模板 + 4 种拼图布局，最终 iOS App 与 Web 设计语言一致。

## 功能总览

- **水印模块（16 套模板）**
  Leica White / Leica Mono / Fuji Dark / Fuji Film Strip / Sony Alpha / Hasselblad / Ricoh GR / iPhone Shot / Polaroid / Minimal Light / Minimal Dark / Date Stamp / Soft Journal / Clean Instagram / Magazine Cover / Receipt Memo。
- **拼图模块（4 种布局）**
  Stacked（上下二格）/ Side by Side（左右二格）/ Grid 2x2（田字四格）/ Camera + Shot（相机产品图 + 实拍）。
  每种布局支持 4 种比例（3:4 / 1:1 / 4:5 / 9:16）+ 4 种背景（白 / 黑 / 米 / 渐变）+ 自定义文字。
- **浏览与推荐**：Discover / Watermarks / Puzzles 按主题横向分组展示，包含 Watermarks、Camera vs Photo、Minimal Frames、Film Vintage、Color Walk、Free Collage 等入口。
- **友好交互**：浮动 `+` 快速创建、模板卡片直接拉起相册、拼图槽位逐张替换、选图 loading 反馈、底部内容避让浮动按钮。
- **首页 4 个 Tab**：Discover（推荐）/ Watermarks（水印）/ Puzzles（拼图）/ Me（我的），深色卡片风格。
- 全程本地处理，无任何网络请求。

## 环境要求

- macOS 13 + Xcode 15 及以上
- iOS 16.0+ 真机或模拟器
- Swift 5.9

## 运行方式

### 方式一：用 XcodeGen 生成工程（推荐）

仓库里没有 `.xcodeproj`，用 [XcodeGen](https://github.com/yonaskolb/XcodeGen) 一键生成：

```bash
brew install xcodegen
cd /path/to/this/repo
xcodegen
open Markit.xcodeproj
```

然后选一个 iOS 16+ 模拟器，Cmd+R 即可。

## 上架物料

App Store 上架草稿放在 `AppStoreAssets/`：

- `icon/markit-icon-1024.png`：1024x1024 App Store 图标。
- `screenshots/`：iPhone 6.9 / 6.5 / 5.5 英寸截图素材。
- `metadata/zh-Hans.md`：中文上架文案、关键词、审核备注、隐私选项。
- `metadata/en-US.md`：英文备用文案。
- `metadata/submission-checklist.md`：提交前检查清单。

隐私政策与支持页放在 `docs/privacy.html` 和 `docs/support.html`。

### 方式二：手动新建 Xcode 工程

1. Xcode > File > New > Project > iOS > App
2. Product Name 填 `Markit`，Interface 选 SwiftUI，Language 选 Swift，Minimum Deployments 选 iOS 16.0
3. 删除自动生成的 `ContentView.swift` 和 `<ProjectName>App.swift`
4. 把本仓库 `Markit/` 目录下的所有 `.swift` 文件、`Info.plist`、`Resources/Assets.xcassets` 全部拖入工程（选 Copy items if needed，加入 target）
5. Project Settings > Info > 把 `Info.plist` 指向拖入的那份
6. Cmd+R

## 目录结构

```
Markit/
├── App/
│   └── MarkitApp.swift              # @main 入口
├── Theme/
│   ├── AppTheme.swift               # 深色 token：色板/字号/圆角/阴影
│   └── ViewModifiers.swift          # .cardStyle() / .appBackground() / LoadingOverlay / 浮动创建按钮
├── Models/
│   ├── PhotoMetadata.swift          # EXIF 摘要 + 品牌识别
│   ├── WatermarkTemplate.swift      # 16 套水印枚举 + 工厂
│   ├── PuzzleLayout.swift           # 4 种拼图枚举 + PuzzleOptions
│   └── BrowseCatalog.swift          # Discover / 水印 / 拼图的主题分组配置
├── Services/
│   ├── ExifReader.swift             # ImageIO 解析 TIFF/EXIF/GPS
│   ├── ImageComposer.swift          # 水印 ImageRenderer
│   ├── PuzzleComposer.swift         # 拼图 ImageRenderer
│   ├── PhotoSaver.swift             # 写入相册（addOnly）
│   └── PlaceLookup.swift            # 可选：GPS 反查城市名
├── Templates/                       # 16 套水印 SwiftUI View
│   ├── LeicaTemplate.swift / LeicaMonoTemplate.swift
│   ├── FujiTemplate.swift / FujiFilmStripTemplate.swift
│   ├── SonyTemplate.swift / HasselbladTemplate.swift
│   ├── RicohGRTemplate.swift / iPhoneNativeTemplate.swift
│   ├── PolaroidTemplate.swift
│   ├── MinimalTemplate.swift / MinimalDarkTemplate.swift
│   ├── DateStampTemplate.swift
│   └── SoftJournalTemplate.swift / CleanInstagramTemplate.swift / MagazineCoverTemplate.swift / ReceiptMemoTemplate.swift
├── PuzzleLayouts/                   # 4 种拼图布局 View
│   ├── Vertical2Layout.swift / Horizontal2Layout.swift
│   ├── Grid4Layout.swift / CameraDetailLayout.swift
├── Views/
│   ├── HomeView.swift               # TabView 根
│   ├── Tabs/
│   │   ├── DiscoverTab.swift        # 推荐：banner + 主题横滑分组 + 快速创建
│   │   ├── WatermarkTab.swift       # 16 套水印按主题横滑分组
│   │   ├── PuzzleTab.swift          # 4 种拼图按场景横滑分组
│   │   └── MeTab.swift              # 我的
│   ├── Cards/
│   │   ├── TemplateCard.swift       # 水印封面卡片
│   │   └── PuzzleLayoutCard.swift   # 拼图封面卡片
│   ├── EditorView.swift             # 水印编辑器
│   ├── PuzzleEditorView.swift       # 拼图编辑器
│   ├── TemplateStrip.swift          # 横向 16 套模板选择条
│   └── MetadataEditorSheet.swift    # 手动覆盖 EXIF
├── Resources/
│   └── Assets.xcassets              # AppIcon / AccentColor / 真实品牌 logo
└── Info.plist
```

## 数据流

```
[ Watermark ]
PhotosPicker → Data → ExifReader → PhotoMetadata
                              ↘
                              UIImage → WatermarkTemplate.makeView(...)
                                        → ImageComposer.render (ImageRenderer)
                                        → PhotoSaver / UIActivityViewController

[ Puzzle ]
PhotosPicker × N → [UIImage] → PuzzleLayout.makeView(images:, options:)
                                        → PuzzleComposer.render (ImageRenderer)
                                        → PhotoSaver / UIActivityViewController
```

## 添加新水印模板

1. 在 `Templates/` 下新建 `<Name>Template.swift`，实现一个 `View`，签名是 `(image: UIImage, meta: PhotoMetadata)`。
2. 在 `Models/WatermarkTemplate.swift` 的 `enum WatermarkTemplate` 里加一个 `case`。
3. 在 `displayName` / `brandLabel` / `makeView(image:meta:)` 的 `switch` 里补对应分支。
4. 在 `Views/Cards/TemplateCard.swift` 的 `gradient` 与 `accentBar` 里补当前 case，让封面卡片有特色。
5. 在 `Views/TemplateStrip.swift` 的 `accentStrip(for:)` 里画一条小色带。
6. 在 `Models/BrowseCatalog.swift` 里把新模板加入合适的浏览分组。
7. 在 `docs/script.js` 的 `TEMPLATES` + `RENDERERS` 里加同名 id 的 Web 版本，保持双端一致。

模板内部坐标系约定：以 `image.size.width` 作为 1 像素单位（合成器把 View 宽度强制等于原图像素宽度，scale=1 渲染输出）。所有字号 / 留白用 `image.size.height * 0.xx` 表达，自动适配横竖图与不同像素分辨率。

## 添加新拼图布局

1. 在 `PuzzleLayouts/` 下新建 `<Name>Layout.swift`，签名 `(images: [UIImage], options: PuzzleOptions)`。
2. 在 `Models/PuzzleLayout.swift` 的 `enum` 与 `makeView` 里加一个 case。
3. 在 `Views/Cards/PuzzleLayoutCard.swift` 的 `cover` switch 里加封面 placeholder。
4. 在 `Models/BrowseCatalog.swift` 里把新布局加入合适的拼图/推荐分组。
5. 在 `docs/script.js` 的 `LAYOUTS` + `LAYOUT_RENDERERS` 里加同名 id 的 Web 版本。

## 品牌 logo

当前版本已经内置真实品牌 SVG logo：

1. iOS 端放在 `Resources/Assets.xcassets/brand_*.imageset`，模板里用 `Image("brand_leica")` / `Image("brand_sony")` 等直接引用。
2. Web 端放在 `docs/assets/logos/brand_*.svg`，`docs/script.js` 通过 `LOGO` 常量引用。
3. 新增品牌时两端保持同名，例如 `brand_nikon`，这样 Web 和 iOS 的模板 id 容易对齐。

> 当前按自用/演示处理真实 logo；如后续上架 App Store，再按实际发布需求调整。

## 已知限制

- **超大图内存**：`ImageRenderer` 在 5000 万像素图上会吃 300MB+ 内存；当前默认长边裁到 4096 像素再渲染（`ImageComposer.render(maxLongEdge:)` / `PuzzleComposer.render(maxLongEdge:)` 可调）。
- **RAW 兼容**：CGImageSource 支持 HEIC、DNG，但 Sony ARW / Canon CR3 等可能缺 `LensModel`，模板里已做 nil 兜底。
- **设备方向**：第一版只锁竖屏；如需横屏，把 `Info.plist` 的 `UISupportedInterfaceOrientations` 加上 `Landscape*`。
- **iPad 适配**：当前 `TARGETED_DEVICE_FAMILY = "1"` 只给 iPhone。

## 隐私

- 仅声明 `NSPhotoLibraryAddUsageDescription` 与 `NSPhotoLibraryUsageDescription`，没有任何网络请求。
- EXIF 中的 GPS 坐标无需定位权限即可读取；如担心隐私，编辑页右上角参数按钮里可清除 GPS。
- `PlaceLookup`（可选）会用 `CLGeocoder` 走 Apple 网络服务反查城市名，调用时才发起请求。
