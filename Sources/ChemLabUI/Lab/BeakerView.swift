import ChemLabCore
import SwiftUI

extension RGB {
    var color: Color { Color(red: red, green: green, blue: blue) }

    /// True for near-white colors, which need an outline to be seen on a light background.
    var isPale: Bool { (red + green + blue) / 3 > 0.85 }
}

/// One beaker on the bench: glass, liquid, solids at the bottom, bubbles, gas and
/// a flame underneath, with its temperature, pH and hazard badges below.
struct BeakerView: View {
    let beaker: Beaker
    let isSelected: Bool
    let bubbleUntil: Date?
    let burnerOn: Bool

    private var isBoiling: Bool { beaker.temperature >= 99 && beaker.waterMoles > 0 }

    private var needsAnimation: Bool {
        burnerOn || isBoiling || !beaker.gases.isEmpty || (bubbleUntil.map { $0 > Date() } ?? false)
    }

    var body: some View {
        VStack(spacing: 6) {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !needsAnimation)) { timeline in
                Canvas { context, size in
                    BeakerArtist.draw(
                        in: context, size: size, beaker: beaker,
                        time: timeline.date.timeIntervalSinceReferenceDate,
                        bubbling: isBoiling || (bubbleUntil.map { $0 > timeline.date } ?? false),
                        burnerOn: burnerOn)
                }
            }
            .aspectRatio(0.85, contentMode: .fit)
            caption
        }
        .padding(8)
        .background(
            isSelected ? Color.accentColor.opacity(0.12) : Color.clear,
            in: RoundedRectangle(cornerRadius: 12)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: isSelected ? 2 : 1)
        )
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var caption: some View {
        VStack(spacing: 3) {
            Text(beaker.name).font(.headline)
            HStack(spacing: 8) {
                Label(String(format: "%.0f °C", beaker.temperature), systemImage: "thermometer.medium")
                    .foregroundStyle(beaker.temperature >= 60 ? Color.red : Color.secondary)
                if let pH = beaker.pH {
                    Text(String(format: "pH %.1f", pH))
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                ForEach(beaker.activeHazardKinds, id: \.self) { hazard in
                    Image(systemName: hazard.symbolName)
                        .font(.caption)
                        .foregroundStyle(hazard.color)
                }
            }
            .frame(minHeight: 16)
        }
    }

    private var accessibilitySummary: String {
        var parts = [beaker.name]
        let count = beaker.contents.count + beaker.gases.count
        parts.append(count == 0 ? "empty" : "\(count) substance\(count == 1 ? "" : "s")")
        parts.append(String(format: "%.0f degrees Celsius", beaker.temperature))
        if let pH = beaker.pH { parts.append(String(format: "pH %.1f", pH)) }
        let hazards = beaker.activeHazardKinds.map(\.title)
        if !hazards.isEmpty { parts.append("Hazards: " + hazards.joined(separator: ", ")) }
        return parts.joined(separator: ". ")
    }
}

/// Draws a beaker into a `Canvas`. Kept as plain functions so the view stays small.
private enum BeakerArtist {
    /// Beaker volume the drawing treats as full, in liters.
    static let capacity = 0.25

    static func draw(
        in context: GraphicsContext, size: CGSize, beaker: Beaker, time: Double,
        bubbling: Bool, burnerOn: Bool
    ) {
        let w = size.width
        let h = size.height
        let left = w * 0.14
        let right = w * 0.86
        let top = h * 0.06
        let bottom = h * 0.82
        let width = right - left
        let height = bottom - top
        let corner = width * 0.12

        var glass = Path()
        glass.move(to: CGPoint(x: left, y: top))
        glass.addLine(to: CGPoint(x: left, y: bottom - corner))
        glass.addQuadCurve(to: CGPoint(x: left + corner, y: bottom), control: CGPoint(x: left, y: bottom))
        glass.addLine(to: CGPoint(x: right - corner, y: bottom))
        glass.addQuadCurve(to: CGPoint(x: right, y: bottom - corner), control: CGPoint(x: right, y: bottom))
        glass.addLine(to: CGPoint(x: right, y: top))
        var inside = glass
        inside.closeSubpath()

        // Burner and flame sit under the glass.
        drawBurner(in: context, size: size, bottom: bottom, on: burnerOn, time: time)

        let volume = beaker.liquidVolumeLiters
        let fraction: Double = volume > 0 ? min(0.92, max(0.1, volume / capacity)) : 0
        let liquidTop = bottom - height * CGFloat(fraction)

        context.drawLayer { layer in
            layer.clip(to: inside)

            if let color = beaker.liquidColor, fraction > 0 {
                let rect = CGRect(x: left, y: liquidTop, width: width, height: bottom - liquidTop)
                layer.fill(Path(rect), with: .color(color.color.opacity(0.78)))
                layer.stroke(
                    Path { $0.addLines([CGPoint(x: left, y: liquidTop), CGPoint(x: right, y: liquidTop)]) },
                    with: .color(.white.opacity(0.6)), lineWidth: 1.5)
            }

            drawSolids(in: layer, beaker: beaker, left: left, width: width, bottom: bottom, height: height)

            if bubbling && fraction > 0 {
                drawBubbles(in: layer, left: left, width: width, bottom: bottom, liquidTop: liquidTop, time: time)
            }
            drawGas(in: layer, beaker: beaker, left: left, width: width, top: top, liquidTop: fraction > 0 ? liquidTop : bottom, time: time)
        }

        // Fumes that rise past the rim of the glass.
        drawFumes(in: context, beaker: beaker, left: left, width: width, top: top, time: time)

        context.stroke(
            glass, with: .color(.primary.opacity(0.55)),
            style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        // Rim and graduation marks.
        context.stroke(
            Path { $0.addLines([CGPoint(x: left - 4, y: top), CGPoint(x: right + 4, y: top)]) },
            with: .color(.primary.opacity(0.55)), lineWidth: 2.5)
        for mark in 1...4 {
            let y = bottom - height * CGFloat(mark) / 5
            context.stroke(
                Path { $0.addLines([CGPoint(x: right - width * 0.14, y: y), CGPoint(x: right, y: y)]) },
                with: .color(.primary.opacity(0.3)), lineWidth: 1)
        }
    }

    // MARK: Pieces

    /// A repeatable pseudo-random number in 0..<1, so a beaker draws the same way every frame.
    private static func unit(_ index: Int, _ salt: Double) -> CGFloat {
        let value = sin(Double(index) * 12.9898 + salt * 78.233) * 43758.5453
        return CGFloat(value - floor(value))
    }

    private static func seed(_ text: String) -> Int {
        text.unicodeScalars.reduce(0) { ($0 &* 31 &+ Int($1.value)) & 0xFFFF }
    }

    private static func drawSolids(
        in context: GraphicsContext, beaker: Beaker, left: CGFloat, width: CGFloat,
        bottom: CGFloat, height: CGFloat
    ) {
        var layerIndex = 0
        for item in beaker.solids {
            let count = min(60, max(4, Int(item.grams * 3)))
            let base = seed(item.species.id)
            for k in 0..<count {
                let x = left + width * (0.08 + 0.84 * unit(base + k, 1))
                // Piles are taller in the middle of the beaker than at the walls.
                let hump = CGFloat(sin(Double.pi * Double((x - left) / width)))
                let scatter = unit(base + k, 2)
                let lift = height * 0.05 * CGFloat(layerIndex) + height * 0.12 * scatter * (0.4 + 0.6 * hump)
                let radius = 2.5 + 3.5 * unit(base + k, 3)
                let rect = CGRect(x: x - radius, y: bottom - lift - radius * 2, width: radius * 2, height: radius * 2)
                context.fill(Path(ellipseIn: rect), with: .color(item.species.color.color))
                context.stroke(Path(ellipseIn: rect), with: .color(.black.opacity(0.28)), lineWidth: 0.8)
            }
            layerIndex += 1
        }
    }

    private static func drawBubbles(
        in context: GraphicsContext, left: CGFloat, width: CGFloat, bottom: CGFloat,
        liquidTop: CGFloat, time: Double
    ) {
        for i in 0..<16 {
            let x = left + width * (0.12 + 0.76 * unit(i, 4))
            let speed = 0.35 + 0.5 * Double(unit(i, 5))
            let phase = (time * speed + Double(unit(i, 6))).truncatingRemainder(dividingBy: 1)
            let y = bottom - (bottom - liquidTop) * CGFloat(phase)
            let radius = 1.8 + 3.2 * unit(i, 7)
            let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
            context.stroke(Path(ellipseIn: rect), with: .color(.white.opacity(0.85)), lineWidth: 1.2)
            context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.25)))
        }
    }

    /// Gas colors: colorless gases show only a faint shimmer.
    private static func gasColor(_ species: Species) -> (Color, Double) {
        species.color.isPale ? (Color.gray, 0.16) : (species.color.color, 0.42)
    }

    private static func drawGas(
        in context: GraphicsContext, beaker: Beaker, left: CGFloat, width: CGFloat,
        top: CGFloat, liquidTop: CGFloat, time: Double
    ) {
        guard liquidTop - top > 4 else { return }
        for (index, item) in beaker.gases.enumerated() {
            let (color, opacity) = gasColor(item.species)
            let strength = min(1, 0.4 + item.moles * 4)
            for k in 0..<5 {
                let drift = CGFloat(sin(time * 0.8 + Double(k) * 1.7 + Double(index))) * width * 0.06
                let x = left + width * (0.15 + 0.7 * unit(index * 7 + k, 8)) + drift
                let y = top + (liquidTop - top) * (0.15 + 0.7 * unit(index * 7 + k, 9))
                let rx = width * (0.16 + 0.1 * unit(k, 10))
                let ry = (liquidTop - top) * 0.12
                context.fill(
                    Path(ellipseIn: CGRect(x: x - rx, y: y - ry, width: rx * 2, height: ry * 2)),
                    with: .color(color.opacity(opacity * strength)))
            }
        }
    }

    private static func drawFumes(
        in context: GraphicsContext, beaker: Beaker, left: CGFloat, width: CGFloat,
        top: CGFloat, time: Double
    ) {
        for (index, item) in beaker.gases.enumerated() where item.moles > 0.01 {
            let (color, opacity) = gasColor(item.species)
            for k in 0..<3 {
                let phase = (time * 0.25 + Double(unit(index * 5 + k, 11))).truncatingRemainder(dividingBy: 1)
                let sway = CGFloat(sin(time + Double(k))) * width * 0.05
                let x = left + width * (0.3 + 0.4 * unit(index * 5 + k, 12)) + sway
                let y = top - CGFloat(phase) * top * 0.95
                let r = width * (0.05 + 0.08 * CGFloat(phase))
                context.fill(
                    Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                    with: .color(color.opacity(opacity * (1 - phase) * 0.9)))
            }
        }
    }

    private static func drawBurner(
        in context: GraphicsContext, size: CGSize, bottom: CGFloat, on: Bool, time: Double
    ) {
        let centerX = size.width / 2
        let baseTop = size.height * 0.93
        let base = Path(
            roundedRect: CGRect(x: centerX - size.width * 0.16, y: baseTop, width: size.width * 0.32, height: size.height * 0.05),
            cornerRadius: 3)
        context.fill(base, with: .color(.gray.opacity(0.7)))

        guard on else { return }
        let flicker = CGFloat(0.85 + 0.15 * sin(time * 22))
        let flameHeight = (baseTop - bottom) * flicker
        var flame = Path()
        flame.move(to: CGPoint(x: centerX, y: baseTop - flameHeight))
        flame.addQuadCurve(
            to: CGPoint(x: centerX, y: baseTop),
            control: CGPoint(x: centerX + size.width * 0.13, y: baseTop - flameHeight * 0.3))
        flame.addQuadCurve(
            to: CGPoint(x: centerX, y: baseTop - flameHeight),
            control: CGPoint(x: centerX - size.width * 0.13, y: baseTop - flameHeight * 0.3))
        context.fill(flame, with: .color(.orange.opacity(0.9)))

        var core = Path()
        core.move(to: CGPoint(x: centerX, y: baseTop - flameHeight * 0.55))
        core.addQuadCurve(
            to: CGPoint(x: centerX, y: baseTop),
            control: CGPoint(x: centerX + size.width * 0.06, y: baseTop - flameHeight * 0.15))
        core.addQuadCurve(
            to: CGPoint(x: centerX, y: baseTop - flameHeight * 0.55),
            control: CGPoint(x: centerX - size.width * 0.06, y: baseTop - flameHeight * 0.15))
        context.fill(core, with: .color(.blue.opacity(0.75)))
    }
}
