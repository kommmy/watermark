# markit 上架清单

## 已准备

- App Store 商店显示名：Markit Frame（"markit" 已被占用）；手机桌面图标名仍为 Markit
- Bundle ID：com.kommmy.markit
- App Icon：`AppStoreAssets/icon/markit-icon-1024.png`
- Xcode AppIcon：`Markit/Resources/Assets.xcassets/AppIcon.appiconset/markit-icon-1024.png`
- iPhone 6.9 截图：`AppStoreAssets/screenshots/6.9-inch/`
- iPhone 6.5 截图：`AppStoreAssets/screenshots/6.5-inch/`
- iPhone 5.5 截图：`AppStoreAssets/screenshots/5.5-inch/`
- 中文上架文案：`AppStoreAssets/metadata/zh-Hans.md`
- 英文备用文案：`AppStoreAssets/metadata/en-US.md`
- 隐私政策页：`docs/privacy.html`
- 支持页：`docs/support.html`

## App Store Connect 填写建议

- App 名称：Markit Frame
- 副标题：相机水印与拼图工具
- Bundle ID：com.kommmy.markit
- SKU：markit-ios
- 版本号：1.0.0
- 构建号：1
- 类别：摄影与录像
- 副类别：图形与设计
- 年龄分级：4+
- 隐私：Data Not Collected，No Tracking
- 是否需要登录：否
- 是否包含广告：否
- 是否包含付费内容：当前否

## 提交前需要你确认

- Apple Developer Team ID 与 Signing Certificate。
- `com.kommmy.markit` 是否是你想注册的最终 Bundle ID；如果不是，改 `project.yml` 里的 `PRODUCT_BUNDLE_IDENTIFIER`。
- 支持联系人：当前支持页指向 GitHub Issues；如果你有客服邮箱，建议补到 `docs/support.html`。
- 品牌授权风险：当前产品包含相机品牌相关模板和 logo，如没有授权，正式上架前建议替换成通用样式。
- 隐私政策 URL：如果 GitHub Pages 路径不是 `https://kommmy.github.io/watermark/`，需要把文案里的 URL 改成你的实际域名。
