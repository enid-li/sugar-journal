import SwiftUI
import PhotosUI
import UIKit

enum ScrapbookElementType {
    case sticker
    case text
    case washiTape
}

protocol ScrapbookElement: Identifiable {
    var id: UUID { get }
    var position: CGPoint { get set }
    var scale: CGFloat { get set }
    var rotation: Angle { get set }
    var zIndex: Int { get set }
    var type: ScrapbookElementType { get }
}

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

struct TextElement: ScrapbookElement {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat = 1
    var rotation: Angle = .zero
    var zIndex: Int
    let type: ScrapbookElementType = .text

    var text: String = "Today felt soft and golden."
}

struct WashiTapeElement: ScrapbookElement {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat = 1
    var rotation: Angle = .degrees(-5)
    var zIndex: Int
    let type: ScrapbookElementType = .washiTape

    var color: Color = .cyan
}

final class ScrapbookViewModel: ObservableObject {
    @Published var elements: [any ScrapbookElement] = []

    private var zIndexCounter = 0

    private var nextZIndex: Int {
        zIndexCounter += 1
        return zIndexCounter
    }

    func addSticker() {
        elements.append(
            StickerElement(
                position: CGPoint(x: 210 + CGFloat.random(in: -24...24), y: 280 + CGFloat.random(in: -24...24)),
                zIndex: nextZIndex,
                symbolName: ["star.fill", "heart.fill", "sparkles", "cat.fill"].randomElement() ?? "star.fill",
                tint: [.pink, .orange, .mint, .purple, .yellow].randomElement() ?? .pink
            )
        )
    }

    func addText() {
        elements.append(
            TextElement(
                position: CGPoint(x: 220 + CGFloat.random(in: -24...24), y: 360 + CGFloat.random(in: -24...24)),
                rotation: .degrees(-2),
                zIndex: nextZIndex
            )
        )
    }

    func addWashiTape() {
        elements.append(
            WashiTapeElement(
                position: CGPoint(x: 220 + CGFloat.random(in: -28...28), y: 210 + CGFloat.random(in: -28...28)),
                scale: 1.1,
                zIndex: nextZIndex,
                color: [.cyan, .pink, .yellow, .mint, .indigo].randomElement() ?? .cyan
            )
        )
    }

    func addPhoto(data: Data, asCutout: Bool) {
        elements.append(
            StickerElement(
                position: CGPoint(x: 230 + CGFloat.random(in: -24...24), y: 320 + CGFloat.random(in: -24...24)),
                zIndex: nextZIndex,
                imageData: data,
                isCutout: asCutout
            )
        )
    }

    func bringToFront(element: any ScrapbookElement) {
        guard let index = elements.firstIndex(where: { $0.id == element.id }) else { return }
        let topZIndex = elements.map(\.zIndex).max() ?? 0
        if elements[index].zIndex == topZIndex { return }
        var updated = elements[index]
        updated.zIndex = nextZIndex
        elements[index] = updated
    }

    func update(element: any ScrapbookElement) {
        guard let index = elements.firstIndex(where: { $0.id == element.id }) else { return }
        elements[index] = element
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ScrapbookViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedCutoutItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            PaperBackground()
                .ignoresSafeArea()

            ZStack {
                ForEach(viewModel.elements.sorted { $0.zIndex < $1.zIndex }, id: \.id) { element in
                    ScrapbookElementView(element: element, viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                Spacer()
                toolbar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 18)
            }
        }
        .onAppear {
            if viewModel.elements.isEmpty {
                viewModel.addWashiTape()
                viewModel.addSticker()
                viewModel.addText()
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            loadPhoto(from: newItem, asCutout: false)
        }
        .onChange(of: selectedCutoutItem) { _, newItem in
            loadPhoto(from: newItem, asCutout: true)
        }
    }

    private var toolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ToolbarButton(title: "Add Sticker", systemImage: "seal.fill") {
                    viewModel.addSticker()
                }

                ToolbarButton(title: "Add Text", systemImage: "textformat") {
                    viewModel.addText()
                }

                ToolbarButton(title: "Add Tape", systemImage: "rectangle.fill.on.rectangle.angled.fill") {
                    viewModel.addWashiTape()
                }

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    ToolbarLabel(title: "Add Photo", systemImage: "photo.on.rectangle.angled")
                }

                PhotosPicker(selection: $selectedCutoutItem, matching: .images) {
                    ToolbarLabel(title: "Add Cutouts", systemImage: "person.crop.rectangle.stack.fill")
                }
            }
            .padding(10)
        }
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)
    }

    private func loadPhoto(from item: PhotosPickerItem?, asCutout: Bool) {
        guard let item else { return }

        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else { return }
            await MainActor.run {
                viewModel.addPhoto(data: data, asCutout: asCutout)
                if asCutout {
                    selectedCutoutItem = nil
                } else {
                    selectedPhotoItem = nil
                }
            }
        }
    }
}

struct ScrapbookElementView: View {
    let element: any ScrapbookElement
    @ObservedObject var viewModel: ScrapbookViewModel

    @State private var committedPosition: CGPoint
    @State private var committedScale: CGFloat
    @State private var committedRotation: Angle

    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1
    @GestureState private var gestureRotation: Angle = .zero

    init(element: any ScrapbookElement, viewModel: ScrapbookViewModel) {
        self.element = element
        self.viewModel = viewModel
        _committedPosition = State(initialValue: element.position)
        _committedScale = State(initialValue: element.scale)
        _committedRotation = State(initialValue: element.rotation)
    }

    var body: some View {
        renderedElement
            .scaleEffect(clampedScale(committedScale * gestureScale))
            .rotationEffect(committedRotation + gestureRotation)
            .position(
                x: committedPosition.x + dragOffset.width,
                y: committedPosition.y + dragOffset.height
            )
            .zIndex(Double(element.zIndex))
            .contentShape(Rectangle())
            .highPriorityGesture(TapGesture().onEnded { focusElement() })
            .gesture(combinedGesture)
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

    private var combinedGesture: some Gesture {
        dragGesture
            .simultaneously(with: magnificationGesture)
            .simultaneously(with: rotationGesture)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { _ in focusElement() }
            .updating($dragOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                committedPosition.x += value.translation.width
                committedPosition.y += value.translation.height
                saveElement()
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { _ in focusElement() }
            .updating($gestureScale) { value, state, _ in
                state = value
            }
            .onEnded { value in
                committedScale = clampedScale(committedScale * value)
                saveElement()
            }
    }

    private var rotationGesture: some Gesture {
        RotationGesture()
            .onChanged { _ in focusElement() }
            .updating($gestureRotation) { value, state, _ in
                state = value
            }
            .onEnded { value in
                committedRotation += value
                saveElement()
            }
    }

    private func focusElement() {
        viewModel.bringToFront(element: element)
    }

    private func saveElement() {
        var updated = element
        updated.position = committedPosition
        updated.scale = committedScale
        updated.rotation = committedRotation
        viewModel.update(element: updated)
    }

    private func clampedScale(_ value: CGFloat) -> CGFloat {
        min(max(value, 0.35), 3.2)
    }
}

struct StickerView: View {
    let sticker: StickerElement

    var body: some View {
        Group {
            if let data = sticker.imageData, let uiImage = UIImage(data: data) {
                PhotoStickerView(image: uiImage, isCutout: sticker.isCutout)
            } else {
                SymbolStickerView(symbolName: sticker.symbolName, tint: sticker.tint)
            }
        }
        .shadow(color: .black.opacity(0.15), radius: 4, x: 2, y: 3)
    }
}

struct SymbolStickerView: View {
    let symbolName: String
    let tint: Color

    var body: some View {
        ZStack {
            Image(systemName: symbolName)
                .font(.system(size: 106, weight: .black))
                .foregroundStyle(.white)

            Image(systemName: symbolName)
                .font(.system(size: 78, weight: .bold))
                .foregroundStyle(tint.gradient)
        }
        .frame(width: 132, height: 132)
        .accessibilityLabel("Sticker")
    }
}

struct PhotoStickerView: View {
    let image: UIImage
    let isCutout: Bool

    var body: some View {
        Group {
            if isCutout {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(DieCutBlobShape())
                    .padding(9)
                    .background(.white, in: DieCutBlobShape())
            } else {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 168, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(8)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if isCutout {
                Image(systemName: "scissors")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(.white.opacity(0.85), in: Circle())
                    .offset(x: 6, y: 6)
            }
        }
    }
}

struct TextBlockView: View {
    let text: TextElement

    var body: some View {
        Text(text.text)
            .font(.custom("ChalkboardSE-Regular", size: 24))
            .foregroundStyle(.brown.opacity(0.82))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(.white.opacity(0.56), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.brown.opacity(0.10), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.05), radius: 3, x: 1, y: 2)
            .frame(width: 230)
            .accessibilityLabel("Journal text")
    }
}

struct WashiTapeView: View {
    let tape: WashiTapeElement

    var body: some View {
        ZStack {
            TornTapeShape()
                .fill(tape.color.opacity(0.48))

            TornTapeShape()
                .stroke(.white.opacity(0.55), style: StrokeStyle(lineWidth: 1, dash: [7, 6]))

            HStack(spacing: 10) {
                ForEach(0..<9, id: \.self) { _ in
                    Rectangle()
                        .fill(.white.opacity(0.22))
                        .frame(width: 2)
                        .rotationEffect(.degrees(14))
                }
            }
        }
        .frame(width: 190, height: 54)
        .shadow(color: .black.opacity(0.08), radius: 3, x: 1, y: 2)
        .accessibilityLabel("Washi tape")
    }
}

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

struct TornTapeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let leftInset = rect.width * 0.035
        let rightInset = rect.width * 0.965

        path.move(to: CGPoint(x: leftInset, y: rect.minY + 4))
        path.addLine(to: CGPoint(x: rightInset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - 5, y: rect.midY - 5))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY + 4))
        path.addLine(to: CGPoint(x: rightInset, y: rect.maxY - 3))
        path.addLine(to: CGPoint(x: leftInset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + 5, y: rect.midY + 4))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY - 5))
        path.closeSubpath()

        return path
    }
}

struct DieCutBlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let points = 24

        for index in 0...points {
            let angle = CGFloat(index) / CGFloat(points) * .pi * 2
            let wobble = 0.92 + 0.08 * sin(CGFloat(index) * 1.7)
            let point = CGPoint(
                x: center.x + cos(angle) * radius * wobble,
                y: center.y + sin(angle) * radius * wobble
            )

            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }
}

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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
