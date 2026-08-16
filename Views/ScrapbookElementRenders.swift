import SwiftUI

/// 贴纸渲染视图
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

/// 符号贴纸视图
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

/// 照片贴纸视图
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

/// 文字块视图
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

/// 胶带视图
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

/// 撕裂胶带形状
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

/// 不规则剪纸形状
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