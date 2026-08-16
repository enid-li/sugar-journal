import SwiftUI

/// 设计系统 - 统一按钮样式
struct DSButton: View {
    let title: String
    let systemImage: String?
    let style: DSButtonStyle
    let action: () -> Void

    enum DSButtonStyle {
        case primary
        case secondary
        case ghost
    }

    init(
        _ title: String,
        systemImage: String? = nil,
        style: DSButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(DesignSystem.Fonts.body)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(backgroundColor, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return DesignSystem.Colors.primary
        case .ghost:
            return DesignSystem.Colors.textPrimary
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return DesignSystem.Colors.primary
        case .secondary:
            return DesignSystem.Colors.secondary.opacity(0.4)
        case .ghost:
            return .clear
        }
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.md) {
        DSButton("Primary") {}
        DSButton("Secondary", systemImage: "star.fill", style: .secondary) {}
        DSButton("Ghost", style: .ghost) {}
    }
    .padding()
}