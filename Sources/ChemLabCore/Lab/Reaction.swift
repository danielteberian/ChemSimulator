import Foundation

/// One species in a reaction, with its coefficient.
public struct Participant: Sendable, Hashable {
    public let species: Species
    public let coefficient: Int

    public init(_ species: Species, _ coefficient: Int) {
        self.species = species
        self.coefficient = coefficient
    }
}

/// When a reaction is allowed to happen.
public struct ReactionConditions: Sendable, Hashable {
    /// Degrees Celsius the beaker must reach (ignition, decomposition).
    public var minTemperature: Double?
    /// Species id that must be concentrated (at least `Beaker.concentratedMolarity`).
    public var requiresConcentrated: String?
    /// Species id that must be dilute.
    public var requiresDilute: String?
    /// True when the reaction works without water. Otherwise dissolvable
    /// reactants (acids, bases, salts) have to be dissolved first.
    public var worksDry: Bool

    public init(
        minTemperature: Double? = nil, requiresConcentrated: String? = nil,
        requiresDilute: String? = nil, worksDry: Bool = false
    ) {
        self.minTemperature = minTemperature
        self.requiresConcentrated = requiresConcentrated
        self.requiresDilute = requiresDilute
        self.worksDry = worksDry
    }
}

/// A reaction rule, written as data. The engine only reads these; adding a
/// reaction never needs new logic.
public struct Reaction: Identifiable, Sendable, Hashable {
    public enum Kind: String, Sendable, CaseIterable {
        case acidMetal, neutralization, precipitation, displacement
        case metalWater, gasEvolution, decomposition, combustion, redox, other

        public var title: String {
            switch self {
            case .acidMetal: "Acid + metal"
            case .neutralization: "Neutralization"
            case .precipitation: "Precipitation"
            case .displacement: "Displacement"
            case .metalWater: "Metal + water"
            case .gasEvolution: "Gas formation"
            case .decomposition: "Decomposition"
            case .combustion: "Combustion"
            case .redox: "Redox"
            case .other: "Reaction"
            }
        }
    }

    public let kind: Kind
    public let reactants: [Participant]
    public let products: [Participant]
    public let conditions: ReactionConditions
    /// Heat change in kJ for the reaction as written. Negative gives off heat.
    public let enthalpy: Double
    /// Hazards of what happens (not of the substances), shown when it fires.
    public let hazards: [HazardNote]
    /// The "why did that happen?" text.
    public let why: String

    public init(
        _ kind: Kind, reactants: [Participant], products: [Participant],
        conditions: ReactionConditions = ReactionConditions(), enthalpy: Double = 0,
        hazards: [HazardNote] = [], why: String
    ) {
        self.kind = kind
        self.reactants = reactants
        self.products = products
        self.conditions = conditions
        self.enthalpy = enthalpy
        self.hazards = hazards
        self.why = why
    }

    /// Stable key made from the equation, e.g. "H2O+Na>H2+HNaO".
    public var id: String {
        let left = reactants.map { "\($0.coefficient)\($0.species.id)" }.sorted().joined(separator: "+")
        let right = products.map { "\($0.coefficient)\($0.species.id)" }.sorted().joined(separator: "+")
        return "\(left)>\(right)"
    }

    /// "Zn + 2 HCl → ZnCl₂ + H₂".
    public var equation: String {
        func side(_ participants: [Participant]) -> String {
            participants.map {
                ($0.coefficient > 1 ? "\($0.coefficient) " : "") + $0.species.displayFormula
            }.joined(separator: " + ")
        }
        return side(reactants) + " → " + side(products)
    }

    /// True when every element balances.
    public var isBalanced: Bool {
        EquationBalancer.isBalanced(
            reactants: reactants.map { ($0.species.formula, $0.coefficient) },
            products: products.map { ($0.species.formula, $0.coefficient) })
    }

    /// Hazards from the reaction plus those of the products, without repeats.
    public var allHazards: [HazardNote] {
        var result = hazards
        for product in products {
            for note in product.species.hazards where !result.contains(note) { result.append(note) }
        }
        return result
    }

    // MARK: Building from text

    /// Builds a reaction from "Cu + 4 HNO3 -> Cu(NO3)2 + 2 NO2 + 2 H2O".
    /// Returns nil if the text is malformed or names a species the lab doesn't have.
    public static func parse(
        _ equation: String, _ kind: Kind, conditions: ReactionConditions = ReactionConditions(),
        enthalpy: Double = 0, hazards: [HazardNote] = [], why: String
    ) -> Reaction? {
        let sides = equation.components(separatedBy: "->")
        guard sides.count == 2,
            let reactants = participants(in: sides[0]),
            let products = participants(in: sides[1])
        else { return nil }
        return Reaction(
            kind, reactants: reactants, products: products, conditions: conditions,
            enthalpy: enthalpy, hazards: hazards, why: why)
    }

    private static func participants(in text: String) -> [Participant]? {
        var result: [Participant] = []
        for term in text.components(separatedBy: " + ") {
            let pieces = term.split(separator: " ").map(String.init)
            var coefficient = 1
            let formulaText: String
            switch pieces.count {
            case 1:
                formulaText = pieces[0]
            case 2:
                guard let n = Int(pieces[0]), n > 0 else { return nil }
                coefficient = n
                formulaText = pieces[1]
            default:
                return nil
            }
            guard let species = SpeciesCatalog.species(formula: formulaText) else { return nil }
            result.append(Participant(species, coefficient))
        }
        return result.isEmpty ? nil : result
    }
}
