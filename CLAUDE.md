# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

markit is a 100% local, no-backend iOS (SwiftUI, iOS 16+) app that adds
camera-brand-style EXIF watermarks to photos and composes multi-photo puzzles.
A companion browser demo under `docs/` re-implements the same templates in
JavaScript and is deployed to GitHub Pages. README.md is in Chinese and describes
the broader product vision; treat the code as the source of truth where they differ
(see "Current shipped surface vs README" below).

## Build & run

There is **no `.xcodeproj` in git** — it is `.gitignore`d. `project.yml` (XcodeGen)
is the source of truth for the project structure. Always regenerate after adding,
removing, or moving source files:

```bash
brew install xcodegen        # once
xcodegen generate            # regenerates Markit.xcodeproj from project.yml
open Markit.xcodeproj
```

Command-line build (mirrors `.github/workflows/ios-build.yml`):

```bash
xcodebuild \
  -project Markit.xcodeproj \
  -scheme Markit \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build \
  clean build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

There is **no test target** — CI only verifies that the app compiles for the
simulator. "Run the tests" means "make it build."

CI note: XcodeGen 2.x emits `objectVersion = 77`; the build workflow `sed`s it down
to `60` for older Xcode on the runner. Only relevant if a generated project won't open.

## Core architecture

The whole app is a SwiftUI rendering pipeline. There is no networking (the lone
exception is the optional `PlaceLookup`, which uses `CLGeocoder` only when invoked).

Two parallel pipelines, same shape:

```
Watermark:  PhotosPicker → Data → ExifReader → PhotoMetadata
                                       ↘ UIImage → WatermarkTemplate.makeView(image:meta:)
                                                 → ImageComposer.render  (SwiftUI ImageRenderer)
                                                 → PhotoSaver / share sheet

Puzzle:     PhotosPicker × N → [UIImage] → PuzzleLayout.makeView(images:options:)
                                         → PuzzleComposer.render (SwiftUI ImageRenderer)
                                         → PhotoSaver / share sheet
```

- **A template / layout *is* a SwiftUI `View`.** `WatermarkTemplate` and `PuzzleLayout`
  (in `Models/`) are enums that map a case → a concrete View via `makeView(...)`.
  Each watermark template View has the fixed signature `(image: UIImage, meta: PhotoMetadata)`;
  each puzzle layout View is `(images: [UIImage], options: PuzzleOptions)`.
- **`ImageComposer` / `PuzzleComposer`** (in `Services/`, both `@MainActor enum`s) turn a
  template View into a single exported `UIImage` via `ImageRenderer`.
- **`ExifReader`** parses TIFF/EXIF/EXIFAux/GPS dictionaries via `ImageIO`. Every field is
  optional and nil-tolerant — templates must handle missing data (RAW formats like Sony ARW
  often lack `LensModel`).
- **`Theme/`** holds the design system: `AppTheme` (color/spacing/radius tokens) and
  `ViewModifiers` (`.cardStyle()`, `.appBackground()`, loading overlay, floating create button).
- **`BrowseCatalog`** declares the themed horizontal groupings used by the browse tabs.

### The template coordinate-system convention (important)

Inside any template/layout View, layout is expressed in points where **1 pt == 1 output
pixel**. The composer forces the View's width to the target render width and sets
`renderer.scale = 1`, so points map 1:1 to pixels regardless of device screen scale.

Therefore: express all font sizes, paddings, and offsets as fractions of the image
dimension (e.g. `image.size.height * 0.04`), never as hard-coded point values. This is
what makes templates adapt across portrait/landscape and arbitrary resolutions.

Memory guard: `ImageRenderer` on 50MP images costs 300MB+, so both composers downscale
the long edge to `maxLongEdge` (default 4096px) before rendering.

## The dual-platform lockstep contract (read before adding templates)

Every watermark template and puzzle layout exists **twice** and must stay in sync by a
shared string `id`:

- iOS: a SwiftUI View + an enum `case` whose `rawValue` is the id.
- Web: an entry in `docs/script.js` (`TEMPLATES` + `RENDERERS`, or `LAYOUTS` +
  `LAYOUT_RENDERERS`), keyed by the same id.

Brand logos likewise live in two places under the same `brand_<name>` name:
`Resources/Assets.xcassets/brand_<name>.imageset` (iOS) and `docs/assets/logos/brand_<name>.svg`
referenced via the `LOGO` constant (Web).

### Adding a watermark template

1. `Templates/<Name>Template.swift` — a View `(image: UIImage, meta: PhotoMetadata)`.
2. `Models/WatermarkTemplate.swift` — add the `case`, and a branch in each `switch`
   (`displayName`, `brandLabel`, `isBrandSpecific`, `makeView`).
3. `Views/Cards/TemplateCard.swift` and `Views/TemplateStrip.swift` — give it a cover
   gradient/accent and a strip color band.
4. `Models/BrowseCatalog.swift` — slot it into a browse group.
5. `docs/script.js` — add the matching-id entry to `TEMPLATES` + `RENDERERS`.
6. `xcodegen generate` to pick up the new file.

### Adding a puzzle layout

Same pattern: View in `PuzzleLayouts/`, `case` + `makeView` + `slotCount` in
`Models/PuzzleLayout.swift`, cover in `Views/Cards/PuzzleLayoutCard.swift`, group in
`BrowseCatalog`, and the matching id in `docs/script.js` (`LAYOUTS` + `LAYOUT_RENDERERS`).

## Current shipped surface vs README

The code is intentionally narrowed to a **Leica-focused** experience even though more
templates/tabs exist in the tree. Don't "fix" these to match the README without intent:

- `HomeView` mounts only **two tabs** (徕卡水印 / 相机拼图). `DiscoverTab` and `MeTab`
  exist as files but are not wired into the TabView.
- `PuzzleLayout.allCases` is **overridden to `[.cameraDetail]`** — only the Leica
  camera+shot puzzle is user-selectable, though 4 layouts are implemented.
- `WatermarkTemplate.recommended(for:)` always returns `.leica`, and
  `WatermarkTemplate.resolved(...)` clamps selection to the `leicaTemplates` set
  (a hand-curated subset). ~22 templates exist in the enum, but the editor entry
  flow surfaces only that Leica subset.

## Deployment

`.github/workflows/deploy-pages.yml` publishes `docs/` to GitHub Pages on pushes to
`main` that touch `docs/**`. Live demo: https://kommmy.github.io/watermark/
