import ChemLabCore
import CoreGraphics
import Observation

public enum BuilderTool: String, CaseIterable, Identifiable, Sendable {
    case move, bond, erase

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .move: "Move"
        case .bond: "Bond"
        case .erase: "Erase"
        }
    }

    public var symbolName: String {
        switch self {
        case .move: "hand.point.up.left"
        case .bond: "link"
        case .erase: "eraser"
        }
    }

    public var help: String {
        switch self {
        case .move: "Drag atoms to move them. Tap one to select it."
        case .bond: "Drag from one atom to another. Repeat to make double or triple bonds."
        case .erase: "Tap an atom or bond to remove it."
        }
    }
}

/// What the info panel shows for one connected group of atoms.
public struct MoleculeReport: Identifiable {
    /// Lowest atom ID in the group; stable while the group is edited.
    public let id: Int
    public let formula: Formula
    /// Set only when the group is complete and something is known about it.
    public let identification: Identification?
    public let isComplete: Bool
    /// Plain-language reasons the group isn't complete yet.
    public let issues: [String]
}

@MainActor @Observable
public final class BuilderModel {
    public private(set) var molecule = Molecule()
    public private(set) var positions: [Int: CGPoint] = [:]
    public var tool: BuilderTool = .move
    public private(set) var selectedAtomID: Int?
    /// When on, a new atom bonds to the selected atom if that atom has room.
    public var autoBond = true
    /// Where atoms land when nothing is selected. The canvas keeps this at its centre.
    public var canvasCenter = CGPoint(x: 300, y: 250)

    private struct Snapshot {
        let molecule: Molecule
        let positions: [Int: CGPoint]
        let selectedAtomID: Int?
    }

    private var undoStack: [Snapshot] = []
    private var redoStack: [Snapshot] = []
    /// While one atom is being dragged, only the first movement is an undo step.
    private var movingAtomID: Int?
    private static let maxUndoSteps = 100

    public init() {}

    // MARK: Undo and redo

    public var canUndo: Bool { !undoStack.isEmpty }
    public var canRedo: Bool { !redoStack.isEmpty }

    public func undo() {
        guard let previous = undoStack.popLast() else { return }
        redoStack.append(snapshot())
        restore(previous)
    }

    public func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(snapshot())
        restore(next)
    }

    private func snapshot() -> Snapshot {
        Snapshot(molecule: molecule, positions: positions, selectedAtomID: selectedAtomID)
    }

    private func restore(_ snapshot: Snapshot) {
        molecule = snapshot.molecule
        positions = snapshot.positions
        selectedAtomID = snapshot.selectedAtomID
        movingAtomID = nil
    }

    /// Call before every change so it can be undone.
    private func checkpoint() {
        undoStack.append(snapshot())
        if undoStack.count > Self.maxUndoSteps { undoStack.removeFirst() }
        redoStack.removeAll()
        movingAtomID = nil
    }

    // MARK: Editing

    @discardableResult
    public func addAtom(_ element: Element) -> Int {
        checkpoint()
        let others = Array(positions.values)
        let anchorID = autoBond ? selectedAtomID : nil

        if let anchorID, let anchor = positions[anchorID], canBond(anchorID, with: element) {
            let id = molecule.addAtom(element)
            positions[id] = Placement.aroundAnchor(anchor, others: others)
            try? molecule.addBond(anchorID, id)
            return id
        }

        let id = molecule.addAtom(element)
        positions[id] = Placement.nearCenter(canvasCenter, others: others)
        if selectedAtomID == nil { selectedAtomID = id }
        return id
    }

    /// Drops a ready-made molecule (an acid, base or salt) onto the canvas in a
    /// free spot near the middle. The current selection is left alone.
    public func insert(_ substance: CommonSubstance) {
        checkpoint()
        let piece = substance.makeMolecule()
        let layout = GraphLayout.positions(for: piece)
        let center = Placement.cluster(
            Array(layout.values), nearCenter: canvasCenter, others: Array(positions.values))
        let mapping = molecule.insert(piece)
        for (oldID, newID) in mapping {
            let offset = layout[oldID] ?? .zero
            positions[newID] = CGPoint(x: center.x + offset.x, y: center.y + offset.y)
        }
    }

    public func removeAtom(_ id: Int) {
        guard molecule.atom(id) != nil else { return }
        checkpoint()
        molecule.removeAtom(id)
        positions[id] = nil
        if selectedAtomID == id { selectedAtomID = nil }
    }

    public func moveAtom(_ id: Int, to point: CGPoint) {
        guard positions[id] != nil else { return }
        if movingAtomID != id {
            checkpoint()
            movingAtomID = id
        }
        positions[id] = point
    }

    /// Raises the bond order between two atoms: none, single, double, triple, none.
    public func cycleBond(_ a: Int, _ b: Int) {
        guard a != b else { return }
        checkpoint()
        let existing = molecule.bonds.first { $0.a == min(a, b) && $0.b == max(a, b) }
        let next = ((existing?.order ?? 0) + 1) % 4
        if next == 0 {
            molecule.removeBond(a, b)
        } else {
            try? molecule.addBond(a, b, order: next)
        }
    }

    public func removeBond(_ a: Int, _ b: Int) {
        checkpoint()
        molecule.removeBond(a, b)
    }

    public func select(_ id: Int?) {
        selectedAtomID = id.flatMap { molecule.atom($0) == nil ? nil : $0 }
    }

    public func clear() {
        if !molecule.atoms.isEmpty { checkpoint() }
        molecule = Molecule()
        positions = [:]
        selectedAtomID = nil
    }

    // MARK: Hit testing

    public func atomID(at point: CGPoint, tolerance: CGFloat = 4) -> Int? {
        positions
            .map { ($0.key, Placement.distance($0.value, point)) }
            .filter { $0.1 <= Placement.atomRadius + tolerance }
            .min { $0.1 < $1.1 }?.0
    }

    public func bond(at point: CGPoint, tolerance: CGFloat = 8) -> Bond? {
        molecule.bonds
            .compactMap { bond -> (Bond, CGFloat)? in
                guard let a = positions[bond.a], let b = positions[bond.b] else { return nil }
                return (bond, Placement.distance(from: point, toSegment: a, b))
            }
            .filter { $0.1 <= tolerance }
            .min { $0.1 < $1.1 }?.0
    }

    // MARK: Reports

    public var reports: [MoleculeReport] {
        molecule.connectedComponents().compactMap { group in
            guard let firstID = group.atoms.map(\.id).min() else { return nil }
            return MoleculeReport(
                id: firstID,
                formula: Formula(group),
                identification: Naming.identify(group),
                isComplete: group.isComplete,
                issues: issues(in: group))
        }
    }

    private func issues(in group: Molecule) -> [String] {
        group.atoms.compactMap { atom in
            guard let state = group.valenceState(of: atom.id), state != .satisfied else { return nil }
            let total = group.bondTotal(of: atom.id)
            let max = atom.allowedValences.max() ?? 0
            switch state {
            case .open:
                return "\(atom.element.name) has \(total) of \(max) bonds"
            case .overValent:
                return max == 0
                    ? "\(atom.element.name) doesn't normally bond"
                    : "\(atom.element.name) has too many bonds (\(total), usually at most \(max))"
            case .satisfied:
                return nil
            }
        }
    }

    private func canBond(_ anchorID: Int, with element: Element) -> Bool {
        guard let anchor = molecule.atom(anchorID),
            let anchorMax = anchor.allowedValences.max(),
            !element.valences.isEmpty
        else { return false }
        return molecule.bondTotal(of: anchorID) < anchorMax
    }
}
