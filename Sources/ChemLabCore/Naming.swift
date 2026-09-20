/// What the app shows for a molecule: the name people use, the systematic name,
/// and any hazards.
public struct Identification: Sendable, Equatable {
    public let formula: Formula
    /// Formula the way people write it ("H₂SO₄", "NaCl"); Hill order when generated.
    public let displayFormula: String
    /// "Water", or the systematic name when there is no common one.
    public let displayName: String
    public let systematicName: String
    public let aliases: [String]
    public let hazards: [HazardNote]
    public let isomerNote: String?
    /// True when matched in the catalog, false when generated from naming rules.
    public let isCatalogued: Bool
}

public enum Naming {
    /// Identifies a molecule. Returns nil unless it is complete (connected, all
    /// valences satisfied), neutral, and something can be said about its name.
    /// Charged species (ions) are not named yet; a formula alone would give
    /// wrong names like "tetrahydrogen nitride" for ammonium.
    public static func identify(_ molecule: Molecule) -> Identification? {
        guard molecule.isComplete, molecule.netCharge == 0 else { return nil }
        return identify(Formula(molecule))
    }

    public static func identify(_ formula: Formula) -> Identification? {
        if let known = CompoundCatalog.lookup(formula) {
            return Identification(
                formula: formula,
                displayFormula: known.displayFormula,
                displayName: known.commonName,
                systematicName: known.systematicName,
                aliases: known.aliases,
                hazards: known.hazards,
                isomerNote: known.isomerNote,
                isCatalogued: true)
        }
        guard let generated = systematicName(for: formula) else { return nil }
        return Identification(
            formula: formula,
            displayFormula: formula.display,
            displayName: generated.capitalizedFirst,
            systematicName: generated,
            aliases: [],
            hazards: [],
            isomerNote: nil,
            isCatalogued: false)
    }

    /// Systematic name for a single element or a binary compound, or nil.
    public static func systematicName(for formula: Formula) -> String? {
        let parts = formula.counts.compactMap { symbol, count in
            PeriodicTable.element(symbol: symbol).map { ($0, count) }
        }
        switch parts.count {
        case 1:
            let (element, count) = parts[0]
            if count == 1 { return element.name.lowercased() }
            return element.isMetal ? nil : prefix(count) + element.name.lowercased()
        case 2:
            return binaryName(parts[0], parts[1])
        default:
            return nil
        }
    }

    private static func binaryName(
        _ x: (Element, Int), _ y: (Element, Int)
    ) -> String? {
        // Less electronegative element goes first.
        let ordered = [x, y].sorted {
            ($0.0.electronegativity ?? 0) < ($1.0.electronegativity ?? 0)
        }
        let (first, second) = (ordered[0], ordered[1])
        guard let anionStem = anionStems[second.0.symbol] else { return nil }

        if first.0.isMetal && !second.0.isMetal {
            return ionicName(cation: first, anion: second, stem: anionStem)
        }
        if first.0.isMetal || second.0.isMetal { return nil }

        let firstName = (first.1 > 1 ? prefix(first.1) : "") + first.0.name.lowercased()
        return firstName + " " + prefixedAnion(count: second.1, stem: anionStem)
    }

    private static func ionicName(
        cation: (Element, Int), anion: (Element, Int), stem: String
    ) -> String? {
        guard let anionCharge = anion.0.ionCharges.first(where: { $0 < 0 }) else { return nil }
        let totalNegative = anion.1 * -anionCharge
        guard totalNegative % cation.1 == 0 else { return nil }
        let charge = totalNegative / cation.1
        let charges = cation.0.ionCharges.filter { $0 > 0 }
        guard charges.contains(charge) else { return nil }

        var name = cation.0.name.lowercased()
        if charges.count > 1 { name += "(\(roman(charge)))" }
        return name + " " + stem
    }

    private static func prefixedAnion(count: Int, stem: String) -> String {
        let p = count == 1 ? "mono" : prefix(count)
        // "monooxide" -> "monoxide", "tetraoxide" -> "tetroxide".
        if stem == "oxide", ["mono", "tetra", "penta"].contains(p) {
            return String(p.dropLast()) + stem
        }
        return p + stem
    }

    private static func prefix(_ n: Int) -> String {
        let prefixes = ["", "mono", "di", "tri", "tetra", "penta", "hexa", "hepta", "octa", "nona", "deca"]
        return prefixes.indices.contains(n) ? prefixes[n] : "\(n)-"
    }

    private static func roman(_ n: Int) -> String {
        let numerals = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII"]
        return numerals.indices.contains(n) ? numerals[n] : String(n)
    }

    private static let anionStems: [String: String] = [
        "H": "hydride", "B": "boride", "C": "carbide", "N": "nitride", "O": "oxide",
        "F": "fluoride", "Si": "silicide", "P": "phosphide", "S": "sulfide",
        "Cl": "chloride", "As": "arsenide", "Se": "selenide", "Br": "bromide",
        "Te": "telluride", "I": "iodide", "At": "astatide",
    ]
}

extension String {
    var capitalizedFirst: String {
        prefix(1).uppercased() + dropFirst()
    }
}
