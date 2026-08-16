import SwiftUI

/// 剪贴簿视图模型
/// 负责管理元素集合、层级顺序，以及根据画布尺寸生成初始位置
final class ScrapbookViewModel: ObservableObject {
    @Published var elements: [any ScrapbookElement] = []
    @Published var selectedElementID: UUID? = nil

    var selectedElement: (any ScrapbookElement)? {
        elements.first { $0.id == selectedElementID }
    }

    private var zIndexCounter = 0

    private var nextZIndex: Int {
        zIndexCounter += 1
        return zIndexCounter
    }

    /// 基于画布几何信息，在指定区域中心生成带随机偏移的坐标
    private func centeredPosition(in size: CGSize, at area: CGRect) -> CGPoint {
        let x = area.midX + CGFloat.random(in: -24...24)
        let y = area.midY + CGFloat.random(in: -24...24)
        return CGPoint(x: x, y: y)
    }

    /// 添加贴纸元素
    func addSticker(canvasSize: CGSize) {
        let area = canvasRect(for: canvasSize, verticalFraction: 0.42, heightFraction: 0.28)
        let element = StickerElement(
            position: centeredPosition(in: canvasSize, at: area),
            scale: 1.0,
            rotation: .degrees(0),
            zIndex: nextZIndex,
            symbolName: ["star.fill", "heart.fill", "sparkles", "cat.fill"].randomElement() ?? "star.fill",
            tint: [.pink, .orange, .mint, .purple, .yellow].randomElement() ?? .pink,
            imageData: nil,
            isCutout: false
        )
        elements.append(element)
        selectedElementID = nil
    }

    /// 添加文本元素
    func addText(canvasSize: CGSize) {
        let area = canvasRect(for: canvasSize, verticalFraction: 0.58, heightFraction: 0.24)
        let element = TextElement(
            position: centeredPosition(in: canvasSize, at: area),
            rotation: .degrees(-2),
            zIndex: nextZIndex
        )
        elements.append(element)
        selectedElementID = nil
    }

    /// 添加和纸胶带元素
    func addWashiTape(canvasSize: CGSize) {
        let area = canvasRect(for: canvasSize, verticalFraction: 0.26, heightFraction: 0.18)
        let element = WashiTapeElement(
            position: centeredPosition(in: canvasSize, at: area),
            scale: 1.1,
            rotation: .degrees(0),
            zIndex: nextZIndex,
            color: [.cyan, .pink, .yellow, .mint, .indigo].randomElement() ?? .cyan
        )
        elements.append(element)
        selectedElementID = nil
    }

    /// 添加照片（可作为剪切贴纸）
    func addPhoto(data: Data, asCutout: Bool, canvasSize: CGSize) {
        let area = canvasRect(for: canvasSize, verticalFraction: 0.5, heightFraction: 0.28)
        let element = StickerElement(
            position: centeredPosition(in: canvasSize, at: area),
            scale: 1.0,
            rotation: .degrees(0),
            zIndex: nextZIndex,
            symbolName: "", // 照片贴纸不需要系统符号
            tint: .clear,     // 颜色对图片无效，占位
            imageData: data,
            isCutout: asCutout
        )
        elements.append(element)
        selectedElementID = nil
    }

    /// 计算用于放置元素的画布内矩形区域
    /// - Parameters:
    ///   - size: 画布总尺寸
    ///   - verticalFraction: 区域中心的纵向比例 (0~1)
    ///   - heightFraction: 区域高度占画布高度的比例
    private func canvasRect(for size: CGSize, verticalFraction: CGFloat, heightFraction: CGFloat) -> CGRect {
        // 预留底部工具栏空间
        let toolbarInset: CGFloat = 110
        let usableHeight = max(size.height - toolbarInset, 1)
        let usableTop = toolbarInset * 0.5
        let usableRect = CGRect(x: 0, y: usableTop, width: size.width, height: usableHeight)

        let centerY = usableRect.minY + usableRect.height * verticalFraction
        let rectHeight = usableRect.height * heightFraction
        let rect = CGRect(
            x: 0,
            y: centerY - rectHeight / 2,
            width: size.width,
            height: rectHeight
        )
        return rect
    }

    /// 将元素置顶（提高 zIndex）
    func bringToFront(element: any ScrapbookElement) {
        guard let index = elements.firstIndex(where: { $0.id == element.id }) else { return }
        let topZIndex = elements.map { $0.zIndex }.max() ?? 0
        if elements[index].zIndex == topZIndex { return }
        var updated = elements[index]
        updated.zIndex = nextZIndex
        elements[index] = updated
    }

    /// 更新元素（位置、旋转、缩放等）
    func update(element: any ScrapbookElement) {
        guard let index = elements.firstIndex(where: { $0.id == element.id }) else { return }
        elements[index] = element
    }

    /// 选择某个元素（用于手指按下即选中）
    func selectElement(_ id: UUID) {
        selectedElementID = id
    }
}
