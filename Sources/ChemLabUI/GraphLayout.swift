import ChemLabCore
import CoreGraphics
import Foundation

/// Lays out a molecule in 2D: a tree layout from the best-connected atom, then a
/// few rounds of spring relaxation so rings close up and nothing overlaps.
/// This is a drawing aid, not real molecular geometry.
enum GraphLayout {
    /// Position for every atom, centred on the origin, bonded atoms about
    /// `bondLength` apart.
    static func positions(
        for molecule: Molecule, bondLength: CGFloat = Placement.bondLength
    ) -> [Int: CGPoint] {
        guard molecule.atoms.count > 1 else {
            return Dictionary(uniqueKeysWithValues: molecule.atoms.map { ($0.id, CGPoint.zero) })
        }
        var positions = seed(molecule, bondLength: bondLength)
        relax(&positions, molecule: molecule, bondLength: bondLength)
        return recentered(positions)
    }

    // MARK: Tree layout

    private static func seed(_ molecule: Molecule, bondLength: CGFloat) -> [Int: CGPoint] {
        var positions: [Int: CGPoint] = [:]
        var componentOffset: CGFloat = 0

        // Start from the best-connected atom so branches fan out from the middle.
        let starts = molecule.atoms.map(\.id).sorted {
            molecule.neighbors(of: $0).count > molecule.neighbors(of: $1).count
        }

        for start in starts where positions[start] == nil {
            positions[start] = CGPoint(x: componentOffset, y: 0)
            var queue: [(id: Int, parent: Int?, backAngle: Double, depth: Int)] = [(start, nil, 0, 0)]
            var head = 0

            while head < queue.count {
                let (id, parent, backAngle, depth) = queue[head]
                head += 1
                guard let origin = positions[id] else { continue }
                let children = molecule.neighbors(of: id).filter { positions[$0] == nil }
                guard !children.isEmpty else { continue }

                // Share the directions around this atom evenly; the parent takes one slot.
                let slots = children.count + (parent == nil ? 0 : 1)
                let firstAngle = parent == nil ? 0.3 : backAngle
                // Two-neighbour atoms bend by 120 degrees instead of going straight,
                // alternating sides so chains zigzag instead of curling into a ring.
                let spread = slots == 2 ? 2 * Double.pi / 3 : 2 * Double.pi / Double(slots)
                let direction: Double = (slots == 2 && depth % 2 == 1) ? -1 : 1

                for (i, child) in children.enumerated() {
                    let step = parent == nil ? i : i + 1
                    let angle = firstAngle + direction * spread * Double(step)
                    positions[child] = CGPoint(
                        x: origin.x + bondLength * CGFloat(cos(angle)),
                        y: origin.y + bondLength * CGFloat(sin(angle)))
                    queue.append((child, id, angle + Double.pi, depth + 1))
                }
            }
            componentOffset += bondLength * 4
        }
        return positions
    }

    // MARK: Relaxation

    private struct Pair: Hashable {
        let low: Int
        let high: Int
        init(_ a: Int, _ b: Int) {
            low = min(a, b)
            high = max(a, b)
        }
    }

    private static func relax(
        _ positions: inout [Int: CGPoint], molecule: Molecule, bondLength: CGFloat
    ) {
        let ids = molecule.atoms.map(\.id)
        let bonded = Set(molecule.bonds.map { Pair($0.a, $0.b) })
        // Atoms that aren't bonded try to stay at least this far apart.
        let personalSpace = bondLength * 1.3

        for _ in 0..<300 {
            var nudges: [Int: CGVector] = [:]

            for bond in molecule.bonds {
                guard let a = positions[bond.a], let b = positions[bond.b] else { continue }
                let d = Placement.distance(a, b)
                guard d > 0.001 else { continue }
                // Pull together when too far, push apart when too close.
                let scale = (d - bondLength) * 0.15 / d
                let dx = (b.x - a.x) * scale
                let dy = (b.y - a.y) * scale
                nudges[bond.a, default: .zero].dx += dx
                nudges[bond.a, default: .zero].dy += dy
                nudges[bond.b, default: .zero].dx -= dx
                nudges[bond.b, default: .zero].dy -= dy
            }

            for i in 0..<ids.count {
                for j in (i + 1)..<ids.count where !bonded.contains(Pair(ids[i], ids[j])) {
                    guard let a = positions[ids[i]], let b = positions[ids[j]] else { continue }
                    let d = Placement.distance(a, b)
                    guard d < personalSpace else { continue }
                    let unit = d > 0.001 ? CGVector(dx: (b.x - a.x) / d, dy: (b.y - a.y) / d) : CGVector(dx: 1, dy: 0)
                    let push = (personalSpace - d) * 0.1
                    nudges[ids[i], default: .zero].dx -= unit.dx * push
                    nudges[ids[i], default: .zero].dy -= unit.dy * push
                    nudges[ids[j], default: .zero].dx += unit.dx * push
                    nudges[ids[j], default: .zero].dy += unit.dy * push
                }
            }

            for (id, nudge) in nudges {
                guard let p = positions[id] else { continue }
                positions[id] = CGPoint(x: p.x + nudge.dx, y: p.y + nudge.dy)
            }
        }
    }

    private static func recentered(_ positions: [Int: CGPoint]) -> [Int: CGPoint] {
        guard !positions.isEmpty else { return positions }
        let count = CGFloat(positions.count)
        let cx = positions.values.reduce(0) { $0 + $1.x } / count
        let cy = positions.values.reduce(0) { $0 + $1.y } / count
        return positions.mapValues { CGPoint(x: $0.x - cx, y: $0.y - cy) }
    }
}
