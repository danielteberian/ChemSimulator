/// A monatomic or polyatomic ion. Salts are built from a cation and an anion,
/// which is how the lab works out formulas, names and solubility.
public struct Ion: Sendable, Hashable, Identifiable {
    /// Formula without the charge: "Na", "SO4", "NH4".
    public let symbol: String
    public let charge: Int
    /// Lowercase name used inside salt names: "sodium", "sulfate", "iron(III)".
    public let name: String

    public init(_ symbol: String, _ charge: Int, _ name: String) {
        self.symbol = symbol
        self.charge = charge
        self.name = name
    }

    /// Unique key such as "Na+1" or "SO4-2".
    public var id: String { "\(symbol)\(charge > 0 ? "+" : "-")\(abs(charge))" }

    /// "Na⁺", "SO₄²⁻".
    public var display: String { Formula.subscripted(symbol) + Ion.superscriptCharge(charge) }

    /// True for ions made of several atoms (sulfate, hydroxide, ammonium), which
    /// need brackets in a formula when more than one is present.
    public var isPolyatomic: Bool { (Formula(parsing: symbol)?.totalAtoms ?? 1) > 1 }

    static func superscriptCharge(_ charge: Int) -> String {
        let superscripts: [Character: Character] = [
            "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴",
            "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹",
            "+": "⁺", "-": "⁻",
        ]
        let magnitude = abs(charge)
        let text = (magnitude == 1 ? "" : String(magnitude)) + (charge > 0 ? "+" : "-")
        return String(text.map { superscripts[$0] ?? $0 })
    }
}

public enum IonCatalog {
    public static let cations: [Ion] = [
        Ion("H", 1, "hydrogen"),
        Ion("Li", 1, "lithium"),
        Ion("Na", 1, "sodium"),
        Ion("K", 1, "potassium"),
        Ion("NH4", 1, "ammonium"),
        Ion("Ag", 1, "silver"),
        Ion("Mg", 2, "magnesium"),
        Ion("Ca", 2, "calcium"),
        Ion("Ba", 2, "barium"),
        Ion("Zn", 2, "zinc"),
        Ion("Fe", 2, "iron(II)"),
        Ion("Ni", 2, "nickel(II)"),
        Ion("Cu", 2, "copper(II)"),
        Ion("Pb", 2, "lead(II)"),
        Ion("Al", 3, "aluminum"),
        Ion("Fe", 3, "iron(III)"),
    ]

    public static let anions: [Ion] = [
        Ion("F", -1, "fluoride"),
        Ion("Cl", -1, "chloride"),
        Ion("Br", -1, "bromide"),
        Ion("I", -1, "iodide"),
        Ion("OH", -1, "hydroxide"),
        Ion("NO3", -1, "nitrate"),
        Ion("CH3COO", -1, "acetate"),
        Ion("HCO3", -1, "hydrogen carbonate"),
        Ion("ClO", -1, "hypochlorite"),
        Ion("MnO4", -1, "permanganate"),
        Ion("S", -2, "sulfide"),
        Ion("SO4", -2, "sulfate"),
        Ion("CO3", -2, "carbonate"),
        Ion("CrO4", -2, "chromate"),
        Ion("PO4", -3, "phosphate"),
    ]

    public static func cation(_ symbol: String, charge: Int) -> Ion? {
        cations.first { $0.symbol == symbol && $0.charge == charge }
    }

    public static func anion(_ symbol: String, charge: Int) -> Ion? {
        anions.first { $0.symbol == symbol && $0.charge == charge }
    }

    /// The cation for a metal element at its most common charge, if it is in the catalog.
    public static func cation(forMetal symbol: String, charge: Int? = nil) -> Ion? {
        let matches = cations.filter { $0.symbol == symbol }
        if let charge { return matches.first { $0.charge == charge } }
        return matches.first
    }

    /// Formula string for a salt: "NaCl", "Ca(OH)2", "Al2(SO4)3", "(NH4)2SO4".
    /// Ion counts are the smallest whole numbers that cancel the charges.
    public static func saltFormula(cation: Ion, anion: Ion) -> String {
        let (cationCount, anionCount) = ratio(cation: cation, anion: anion)
        return part(cation, cationCount) + part(anion, anionCount)
    }

    /// How many cations and anions make a neutral salt.
    public static func ratio(cation: Ion, anion: Ion) -> (cations: Int, anions: Int) {
        let a = abs(cation.charge)
        let b = abs(anion.charge)
        let divisor = gcd(a, b)
        return (b / divisor, a / divisor)
    }

    /// "sodium chloride", "calcium hydroxide".
    public static func saltName(cation: Ion, anion: Ion) -> String {
        "\(cation.name) \(anion.name)".capitalizedFirst
    }

    private static func part(_ ion: Ion, _ count: Int) -> String {
        if count == 1 { return ion.symbol }
        return ion.isPolyatomic ? "(\(ion.symbol))\(count)" : "\(ion.symbol)\(count)"
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int {
        b == 0 ? a : gcd(b, a % b)
    }
}
