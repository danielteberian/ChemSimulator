public struct Atom: Sendable, Hashable, Identifiable {
    public let id: Int
    public let element: Element
    /// Charge on this atom in a drawn structure, e.g. +1 on N and -1 on O in nitric acid.
    public let formalCharge: Int

    /// Bond counts this atom can take. A charged atom behaves like the neutral
    /// element with the same number of electrons (N+ like C, O- like F).
    /// Charged transition metals and bare ions (Na+, Cl-) take no bonds.
    public var allowedValences: [Int] {
        guard formalCharge != 0 else { return element.valences }
        switch element.category {
        case .transitionMetal, .lanthanide, .actinide:
            return []
        default:
            let twin = PeriodicTable.element(number: element.number - formalCharge)
            return twin?.valences ?? []
        }
    }

    /// "+", "−", "2+", "3−", or "" when neutral.
    public var chargeLabel: String {
        switch formalCharge {
        case 0: ""
        case 1: "+"
        case -1: "\u{2212}"
        case let n where n > 0: "\(n)+"
        default: "\(-formalCharge)\u{2212}"
        }
    }
}

public struct Bond: Sendable, Hashable {
    public let a: Int
    public let b: Int
    /// 1 = single, 2 = double, 3 = triple.
    public let order: Int

    func involves(_ atomID: Int) -> Bool { a == atomID || b == atomID }
    func other(than atomID: Int) -> Int { a == atomID ? b : a }
}

public enum BondError: Error, Equatable {
    case unknownAtom
    case sameAtom
    case invalidOrder
}

/// State of a single atom's valence.
public enum ValenceState: Sendable, Equatable {
    /// Bond total matches one of the element's common valences.
    case satisfied
    /// Bond total is below what the element wants; more bonds can be added.
    case open
    /// Bond total exceeds the element's maximum valence.
    case overValent
}

/// A set of atoms and the bonds between them. May hold several disconnected
/// pieces; use `connectedComponents()` to split them.
public struct Molecule: Sendable, Equatable {
    public private(set) var atoms: [Atom] = []
    public private(set) var bonds: [Bond] = []
    private var nextID = 0

    public init() {}

    @discardableResult
    public mutating func addAtom(_ element: Element, formalCharge: Int = 0) -> Int {
        let id = nextID
        nextID += 1
        atoms.append(Atom(id: id, element: element, formalCharge: formalCharge))
        return id
    }

    /// Sum of formal charges. Zero for neutral molecules.
    public var netCharge: Int {
        atoms.reduce(0) { $0 + $1.formalCharge }
    }

    /// Copies all of `other` into this molecule. Returns old atom ID -> new atom ID.
    @discardableResult
    public mutating func insert(_ other: Molecule) -> [Int: Int] {
        var mapping: [Int: Int] = [:]
        for atom in other.atoms {
            mapping[atom.id] = addAtom(atom.element, formalCharge: atom.formalCharge)
        }
        for bond in other.bonds {
            if let a = mapping[bond.a], let b = mapping[bond.b] {
                _ = try? addBond(a, b, order: bond.order)
            }
        }
        return mapping
    }

    /// Adds a bond, or replaces the order if the two atoms are already bonded.
    public mutating func addBond(_ a: Int, _ b: Int, order: Int = 1) throws {
        guard (1...3).contains(order) else { throw BondError.invalidOrder }
        guard a != b else { throw BondError.sameAtom }
        guard atom(a) != nil, atom(b) != nil else { throw BondError.unknownAtom }
        let (lo, hi) = (min(a, b), max(a, b))
        bonds.removeAll { $0.a == lo && $0.b == hi }
        bonds.append(Bond(a: lo, b: hi, order: order))
    }

    public mutating func removeBond(_ a: Int, _ b: Int) {
        let (lo, hi) = (min(a, b), max(a, b))
        bonds.removeAll { $0.a == lo && $0.b == hi }
    }

    public mutating func removeAtom(_ id: Int) {
        atoms.removeAll { $0.id == id }
        bonds.removeAll { $0.involves(id) }
    }

    public func atom(_ id: Int) -> Atom? {
        atoms.first { $0.id == id }
    }

    /// Sum of bond orders touching the atom.
    public func bondTotal(of id: Int) -> Int {
        bonds.filter { $0.involves(id) }.reduce(0) { $0 + $1.order }
    }

    public func neighbors(of id: Int) -> [Int] {
        bonds.filter { $0.involves(id) }.map { $0.other(than: id) }
    }

    public func valenceState(of id: Int) -> ValenceState? {
        guard let atom = atom(id) else { return nil }
        let total = bondTotal(of: id)
        // A lone metal atom stands for the element itself (Fe, Na, ...).
        if total == 0 && atom.element.isMetal && atom.formalCharge == 0 { return .satisfied }
        let valences = atom.allowedValences
        guard let maxValence = valences.max() else {
            return total == 0 ? .satisfied : .overValent
        }
        if valences.contains(total) { return .satisfied }
        return total < maxValence ? .open : .overValent
    }

    public var hasOverValentAtom: Bool {
        atoms.contains { valenceState(of: $0.id) == .overValent }
    }

    /// True when non-empty, in one piece, and every atom's valence is satisfied.
    public var isComplete: Bool {
        !atoms.isEmpty
            && connectedComponents().count == 1
            && atoms.allSatisfy { valenceState(of: $0.id) == .satisfied }
    }

    public func connectedComponents() -> [Molecule] {
        var seen = Set<Int>()
        var result: [Molecule] = []
        for start in atoms where !seen.contains(start.id) {
            var group = [start.id]
            var stack = [start.id]
            seen.insert(start.id)
            while let current = stack.popLast() {
                for next in neighbors(of: current) where seen.insert(next).inserted {
                    group.append(next)
                    stack.append(next)
                }
            }
            result.append(subgraph(of: Set(group)))
        }
        return result
    }

    private func subgraph(of ids: Set<Int>) -> Molecule {
        var m = Molecule()
        m.nextID = nextID
        m.atoms = atoms.filter { ids.contains($0.id) }
        m.bonds = bonds.filter { ids.contains($0.a) && ids.contains($0.b) }
        return m
    }
}
