import SwiftUI

/// App 根视图：4 Tab（推荐 / 水印 / 拼图 / 我的）+ 深色主题。
/// 实际的选图、模板列表、编辑流程都下放到每个 Tab 自己处理。
struct HomeView: View {
    @State private var tab: Tab = .discover

    enum Tab: Hashable { case discover, watermark, puzzle, me }

    var body: some View {
        TabView(selection: $tab) {
            DiscoverTab(switchTo: { tab = $0 })
                .tabItem { Label("推荐", systemImage: "flame") }
                .tag(Tab.discover)

            WatermarkTab()
                .tabItem { Label("水印", systemImage: "camera.macro") }
                .tag(Tab.watermark)

            PuzzleTab()
                .tabItem { Label("拼图", systemImage: "square.grid.2x2") }
                .tag(Tab.puzzle)

            MeTab()
                .tabItem { Label("我的", systemImage: "person") }
                .tag(Tab.me)
        }
        .tint(.white)
        .preferredColorScheme(.dark)
        .onAppear(perform: configureTabBarAppearance)
    }

    /// 让底部 TabBar 在深色主题下保持半透明黑色，跟 PixFrame 风格一致。
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
