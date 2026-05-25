# WatermarkCamera · Web Demo

5 套相机风格水印模板的浏览器预览，纯 HTML+CSS+JS 复刻 iOS App 的设计。

线上地址：[kommmy.github.io/watermark](https://kommmy.github.io/watermark/)

## 本地预览

直接双击 `index.html` 打开即可，无需任何构建步骤。

## 文件结构

```
docs/
├── index.html      # 主页面（控件 + 预览容器）
├── style.css       # 通用样式 + 5 套模板的全部 CSS
├── script.js       # 模板渲染、参数表单、图片上传逻辑
└── sample.svg      # 默认占位风景图
```

## 添加新模板（与 iOS 同步）

1. 在 `script.js` 的 `RENDERERS` 对象里加一个 `<id>(d) { return "..." }` 渲染函数
2. 在 `TEMPLATES` 数组加 `{ id, name }`
3. 在 `style.css` 加一段 `.tpl-<id> { ... }` 的样式

iOS 端对应改 `WatermarkCamera/Templates/<XxxTemplate>.swift` 与 `WatermarkCamera/Models/WatermarkTemplate.swift`。
