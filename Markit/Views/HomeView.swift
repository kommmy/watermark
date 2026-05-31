import SwiftUI

/// App 根视图：徕卡水印 / 相机拼图。
/// 实际的选图、模板列表、编辑流程都下放到每个 Tab 自己处理。
struct HomeView: View {
    enum Tab: Hashable { case discover, watermark, puzzle, me }

    @State private var tab: Tab

    init(initialTab: Tab = .watermark) {
        self._tab = State(initialValue: initialTab)
    }

    var body: some View {
        TabView(selection: $tab) {
            WatermarkTab()
                .tabItem { Label("徕卡水印", systemImage: "camera.aperture") }
                .tag(Tab.watermark)

            PuzzleTab()
                .tabItem { Label("相机拼图", systemImage: "rectangle.on.rectangle") }
                .tag(Tab.puzzle)
        }
        .tint(.black)
        .preferredColorScheme(.light)
        .onAppear(perform: configureTabBarAppearance)
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(red: 0.98, green: 0.965, blue: 0.94, alpha: 0.94)
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.08)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
