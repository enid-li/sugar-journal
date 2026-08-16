import SwiftUI

/// 设计系统 - 统一管理颜色、字体、间距等设计规范
/// 避免未来 UI 风格混乱
enum DesignSystem {

    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let capsule: CGFloat = 999
    }

    // MARK: - Fonts

    enum Fonts {
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let headline = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 13, weight: .medium, design: .rounded)
    }

    // MARK: - Colors

    enum Colors {
        /// 纸张背景色
        static let paperBackground = Color(red: 0.957, green: 0.945, blue: 0.918)

        /// 主色调 - 暖棕
        static let primary = Color(red: 0.55, green: 0.42, blue: 0.30)

        /// 辅助色 - 柔和粉
        static let secondary = Color(red: 0.95, green: 0.75, blue: 0.75)

        /// 强调色 - 薄荷绿
        static let accent = Color(red: 0.55, green: 0.80, blue: 0.70)

        /// 文字主色
        static let textPrimary = Color(red: 0.30, green: 0.25, blue: 0.20)

        /// 文字次要色
        static let textSecondary = Color(red: 0.55, green: 0.50, blue: 0.45)
    }
}