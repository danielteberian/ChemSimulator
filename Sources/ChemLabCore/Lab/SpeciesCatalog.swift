/// Groups shown in the lab's shelf.
public enum SpeciesGroup: String, CaseIterable, Identifiable, Sendable {
    case metals, acids, bases, salts, gases, other

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .metals: "Metals"
        case .acids: "Acids"
        case .bases: "Bases"
        case .salts: "Salts"
        case .gases: "Gases"
        case .other: "Other"
        }
    }
}

extension Species {
    public var group: SpeciesGroup {
        switch role {
        case .metal: .metals
        case .acid: .acids
        case .base, .ammonia, .basicOxide: .bases
        case .salt: .salts
        case .gas: .gases
        case .water, .other: .other
        }
    }

    /// The ions this species splits into when dissolved, when it is an
    /// ionic compound, an acid or a base.
    public var ionPair: (cation: Ion, anion: Ion)? {
        switch role {
        case .salt(let cation, let anion):
            return (cation, anion)
        case .base(let cation, _):
            guard let hydroxide = IonCatalog.anion("OH", charge: -1) else { return nil }
            return (cation, hydroxide)
        case .acid(let anion, _, _):
            guard let proton = IonCatalog.cation("H", charge: 1) else { return nil }
            return (proton, anion)
        default:
            return nil
        }
    }
}

/// Every substance the lab knows, plus builders for salts and bases the
/// library doesn't list (a reaction can make any combination of known ions).
public enum SpeciesCatalog {
    public static let all: [Species] = library

    private static let byID: [String: Species] =
        Dictionary(library.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

    public static func species(id: String) -> Species? { byID[id] }

    /// Looks up by formula text such as "H2SO4" or "Ca(OH)2".
    public static func species(formula text: String) -> Species? {
        Formula(parsing: text).flatMap { byID[$0.hill] }
    }

    public static func species(in group: SpeciesGroup) -> [Species] {
        library.filter { $0.group == group }
    }

    public static var water: Species {
        guard let water = species(formula: "H2O") else { preconditionFailure("Water is missing") }
        return water
    }

    public static func metal(symbol: String) -> Species? {
        library.first { $0.isMetal && $0.elementSymbol == symbol }
    }

    /// The acid that gives `anion` (Cl⁻ -> HCl), if the library has one.
    public static func acid(anion: Ion) -> Species? {
        library.first {
            if case .acid(let acidAnion, _, _) = $0.role { return acidAnion == anion }
            return false
        }
    }

    /// The metal hydroxide for `cation`, from the library or built on the spot.
    public static func base(cation: Ion) -> Species? {
        // Ammonium hydroxide isn't a real compound (ammonia in water is NH3), and H⁺ + OH⁻ is water.
        guard let hydroxide = IonCatalog.anion("OH", charge: -1),
            cation.symbol != "H", cation.symbol != "NH4"
        else { return nil }
        let text = IonCatalog.saltFormula(cation: cation, anion: hydroxide)
        if let known = species(formula: text) { return known }
        return Species(
            text, name: IonCatalog.saltName(cation: cation, anion: hydroxide),
            role: .base(cation: cation, strong: false), hazards: extraHazards(cation: cation))
    }

    /// The salt for a cation and anion, from the library or built on the spot.
    public static func salt(cation: Ion, anion: Ion) -> Species {
        makeSalt(cation: cation, anion: anion)
    }

    /// Whatever species a cation and anion make together: an acid, a base or a salt.
    public static func product(cation: Ion, anion: Ion) -> Species? {
        if cation.symbol == "H" { return acid(anion: anion) }
        if anion.symbol == "OH" { return base(cation: cation) }
        return salt(cation: cation, anion: anion)
    }

    /// Like `buildSalt`, but returns the library's own entry when there is one.
    static func makeSalt(cation: Ion, anion: Ion) -> Species {
        let text = IonCatalog.saltFormula(cation: cation, anion: anion)
        if let known = species(formula: text) { return known }
        return buildSalt(cation: cation, anion: anion)
    }

    /// Builds a salt without consulting the library. The library's own data uses
    /// this, since looking itself up while it is still being built would loop.
    static func buildSalt(
        cation: Ion, anion: Ion, color: RGB = .white, solutionColor: RGB? = nil,
        melts: Double? = nil, hazards extra: [HazardNote] = []
    ) -> Species {
        let text = IonCatalog.saltFormula(cation: cation, anion: anion)
        let name = Formula(parsing: text).flatMap { Naming.identify($0)?.displayName }
            ?? IonCatalog.saltName(cation: cation, anion: anion)
        return Species(
            text, name: name, role: .salt(cation: cation, anion: anion), melts: melts,
            hazards: extra + extraHazards(cation: cation), color: color, solutionColor: solutionColor)
    }

    /// Hazards that come with a metal ion, so a salt made on the spot is still labelled.
    static func extraHazards(cation: Ion) -> [HazardNote] {
        switch cation.symbol {
        case "Pb":
            return [
                HazardNote(.toxic, "Lead compounds are poisonous and build up in the body."),
                HazardNote(.healthHazard, "Can harm fertility and children's development."),
            ]
        case "Ba":
            return [HazardNote(.toxic, "Soluble barium compounds are poisonous.")]
        case "Ni":
            return [HazardNote(.healthHazard, "Nickel compounds cause allergic skin reactions and may cause cancer.")]
        case "Ag":
            return [HazardNote(.environmental, "Silver compounds are very toxic to aquatic life.")]
        case "Cu":
            return [HazardNote(.environmental, "Copper compounds are very toxic to aquatic life.")]
        default:
            return []
        }
    }
}
