/// How well a salt dissolves in water at room temperature.
public enum Solubility: Sendable {
    case soluble
    /// Dissolves a little; shows up as a cloudy solid when made by mixing.
    case slightlySoluble
    case insoluble

    /// Whether mixing the ions in water leaves a solid behind.
    public var precipitates: Bool { self != .soluble }
}

/// The textbook solubility rules, written as data so they can be read, tested
/// and extended without touching the reaction logic.
public enum SolubilityRules {
    /// Cations whose salts are (almost) always soluble.
    private static let alwaysSolubleCations: Set<String> = ["Li", "Na", "K", "NH4"]

    /// Anions whose salts are (almost) always soluble.
    private static let alwaysSolubleAnions: Set<String> = ["NO3", "CH3COO", "HCO3", "MnO4", "ClO"]

    /// Anion -> cations that break the general rule for that anion.
    private static let halideExceptions: Set<String> = ["Ag", "Pb"]
    private static let sulfateInsoluble: Set<String> = ["Ba", "Pb"]
    private static let sulfateSlightly: Set<String> = ["Ca", "Ag"]
    private static let hydroxideSoluble: Set<String> = ["Ba"]
    private static let hydroxideSlightly: Set<String> = ["Ca"]
    private static let sulfideSoluble: Set<String> = ["Mg", "Ca", "Ba"]

    public static func solubility(cation: Ion, anion: Ion) -> Solubility {
        if alwaysSolubleCations.contains(cation.symbol) { return .soluble }
        if alwaysSolubleAnions.contains(anion.symbol) { return .soluble }
        // Acids are aqueous by definition.
        if cation.symbol == "H" { return .soluble }

        switch anion.symbol {
        case "Cl", "Br", "I":
            return halideExceptions.contains(cation.symbol) ? .insoluble : .soluble
        case "F":
            // Most fluorides dissolve; the group 2 ones and lead do not.
            return ["Mg", "Ca", "Ba", "Pb"].contains(cation.symbol) ? .insoluble : .soluble
        case "SO4":
            if sulfateInsoluble.contains(cation.symbol) { return .insoluble }
            if sulfateSlightly.contains(cation.symbol) { return .slightlySoluble }
            return .soluble
        case "OH":
            if hydroxideSoluble.contains(cation.symbol) { return .soluble }
            if hydroxideSlightly.contains(cation.symbol) { return .slightlySoluble }
            return .insoluble
        case "S":
            return sulfideSoluble.contains(cation.symbol) ? .soluble : .insoluble
        case "CO3", "PO4", "CrO4":
            return .insoluble
        default:
            return .soluble
        }
    }
}
