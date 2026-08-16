import SwiftUI

/// 设计系统 - 统一卡片样式
struct DSCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(DesignSystem.Spacing.lg)
            .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                    .stroke(.white.opacity(0.65), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    DSCard {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Card Title")
                .font(DesignSystem.Fonts.headline)
            Text("Card content goes here.")
                .font(DesignSystem.Fonts.body)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
    }
    .padding()
    .background(DesignSystem.Colors.paperBackground)
}