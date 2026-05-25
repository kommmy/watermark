# WatermarkCamera

> iOS 相机风格水印 App，纯本地，无后端。
> 选图后自动读取 EXIF（机型/镜头/光圈/快门/ISO/日期/GPS），套用徕卡、富士、索尼、哈苏、极简等模板，一键保存到相册或分享。

[![iOS Build](https://github.com/kommmy/watermark/actions/workflows/ios-build.yml/badge.svg)](https://github.com/kommmy/watermark/actions/workflows/ios-build.yml)
[![Deploy Pages](https://github.com/kommmy/watermark/actions/workflows/deploy-pages.yml/badge.svg)](https://github.com/kommmy/watermark/actions/workflows/deploy-pages.yml)

> **在线预览** 5 套模板效果： [kommmy.github.io/watermark](https://kommmy.github.io/watermark/)
> （HTML+CSS 复刻版，可上传自己的照片即时套用，最终 iOS App 设计同款）

## 环境要求

- macOS 13 + Xcode 15 及以上
- iOS 16.0+ 真机或模拟器
- Swift 5.9

## 运行方式

### 方式一：用 XcodeGen 生成工程（推荐）

仓库里没有 `.xcodeproj`，用 [XcodeGen](https://github.com/yonaskolb/XcodeGen) 一键生成，避免任何手工拖文件的繁琐。

```bash
brew install xcodegen
cd /path/to/this/repo
xcodegen
open WatermarkCamera.xcodeproj
```

然后选一个 iOS 16+ 模拟器，Cmd+R 即可。

### 方式二：手动新建 Xcode 工程

如果不想用 XcodeGen，也可以手动建：

1. Xcode > File > New > Project > iOS > App
2. Product Name 填 `WatermarkCamera`，Interface 选 SwiftUI，Language 选 Swift，Minimum Deployments 选 iOS 16.0
3. 删除自动生成的 `ContentView.swift` 和 `<ProjectName>App.swift`
4. 把本仓库 `WatermarkCamera/` 目录下的所有 `.swift` 文件、`Info.plist`、`Resources/Assets.xcassets` 全部拖入 Xcode 工程（选 Copy items if needed，加入 target）
5. Project Settings > Info > 把 `Info.plist` 指向拖入的那份
6. Cmd+R

## 目录结构

```
WatermarkCamera/
├── App/
│   └── WatermarkCameraApp.swift     # @main 入口
├── Models/
│   ├── PhotoMetadata.swift          # EXIF 摘要 + 品牌识别
│   └── WatermarkTemplate.swift      # 模板枚举 + 工厂
├── Services/
│   ├── ExifReader.swift             # ImageIO 解析 TIFF/EXIF/GPS
│   ├── ImageComposer.swift          # ImageRenderer 渲染合成
│   ├── PhotoSaver.swift             # 写入相册（addOnly）
│   └── PlaceLookup.swift            # 可选：GPS 反查城市名
├── Templates/
│   ├── LeicaTemplate.swift
│   ├── FujiTemplate.swift
│   ├── SonyTemplate.swift
│   ├── HasselbladTemplate.swift
│   └── MinimalTemplate.swift
├── Views/
│   ├── HomeView.swift               # 首页 + PhotosPicker
│   ├── EditorView.swift             # 预览 + 模板切换 + 导出
│   ├── TemplateStrip.swift          # 横向模板选择条
│   └── MetadataEditorSheet.swift    # 手动覆盖 EXIF
├── Resources/
│   └── Assets.xcassets              # AppIcon / AccentColor，将来放品牌 logo
└── Info.plist
```

## 数据流

```
PhotosPicker → Data → ExifReader → PhotoMetadata
                              ↘                ↘
                              UIImage → WatermarkTemplate.makeView(...)
                                        → ImageRenderer → UIImage
                                        → PhotoSaver / UIActivityViewController
```

## 添加新模板

1. 在 `Templates/` 下新建 `<Name>Template.swift`，实现一个 `View`，初始化签名是 `(image: UIImage, meta: PhotoMetadata)`。
2. 在 `Models/WatermarkTemplate.swift` 的 `enum WatermarkTemplate` 里加一个新的 `case`。
3. 在 `displayName` 和 `makeView(image:meta:)` 的 `switch` 里补对应分支。
4. 可选：在 `Views/TemplateStrip.swift` 的 `accentStrip(for:)` 里画一个缩略图标识条。

模板内部坐标系约定：以 `image.size.width` 作为 1 个像素单位（合成器会把 View 宽度强制等于原图像素宽度，再以 scale=1 渲染输出）。所有字号/留白用 `image.size.height * 0.xx` 表达即可，自动适配横竖图与各种像素分辨率。

## 替换品牌 logo（用真矢量图）

第一版为了不踩品牌商标问题，模板里都用了 `Text("LEICA")` 之类的纯文字 logo。若需更接近真机印刷字样：

1. 把品牌矢量 logo（建议从 SVG 转 PDF）拖入 `Resources/Assets.xcassets`，命名 `brand_leica`、`brand_fujifilm`、`brand_sony`、`brand_hasselblad`。
2. 在 Asset 设置里勾选 **Preserve Vector Data**、Render As 选 **Template Image**（这样可以跟着 `.foregroundColor` 上色）。
3. 在对应模板里把 `Text("LEICA")` 换成 `Image("brand_leica").resizable().aspectRatio(contentMode: .fit).frame(height: barHeight * 0.5)`。

> 注意：品牌 logo 受商标法保护，自用 OK，公开发布或上架请确保已获得授权或使用替代设计。

## 已知限制

- **超大图内存**：`ImageRenderer` 在 5000 万像素图上会吃 300MB+ 内存；当前默认长边裁到 4096 像素再渲染（`ImageComposer.render(maxLongEdge:)` 可调）。
- **RAW 兼容**：CGImageSource 支持 HEIC、DNG，但 Sony ARW / Canon CR3 等可能缺 `LensModel`，模板里已做 nil 兜底显示空字符串。
- **设备方向**：第一版只锁竖屏；如需横屏，把 `Info.plist` 的 `UISupportedInterfaceOrientations` 加上 `Landscape*` 即可。
- **iPad 适配**：当前 `TARGETED_DEVICE_FAMILY = "1"` 只给 iPhone，iPad 想用可改成 `"1,2"` 并自行处理大屏布局。

## 隐私

- 仅声明 `NSPhotoLibraryAddUsageDescription` 与 `NSPhotoLibraryUsageDescription`，没有任何网络请求。
- EXIF 中的 GPS 坐标无需定位权限即可读取；如担心隐私，编辑页右上角参数按钮里有"清除 GPS"。
- `PlaceLookup`（可选）会用 `CLGeocoder` 走 Apple 网络服务反查城市名，调用时才发起请求。
