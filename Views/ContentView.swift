import SwiftUI
import PhotosUI

/// 剪贴簿主视图
/// 负责画布 + 元素层 + 底部工具栏的整体布局
struct ContentView: View {
    @StateObject private var viewModel = ScrapbookViewModel()

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedCutoutItem: PhotosPickerItem?
    @State private var canvasSize: CGSize = .zero
    @State private var hasSeeded = false

    var body: some View {
        ZStack {
            PaperBackground()
                .ignoresSafeArea()

            // 元素层：位于中层，承载可拖拽元素
            GeometryReader { geometry in
                let size = geometry.size
                ZStack {
                    // 空白手势层：捕获画布空白区域的「按下 / 拖拽」，取消当前选中。
                    // 用 DragGesture(minimumDistance: 0) 而非 onTapGesture：
                    // minimumDistance 为 0 时按下即触发 onChanged，可同时覆盖
                    // 「点击空白」和「在空白处开始拖拽」两种场景。
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    viewModel.selectedElementID = nil
                                }
                        )

                    ForEach(viewModel.elements.sorted { $0.zIndex < $1.zIndex }, id: \.id) { element in
                        ScrapbookElementView(
                            element: element,
                            viewModel: viewModel
                        )
                    }
                }
                .frame(width: size.width, height: size.height)
                .onAppear {
                    updateCanvas(size)
                }
                .onChange(of: size) { _, newSize in
                    updateCanvas(newSize)
                }
            }

            // 工具栏层：位于最上层，永远可点击，不被元素遮挡
            VStack {
                Spacer()
                toolbar
                    .padding(.horizontal, 12)
                    .padding(.bottom, 14)
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            loadPhoto(from: newItem, asCutout: false)
        }
        .onChange(of: selectedCutoutItem) { _, newItem in
            loadPhoto(from: newItem, asCutout: true)
        }
    }

    /// 记录画布尺寸，并在首次渲染时植入默认元素
    private func updateCanvas(_ size: CGSize) {
        canvasSize = size
        guard !hasSeeded, size.width > 0, size.height > 0 else { return }
        hasSeeded = true
        viewModel.addWashiTape(canvasSize: size)
        viewModel.addSticker(canvasSize: size)
        viewModel.addText(canvasSize: size)
    }

    /// 底部工具栏：可横向滚动，每个 tab 完整显示，样式不溢出
    private var toolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ToolbarButton(title: "Add Sticker", systemImage: "seal.fill") {
                    viewModel.addSticker(canvasSize: canvasSize)
                }

                ToolbarButton(title: "Add Text", systemImage: "text.bubble") {
                    viewModel.addText(canvasSize: canvasSize)
                }

                ToolbarButton(title: "Add Tape", systemImage: "rectangle.fill.on.rectangle.angled.fill") {
                    viewModel.addWashiTape(canvasSize: canvasSize)
                }

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    ToolbarLabel(title: "Add Photo", systemImage: "photo.on.rectangle.angled")
                }

                PhotosPicker(selection: $selectedCutoutItem, matching: .images) {
                    ToolbarLabel(title: "Add Cutouts", systemImage: "person.crop.rectangle.stack.fill")
                }
            }
            .padding(8)
        }
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)
    }

    private func loadPhoto(from item: PhotosPickerItem?, asCutout: Bool) {
        guard let item else { return }

        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else { return }
            await MainActor.run {
                viewModel.addPhoto(data: data, asCutout: asCutout, canvasSize: canvasSize)
                if asCutout {
                    selectedCutoutItem = nil
                } else {
                    selectedPhotoItem = nil
                }
            }
        }
    }
}

/// 纸张背景视图：铺满整个画布
struct PaperBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.957, green: 0.945, blue: 0.918)

            Canvas { context, size in
                for index in 0..<260 {
                    let x = CGFloat((index * 47) % Int(max(size.width, 1)))
                    let y = CGFloat((index * 83) % Int(max(size.height, 1)))
                    let rect = CGRect(x: x, y: y, width: 1.2, height: 1.2)
                    context.fill(Path(ellipseIn: rect), with: .color(.brown.opacity(0.045)))
                }
            }
            .allowsHitTesting(false)
        }
    }
}

#Preview {
    ContentView()
}
