import SwiftUI

// "Me" tab: stub for recent works + about info.
struct MeTab: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                    header

                    sectionTitle("最近作品")
                    emptyState
                        .padding(.horizontal, AppTheme.Spacing.l)

                    sectionTitle("关于")
                    aboutCard
                        .padding(.horizontal, AppTheme.Spacing.l)
                }
                .padding(.vertical, AppTheme.Spacing.l)
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.Palette.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .appBackground()
        }
    }

    private var header: some View {
        HStack(spacing: AppTheme.Spacing.m) {
            Circle()
                .fill(LinearGradient(
                    colors: [.purple, .blue],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 56, height: 56)
                .overlay(
                    Text("U")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text("你好，摄影师")
                    .font(AppTheme.Font.bodyBold)
                    .foregroundColor(AppTheme.Palette.textPrimary)
                Text("v1.0 - 全程本地处理")
                    .font(AppTheme.Font.small)
                    .foregroundColor(AppTheme.Palette.textSecondary)
            }
            Spacer()
        }
        .padding(AppTheme.Spacing.l)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.Font.sectionTitle)
            .foregroundColor(AppTheme.Palette.textPrimary)
            .padding(.horizontal, AppTheme.Spacing.l)
    }

    private var emptyState: some View {
        HStack {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(AppTheme.Palette.textSecondary)
            VStack(alignment: .leading, spacing: 2) {
                Text("还没有作品")
                    .font(AppTheme.Font.bodyBold)
                    .foregroundColor(AppTheme.Palette.textPrimary)
                Text("从水印或拼图里选择一个模板开始。")
                    .font(AppTheme.Font.small)
                    .foregroundColor(AppTheme.Palette.textSecondary)
            }
            Spacer()
        }
        .padding(AppTheme.Spacing.l)
        .cardStyle()
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.s) {
            Text("开源的相机水印与拼图工具。")
                .font(AppTheme.Font.body)
                .foregroundColor(AppTheme.Palette.textPrimary)
            Link("github.com/kommmy/watermark",
                 destination: URL(string: "https://github.com/kommmy/watermark")!)
                .font(AppTheme.Font.small)
                .foregroundColor(AppTheme.Palette.accentBlue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.l)
        .cardStyle()
    }
}

struct MeTab_Previews: PreviewProvider {
    static var previews: some View {
        MeTab().preferredColorScheme(.dark)
    }
}
