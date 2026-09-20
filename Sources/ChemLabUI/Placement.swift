import CoreGraphics
import Foundation

/// Picks positions for new atoms so they don't overlap existing ones.
enum Placement {
    static let atomRadius: CGFloat = 22
    static let bondLength: CGFloat = 78

    /// A spot around `anchor` at bond length, as far from every other atom as possible.
    static func aroundAnchor(_ anchor: CGPoint, others: [CGPoint]) -> CGPoint {
        var best = CGPoint(x: anchor.x + bondLength, y: anchor.y)
        var bestScore = -CGFloat.infinity
        for step in 0..<36 {
            let angle = Double(step) / 36 * 2 * .pi
            let p = CGPoint(
                x: anchor.x + bondLength * CGFloat(cos(angle)),
                y: anchor.y + bondLength * CGFloat(sin(angle)))
            let score = others.map { distance($0, p) }.min() ?? .infinity
            if score > bestScore {
                bestScore = score
                best = p
            }
        }
        return best
    }

    /// The free spot nearest `center`, searching outward in rings.
    static func nearCenter(_ center: CGPoint, others: [CGPoint]) -> CGPoint {
        let clearance = atomRadius * 2 + 12
        for ring in 0..<12 {
            let radius = CGFloat(ring) * clearance
            let count = max(1, ring * 6)
            for i in 0..<count {
                let angle = Double(i) / Double(count) * 2 * .pi
                let p = CGPoint(
                    x: center.x + radius * CGFloat(cos(angle)),
                    y: center.y + radius * CGFloat(sin(angle)))
                if others.allSatisfy({ distance($0, p) >= clearance }) { return p }
            }
        }
        return center
    }

    /// A centre for a whole group of atoms (given as offsets from that centre)
    /// so that none of them lands on an existing atom. Searches outward from `center`.
    static func cluster(_ offsets: [CGPoint], nearCenter center: CGPoint, others: [CGPoint]) -> CGPoint {
        let clearance = atomRadius * 2 + 12
        for ring in 0..<24 {
            let radius = CGFloat(ring) * clearance
            let count = max(1, ring * 8)
            for i in 0..<count {
                let angle = Double(i) / Double(count) * 2 * .pi
                let candidate = CGPoint(
                    x: center.x + radius * CGFloat(cos(angle)),
                    y: center.y + radius * CGFloat(sin(angle)))
                let fits = offsets.allSatisfy { offset in
                    let p = CGPoint(x: candidate.x + offset.x, y: candidate.y + offset.y)
                    return others.allSatisfy { distance($0, p) >= clearance }
                }
                if fits { return candidate }
            }
        }
        return center
    }

    static func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }

    /// Distance from `p` to the segment `a`-`b`.
    static func distance(from p: CGPoint, toSegment a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = b.x - a.x, dy = b.y - a.y
        let lengthSquared = dx * dx + dy * dy
        guard lengthSquared > 0 else { return distance(p, a) }
        let t = max(0, min(1, ((p.x - a.x) * dx + (p.y - a.y) * dy) / lengthSquared))
        return distance(p, CGPoint(x: a.x + t * dx, y: a.y + t * dy))
    }
}
