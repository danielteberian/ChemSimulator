public struct Element: Sendable, Hashable, Identifiable {
    public enum Category: Sendable, Hashable {
        case nonmetal, nobleGas, alkaliMetal, alkalineEarthMetal
        case transitionMetal, postTransitionMetal, metalloid, halogen
        case lanthanide, actinide
    }

    public let number: Int
    public let symbol: String
    public let name: String
    /// Standard atomic weight in u.
    public let atomicMass: Double
    /// Pauling electronegativity, nil when not defined (e.g. most noble gases).
    public let electronegativity: Double?
    /// Covalent bond counts this element commonly forms, lowest first.
    public let valences: [Int]
    /// Common monatomic ion charges, e.g. Na: [1], Fe: [2, 3], Cl: [-1].
    public let ionCharges: [Int]
    public let category: Category

    public var id: Int { number }

    public var isMetal: Bool {
        switch category {
        case .alkaliMetal, .alkalineEarthMetal, .transitionMetal,
             .postTransitionMetal, .lanthanide, .actinide:
            return true
        default:
            return false
        }
    }

    public init(
        number: Int, symbol: String, name: String, atomicMass: Double,
        electronegativity: Double?, valences: [Int], ionCharges: [Int] = [],
        category: Category
    ) {
        self.number = number
        self.symbol = symbol
        self.name = name
        self.atomicMass = atomicMass
        self.electronegativity = electronegativity
        self.valences = valences
        self.ionCharges = ionCharges
        self.category = category
    }
}
