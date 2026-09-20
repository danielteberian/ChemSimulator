import ChemLabCore
import SwiftUI

/// Draws the molecule and turns touches/clicks into edits on the model.
struct MoleculeCanvas: View {
    let model: BuilderModel

    private struct DragState {
        let atomID: Int?
        /// Grab offset so the atom doesn't jump to the pointer.
        let grabOffset: CGSize
        var current: CGPoint
        var moved = false
    }

    @State private var drag: DragState?

    private let tapSlop: CGFloat = 5

    var body: some View {
        GeometryReader { proxy in
            Canvas { context, _ in draw(in: &context) }
                .contentShape(Rectangle())
                .gesture(dragGesture)
                .overlay { if model.molecule.atoms.isEmpty { emptyHint } }
                .onAppear { model.canvasCenter = center(of: proxy.size) }
                .onChange(of: proxy.size) { _, size in model.canvasCenter = center(of: size) }
        }
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityLabel("Molecule canvas")
    }

    private func center(of size: CGSize) -> CGPoint {
        CGPoint(x: size.width / 2, y: size.height / 2)
    }

    private var emptyHint: some View {
        VStack(spacing: 6) {
            Image(systemName: "atom").font(.largeTitle)
            Text("Pick an element to add an atom")
            Text("Try O, then H, then H").font(.caption)
        }
        .foregroundStyle(.secondary)
        .allowsHitTesting(false)
    }

    // MARK: Gestures

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                var state = drag ?? startDrag(at: value.startLocation)
                state.current = value.location
                if Placement.distance(value.location, value.startLocation) > tapSlop {
                    state.moved = true
                }
                if model.tool == .move, state.moved, let id = state.atomID {
                    model.moveAtom(
                        id,
                        to: CGPoint(
                            x: value.location.x + state.grabOffset.width,
                            y: value.location.y + state.grabOffset.height))
                }
                drag = state
            }
            .onEnded { value in
                defer { drag = nil }
                guard let state = drag else { return }
                if state.moved {
                    finishDrag(state, at: value.location)
                } else {
                    finishTap(at: value.startLocation, on: state.atomID)
                }
            }
    }

    private func startDrag(at point: CGPoint) -> DragState {
        let id = model.atomID(at: point)
        let offset =
            id.flatMap { model.positions[$0] }
            .map { CGSize(width: $0.x - point.x, height: $0.y - point.y) } ?? .zero
        return DragState(atomID: id, grabOffset: offset, current: point)
    }

    private func finishTap(at point: CGPoint, on atomID: Int?) {
        switch model.tool {
        case .move:
            model.select(atomID == model.selectedAtomID ? nil : atomID)
        case .bond:
            if atomID == nil, let bond = model.bond(at: point) { model.cycleBond(bond.a, bond.b) }
        case .erase:
            if let atomID {
                model.removeAtom(atomID)
            } else if let bond = model.bond(at: point) {
                model.removeBond(bond.a, bond.b)
            }
        }
    }

    private func finishDrag(_ state: DragState, at point: CGPoint) {
        guard model.tool == .bond, let from = state.atomID,
            let to = model.atomID(at: point), from != to
        else { return }
        model.cycleBond(from, to)
    }

    // MARK: Drawing

    private func draw(in context: inout GraphicsContext) {
        let positions = model.positions
        let lineColor = Color.primary.opacity(0.55)

        for bond in model.molecule.bonds {
            guard let a = positions[bond.a], let b = positions[bond.b] else { continue }
            drawBond(in: &context, from: a, to: b, order: bond.order, color: lineColor)
        }

        if model.tool == .bond, let state = drag, state.moved,
            let id = state.atomID, let start = positions[id]
        {
            var path = Path()
            path.move(to: start)
            path.addLine(to: state.current)
            context.stroke(
                path, with: .color(.accentColor),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 5]))
        }

        for atom in model.molecule.atoms {
            guard let p = positions[atom.id] else { continue }
            drawAtom(in: &context, atom: atom, at: p)
        }
    }

    private func drawBond(
        in context: inout GraphicsContext, from a: CGPoint, to b: CGPoint, order: Int, color: Color
    ) {
        let length = Placement.distance(a, b)
        guard length > 0 else { return }
        let nx = -(b.y - a.y) / length, ny = (b.x - a.x) / length
        let spacing: CGFloat = 6
        for i in 0..<order {
            let shift = (CGFloat(i) - CGFloat(order - 1) / 2) * spacing
            var path = Path()
            path.move(to: CGPoint(x: a.x + nx * shift, y: a.y + ny * shift))
            path.addLine(to: CGPoint(x: b.x + nx * shift, y: b.y + ny * shift))
            context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        }
    }

    private func drawAtom(in context: inout GraphicsContext, atom: Atom, at p: CGPoint) {
        let r = Placement.atomRadius
        let body = CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)
        context.fill(Path(ellipseIn: body), with: .color(atom.element.atomColor))
        context.stroke(Path(ellipseIn: body), with: .color(.primary.opacity(0.35)), lineWidth: 1)

        if let state = model.molecule.valenceState(of: atom.id) {
            let ring = body.insetBy(dx: -5, dy: -5)
            context.stroke(Path(ellipseIn: ring), with: .color(state.ringColor), lineWidth: 3)

            if state == .open, let maxValence = atom.allowedValences.max() {
                let missing = maxValence - model.molecule.bondTotal(of: atom.id)
                let badge = Text("+\(missing)").font(.caption2.bold()).foregroundStyle(.orange)
                context.draw(badge, at: CGPoint(x: p.x + r * 1.25, y: p.y - r * 1.3))
            }
        }

        if atom.id == model.selectedAtomID {
            let halo = body.insetBy(dx: -11, dy: -11)
            context.stroke(
                Path(ellipseIn: halo), with: .color(.accentColor),
                style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
        }

        let label = Text(atom.element.symbol)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(atom.element.atomLabelColor)
        context.draw(label, at: p)

        if atom.formalCharge != 0 {
            let charge = Text(atom.chargeLabel).font(.caption.bold()).foregroundStyle(.primary)
            context.draw(charge, at: CGPoint(x: p.x - r * 1.25, y: p.y - r * 1.3))
        }
    }
}
