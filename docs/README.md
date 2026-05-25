# WatermarkCamera · Web Demo

iPhone 模拟外壳 + 实时编辑器，演示 iOS App 的设计与功能：

- **水印** 12 套：Leica / Leica Mono / Fuji Dark / Fuji Film Strip / Sony / Hasselblad / Ricoh GR / iPhone / Polaroid / Minimal Light / Minimal Dark / Date Stamp
- **拼图** 4 种：上下二格 / 左右二格 / 田字四格 / 相机 + 实拍
- 深色卡片风格：顶部 chips、底部 tabbar、横滑卡片、毛玻璃

线上地址：[kommmy.github.io/watermark](https://kommmy.github.io/watermark/)

## 本地预览

直接双击 `index.html` 打开即可，无需任何构建步骤。

## 文件结构

```
docs/
├── index.html               # 页面壳 + iPhone 外壳骨架
├── style.css                # 深色 token + 所有模板/拼图 CSS
├── script.js                # SPA：路由 / 状态 / 12 套水印渲染 / 4 种拼图渲染
├── sample.svg               # 默认风景示例图
├── sample-camera.svg        # 默认相机产品示例图（用于 camera_detail 拼图）
└── sample-portrait.svg      # 默认人像示例图
```

## 添加新水印模板（与 iOS 同步）

1. 在 `script.js` 的 `TEMPLATES` 数组加 `{ id, name, group, brand }`
2. 在 `script.js` 的 `RENDERERS` 对象里加一个 `<id>(d) { return "..." }` 渲染函数
3. 在 `style.css` 加一段 `.tpl-<id> { ... }` 的样式
4. iOS 端对应改 `WatermarkCamera/Templates/<Xxx>Template.swift` 与 `WatermarkCamera/Models/WatermarkTemplate.swift`

## 添加新拼图布局（与 iOS 同步）

1. 在 `script.js` 的 `LAYOUTS` 数组加 `{ id, name, slots, hint }`
2. 在 `script.js` 的 `LAYOUT_RENDERERS` 加 `<id>(imgs, opts) { return "..." }`
3. 在 `puzzleCoverSvg()` 里给 id 加一个封面 SVG
4. iOS 端对应在 `WatermarkCamera/PuzzleLayouts/` 加 `<Xxx>Layout.swift` 并补 `Models/PuzzleLayout.swift` 的 case
