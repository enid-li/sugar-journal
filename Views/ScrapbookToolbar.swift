import SwiftUI

/// 工具栏按钮
struct ToolbarButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ToolbarLabel(title: title, systemImage: systemImage)
        }
        .buttonStyle(.plain)
    }
}

/// 工具栏按钮标签（按内容 intrinsic 宽度自适应，完整显示、不缩写、不溢出）
struct ToolbarLabel: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(.primary)
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(.white.opacity(0.72), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.65), lineWidth: 1)
            }
            .fixedSize()
    }
}