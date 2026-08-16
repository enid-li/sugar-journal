import SwiftUI

/// 剪贴簿元素的类型
enum ScrapbookElementType {
    case sticker
    case text
    case washiTape
}

/// 剪贴簿元素协议
protocol ScrapbookElement: Identifiable {
    var id: UUID { get }
    var position: CGPoint { get set }
    var scale: CGFloat { get set }
    var rotation: Angle { get set }
    var zIndex: Int { get set }
    var type: ScrapbookElementType { get }
}

/// 贴纸元素
struct StickerElement: ScrapbookElement {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat = 1
    var rotation: Angle = .zero
    var zIndex: Int
    let type: ScrapbookElementType = .sticker

    var symbolName: String = "star.fill"
    var tint: Color = .pink
    var imageData: Data?
    var isCutout: Bool = false
}

/// 文字元素
struct TextElement: ScrapbookElement {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat = 1
    var rotation: Angle = .zero
    var zIndex: Int
    let type: ScrapbookElementType = .text

    var text: String = "Today felt soft and golden."
}

/// 胶带元素
struct WashiTapeElement: ScrapbookElement {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat = 1
    var rotation: Angle = .degrees(-5)
    var zIndex: Int
    let type: ScrapbookElementType = .washiTape

    var color: Color = .cyan
}