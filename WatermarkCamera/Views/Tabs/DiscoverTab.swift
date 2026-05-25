import SwiftUI

// "For You" tab: banner + horizontally scrolling cards (Watermarks + Layouts).
struct DiscoverTab: View {
    var switchTo: (HomeView.Tab) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                    banner
                        .padding(.horizontal, AppTheme.Spacing.l)

                    section(title: "Watermarks", more: "More >") { switchTo(.watermark) } content: {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.Spacing.m) {
                                ForEach(WatermarkTemplate.allCases.prefix(8)) { tpl in
                                    NavigationLink {
                                        TemplatePickPlaceholder(template: tpl)
                                    } label: {
                                        TemplateCard(template: tpl)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.l)
                        }
                    }

                    section(title: "Puzzles", more: "More >") { switchTo(.puzzle) } content: {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.Spacing.m) {
                                ForEach(PuzzleLayout.allCases) { layout in
                                    NavigationLink {
                                        PuzzleEditorEntry(layout: layout)
                                    } label: {
                                        PuzzleLayoutCard(layout: layout)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.l)
                        }
                    }
                }
                .padding(.vertical, AppTheme.Spacing.m)
            }
            .navigationTitle("LumaFrame")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("PRO")
                        .font(AppTheme.Font.caption.weight(.bold))
                        .foregroundColor(AppTheme.Palette.proOrange)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(AppTheme.Palette.surface))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { } label: { Image(systemName: "gearshape") }
                    .foregroundColor(AppTheme.Palette.textPrimary)
                }
            }
            .toolbarBackground(AppTheme.Palette.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .appBackground()
        }
    }

    private var banner: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: [Color(red: 0.27, green: 0.20, blue: 0.16), Color(red: 0.17, green: 0.15, blue: 0.13)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Make it a photo card")
                        .font(AppTheme.Font.bodyBold)
                        .foregroundColor(AppTheme.Palette.textPrimary)
                    Text("Real logos, refined watermarks, and collage layouts.")
                        .font(AppTheme.Font.small)
                        .foregroundColor(AppTheme.Palette.textSecondary)
                }
                Spacer()
                Text("Create")
                    .font(AppTheme.Font.small.weight(.semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Capsule().fill(.white))
            }
            .padding(AppTheme.Spacing.l)
        }
        .frame(height: 90)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
    }

    @ViewBuilder
    private func section<Content: View>(
        title: String, more: String,
        moreAction: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.m) {
            HStack {
                Text(title).font(AppTheme.Font.sectionTitle).foregroundColor(AppTheme.Palette.textPrimary)
                Spacer()
                Button(more) { moreAction() }
                    .font(AppTheme.Font.small)
                    .foregroundColor(AppTheme.Palette.textSecondary)
            }
            .padding(.horizontal, AppTheme.Spacing.l)
            content()
        }
    }
}

// Discover card -> Watermark flow: route into WatermarkTab with pre-selected template.
struct TemplatePickPlaceholder: View {
    let template: WatermarkTemplate
    var body: some View {
        WatermarkTab(preselectedTemplate: template)
    }
}

// Discover card -> Puzzle flow.
struct PuzzleEditorEntry: View {
    let layout: PuzzleLayout
    var body: some View {
        PuzzleEditorView(layout: layout)
    }
}
