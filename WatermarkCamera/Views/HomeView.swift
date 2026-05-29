import SwiftUI

/// App 根视图：4 Tab（推荐 / 水印 / 拼图 / 我的）+ 深色主题。
/// 实际的选图、模板列表、编辑流程都下放到每个 Tab 自己处理。
struct HomeView: View {
    @State private var tab: Tab = .watermark

    enum Tab: Hashable { case discover, watermark, puzzle, me }

    var body: some View {
        TabView(selection: $tab) {
            WatermarkTab()
                .tabItem { Label("徕卡水印", systemImage: "camera.aperture") }
                .tag(Tab.watermark)

            PuzzleTab()
                .tabItem { Label("相机拼图", systemImage: "rectangle.on.rectangle") }
                .tag(Tab.puzzle)
        }
        .tint(.white)
        .preferredColorScheme(.dark)
        .onAppear(perform: configureTabBarAppearance)
    }

    /// Keep the tab bar dark and translucent so it feels native inside the app.
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        appearance.shadowColor = UIColor.white.withAlphaComponent(0.08)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
