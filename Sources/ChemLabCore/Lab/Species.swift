public enum MatterState: String, Sendable, CaseIterable {
    case solid, liquid, gas
    /// Dissolved in water.
    case aqueous

    public var title: String {
        switch self {
        case .solid: "Solid"
        case .liquid: "Liquid"
        case .gas: "Gas"
        case .aqueous: "Dissolved"
        }
    }

    /// State label used in equations: "(s)", "(l)", "(g)", "(aq)".
    public var label: String {
        switch self {
        case .solid: "(s)"
        case .liquid: "(l)"
        case .gas: "(g)"
        case .aqueous: "(aq)"
        }
    }
}

/// A colour with no UI dependency; the views turn it into a SwiftUI `Color`.
public struct RGB: Sendable, Hashable {
    public let red: Double
    public let green: Double
    public let blue: Double

    public init(_ red: Double, _ green: Double, _ blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public static let white = RGB(0.95, 0.95, 0.95)
    public static let water = RGB(0.80, 0.90, 1.00)

    /// `amount` of 0 gives `self`, 1 gives `other`.
    public func blended(with other: RGB, amount: Double) -> RGB {
        let t = min(max(amount, 0), 1)
        return RGB(
            red + (other.red - red) * t,
            green + (other.green - green) * t,
            blue + (other.blue - blue) * t)
    }
}

/// Something that can go in a beaker: an element, a compound, or water.
///
/// `role` says what kind of chemical it is, which is what the generic reaction
/// rules (acid + metal, acid + base, precipitation) look at.
public struct Species: Identifiable, Sendable, Hashable {
    public enum Role: Sendable, Hashable {
        case metal(charge: Int)
        /// `protons` is how many H⁺ one molecule can give away.
        case acid(anion: Ion, protons: Int, strong: Bool)
        /// A metal hydroxide such as NaOH or Ca(OH)₂.
        case base(cation: Ion, strong: Bool)
        case ammonia
        /// A metal oxide that makes a base with water, such as CaO.
        case basicOxide(cation: Ion)
        case salt(cation: Ion, anion: Ion)
        case water
        case gas
        case other
    }

    /// Hill formula, so it matches `Formula.hill` and is unique.
    public let id: String
    public let formula: Formula
    /// "H₂SO₄" as people write it.
    public let displayFormula: String
    public let name: String
    public let role: Role
    /// State of the pure substance at room temperature.
    public let roomState: MatterState
    /// Degrees Celsius.
    public let meltingPoint: Double?
    public let boilingPoint: Double?
    public let hazards: [HazardNote]
    /// Colour of the pure substance.
    public let color: RGB
    /// Colour it gives water when dissolved; nil means colorless.
    public let solutionColor: RGB?
    private let explicitSolubility: Solubility?

    public init(
        _ text: String, name: String? = nil, role: Role, state: MatterState = .solid,
        melts: Double? = nil, boils: Double? = nil, hazards extra: [HazardNote] = [],
        color: RGB = .white, solutionColor: RGB? = nil, solubility: Solubility? = nil
    ) {
        guard let parsed = Formula(parsing: text) else {
            preconditionFailure("Species formula does not parse: \(text)")
        }
        let known = Naming.identify(parsed)
        var merged = known?.hazards ?? []
        // Catalog notes win; an extra note is added only for a hazard not already listed.
        for note in extra where !merged.contains(where: { $0.hazard == note.hazard }) {
            merged.append(note)
        }

        self.id = parsed.hill
        self.formula = parsed
        self.displayFormula = Formula.subscripted(text)
        self.name = name ?? known?.displayName ?? Formula.subscripted(text)
        self.role = role
        self.roomState = state
        self.meltingPoint = melts
        self.boilingPoint = boils
        self.hazards = merged
        self.color = color
        self.solutionColor = solutionColor
        self.explicitSolubility = solubility
    }

    public var molarMass: Double { formula.molarMass }

    public var solubility: Solubility {
        if let explicitSolubility { return explicitSolubility }
        switch role {
        case .salt(let cation, let anion):
            return SolubilityRules.solubility(cation: cation, anion: anion)
        case .base(let cation, _):
            if let hydroxide = IonCatalog.anion("OH", charge: -1) {
                return SolubilityRules.solubility(cation: cation, anion: hydroxide)
            }
            return .insoluble
        case .acid, .ammonia, .water:
            return .soluble
        case .metal, .basicOxide, .gas, .other:
            return .insoluble
        }
    }

    /// True for gases that bubble out of water instead of dissolving.
    public var escapesAsGas: Bool { roomState == .gas && solubility != .soluble }

    public var isMetal: Bool {
        if case .metal = role { return true }
        return false
    }

    public var isAcid: Bool {
        if case .acid = role { return true }
        return false
    }

    public var isWater: Bool { role == .water }

    /// Element symbol for a single-element species such as "Zn" or "Na".
    public var elementSymbol: String? {
        formula.counts.count == 1 ? formula.counts.keys.first : nil
    }
}
