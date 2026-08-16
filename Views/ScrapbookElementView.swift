import SwiftUI
import Foundation


/// 单个剪贴簿元素的视图容器
/// 负责处理拖拽 / 缩放 / 旋转手势，以及元素置顶逻辑
struct ScrapbookElementView: View {
    let element: any ScrapbookElement
    @ObservedObject var viewModel: ScrapbookViewModel

    @GestureState private var isInteracting = false
    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1
    @GestureState private var gestureRotation: Angle = .zero

    init(element: any ScrapbookElement, viewModel: ScrapbookViewModel) {
        self.element = element
        self.viewModel = viewModel
    }

    var body: some View {
        renderedElement
            // 命中形状必须贴合元素实际内容尺寸，并先于 scale/rotation/position 应用，
            // 由外层变换一起缩放/旋转/定位命中区域。
            // 若把 .contentShape 放在 .position 之后，position 会把视图 frame 撑满整个画布，
            // contentShape 的 Shape（Circle/RoundedRectangle/Rectangle）会随之填满全画布，
            // 导致 zIndex 最高的元素拦截所有点击，其他元素永远点不到。
            .contentShape(hitShape)
            .scaleEffect(clampedScale(element.scale * gestureScale) * (isInteracting ? 1.06 : 1))
            .rotationEffect(element.rotation + gestureRotation)
            .position(
                x: element.position.x + dragOffset.width,
                y: element.position.y + dragOffset.height
            )
            // 层级完全由数据源 zIndex 决定：手势进行中不改 zIndex，
            // 避免 ForEach 重排打断手势导致状态卡死；置顶只在松手后通过 bringToFront 完成
            .zIndex(Double(element.zIndex))
            .gesture(dragGesture)
            .simultaneousGesture(magnificationGesture)
            .simultaneousGesture(rotationGesture)
    }

    @ViewBuilder
    private var renderedElement: some View {
        switch element.type {
        case .sticker:
            if let sticker = element as? StickerElement {
                StickerView(sticker: sticker)
            }
        case .text:
            if let text = element as? TextElement {
                TextBlockView(text: text)
            }
        case .washiTape:
            if let tape = element as? WashiTapeElement {
                WashiTapeView(tape: tape)
            }
        }
    }

    /// 命中区域贴合元素可见内容：缩小透明区域对其他元素的拦截，
    /// 使元素重叠时点击「空白处」能选到下层元素
    private var hitShape: AnyShape {
        switch element.type {
        case .sticker:
            if let sticker = element as? StickerElement, sticker.imageData != nil {
                // 照片贴纸：圆角矩形
                return AnyShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            // 符号贴纸（星形/心形等）内容居中，用内切圆贴合，四个角不再拦截
            return AnyShape(Circle())
        case .text:
            // 文本块：白色圆角背景才是可点区域
            return AnyShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        case .washiTape:
            return AnyShape(Rectangle())
        }
    }

    /// 拖拽手势：minimumDistance 为 0，实现「点到即拖」
    /// 过程中只更新 @GestureState（自动复位），不触碰数据源与 zIndex；松手时才保存并置顶
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                // 按下即选中
                if viewModel.selectedElementID != element.id {
                    viewModel.selectElement(element.id)
                }
            }
            .updating($isInteracting) { _, state, _ in state = true }
            .updating($dragOffset) { value, state, _ in
                // 只有当前选中的元素才响应拖拽偏移
                if viewModel.selectedElementID == element.id {
                    state = value.translation
                } else {
                    state = .zero
                }
            }
            .onEnded { value in
                // 结束时仅当自己被选中才保存
                guard viewModel.selectedElementID == element.id else { return }
                var updated = element
                updated.position.x += value.translation.width
                updated.position.y += value.translation.height
                viewModel.update(element: updated)
                viewModel.bringToFront(element: updated)
                viewModel.selectedElementID = nil
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { _ in
                if viewModel.selectedElementID != element.id {
                    viewModel.selectElement(element.id)
                }
            }
            .updating($isInteracting) { _, state, _ in state = true }
            .updating($gestureScale) { value, state, _ in
                if viewModel.selectedElementID == element.id {
                    state = value
                } else {
                    state = 1
                }
            }
            .onEnded { value in
                guard viewModel.selectedElementID == element.id else { return }
                var updated = element
                updated.scale = clampedScale(element.scale * value)
                viewModel.update(element: updated)
                viewModel.bringToFront(element: updated)
                viewModel.selectedElementID = nil
            }
    }

    private var rotationGesture: some Gesture {
        RotationGesture()
            .onChanged { _ in
                if viewModel.selectedElementID != element.id {
                    viewModel.selectElement(element.id)
                }
            }
            .updating($isInteracting) { _, state, _ in state = true }
            .updating($gestureRotation) { value, state, _ in
                if viewModel.selectedElementID == element.id {
                    state = value
                } else {
                    state = .zero
                }
            }
            .onEnded { value in
                guard viewModel.selectedElementID == element.id else { return }
                var updated = element
                updated.rotation = element.rotation + value
                viewModel.update(element: updated)
                viewModel.bringToFront(element: updated)
                viewModel.selectedElementID = nil
            }
    }

    private func clampedScale(_ value: CGFloat) -> CGFloat {
        min(max(value, 0.35), 3.2)
    }
}

