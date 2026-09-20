/// Acids, bases and salts. Salts are built from ions, so the formula, name and
/// solubility come from one place. Colors are for the pure solid and, where it
/// differs, for the dissolved ion.
extension SpeciesCatalog {
    private static let blueSolution = RGB(0.35, 0.65, 0.95)
    private static let paleGreenSolution = RGB(0.72, 0.90, 0.72)

    // MARK: Acids and bases

    private static func acid(
        _ formula: String, name: String? = nil, anion: (String, Int), protons: Int, strong: Bool,
        state: MatterState = .liquid, melts: Double? = nil, boils: Double? = nil
    ) -> Species {
        Species(
            formula, name: name,
            role: .acid(anion: ion(anion.0, anion.1), protons: protons, strong: strong),
            state: state, melts: melts, boils: boils)
    }

    private static func base(
        _ formula: String, cation: (String, Int), strong: Bool, melts: Double? = nil,
        color: RGB = .white
    ) -> Species {
        let metalIon = ion(cation.0, cation.1)
        let catalogName = Formula(parsing: formula).flatMap { Naming.identify($0)?.displayName }
        return Species(
            formula,
            name: catalogName ?? IonCatalog.saltName(cation: metalIon, anion: ion("OH", -1)),
            role: .base(cation: metalIon, strong: strong), melts: melts,
            hazards: extraHazards(cation: metalIon), color: color)
    }

    static let acidsAndBases: [Species] = [
        // The hydrogen halides are sold and used as solutions, so they are liquids
        // here, with the boiling points of the constant-boiling solutions.
        acid("HCl", name: "Hydrochloric acid", anion: ("Cl", -1), protons: 1, strong: true, melts: -27, boils: 110),
        acid("HBr", name: "Hydrobromic acid", anion: ("Br", -1), protons: 1, strong: true, melts: -11, boils: 126),
        acid("HI", name: "Hydroiodic acid", anion: ("I", -1), protons: 1, strong: true, melts: -36, boils: 127),
        acid("HNO3", anion: ("NO3", -1), protons: 1, strong: true, melts: -42, boils: 83),
        acid("H2SO4", anion: ("SO4", -2), protons: 2, strong: true, melts: 10, boils: 337),
        acid("H3PO4", anion: ("PO4", -3), protons: 3, strong: false, state: .solid, melts: 42, boils: 158),
        acid("CH3COOH", anion: ("CH3COO", -1), protons: 1, strong: false, melts: 17, boils: 118),

        base("NaOH", cation: ("Na", 1), strong: true, melts: 318),
        base("KOH", cation: ("K", 1), strong: true, melts: 406),
        base("LiOH", cation: ("Li", 1), strong: true, melts: 462),
        base("Ba(OH)2", cation: ("Ba", 2), strong: true, melts: 408),
        base("Ca(OH)2", cation: ("Ca", 2), strong: false),
        base("Mg(OH)2", cation: ("Mg", 2), strong: false),
        base("Al(OH)3", cation: ("Al", 3), strong: false),
        base("Zn(OH)2", cation: ("Zn", 2), strong: false),
        base("Cu(OH)2", cation: ("Cu", 2), strong: false, color: RGB(0.35, 0.55, 0.95)),
        base("Fe(OH)2", cation: ("Fe", 2), strong: false, color: RGB(0.55, 0.70, 0.55)),
        base("Fe(OH)3", cation: ("Fe", 3), strong: false, color: RGB(0.65, 0.30, 0.10)),
        base("Ni(OH)2", cation: ("Ni", 2), strong: false, color: RGB(0.45, 0.75, 0.45)),
    ]

    // MARK: Salts

    private static func entry(
        _ cation: String, _ cationCharge: Int, _ anion: String, _ anionCharge: Int,
        melts: Double? = nil, color: RGB = .white, solution: RGB? = nil,
        hazards: [HazardNote] = []
    ) -> Species {
        buildSalt(
            cation: ion(cation, cationCharge), anion: ion(anion, anionCharge), color: color,
            solutionColor: solution, melts: melts, hazards: hazards)
    }

    static let salts: [Species] = chlorides + otherHalides + sulfates + nitrates + carbonates + others

    private static let chlorides: [Species] = [
        entry("Na", 1, "Cl", -1, melts: 801),
        entry("K", 1, "Cl", -1, melts: 770),
        entry("NH4", 1, "Cl", -1),
        entry("Ca", 2, "Cl", -1, melts: 772),
        entry("Mg", 2, "Cl", -1, melts: 714),
        entry("Ba", 2, "Cl", -1, melts: 963),
        entry("Zn", 2, "Cl", -1, melts: 290),
        entry("Al", 3, "Cl", -1, melts: 192),
        entry("Fe", 2, "Cl", -1, melts: 677, color: RGB(0.80, 0.85, 0.70), solution: paleGreenSolution),
        entry(
            "Fe", 3, "Cl", -1, melts: 306, color: RGB(0.55, 0.38, 0.15),
            solution: RGB(0.92, 0.68, 0.28)),
        entry(
            "Cu", 2, "Cl", -1, melts: 498, color: RGB(0.50, 0.58, 0.22),
            solution: RGB(0.30, 0.72, 0.65)),
        entry("Ag", 1, "Cl", -1, melts: 455),
        entry("Pb", 2, "Cl", -1, melts: 501),
    ]

    private static let otherHalides: [Species] = [
        entry("Na", 1, "Br", -1, melts: 747),
        entry("K", 1, "Br", -1, melts: 734),
        entry("Ag", 1, "Br", -1, melts: 432, color: RGB(0.95, 0.92, 0.70)),
        entry("K", 1, "I", -1, melts: 681),
        entry("Ag", 1, "I", -1, melts: 558, color: RGB(0.92, 0.85, 0.40)),
        entry("Pb", 2, "I", -1, melts: 402, color: RGB(0.98, 0.85, 0.10)),
    ]

    private static let sulfates: [Species] = [
        entry("Na", 1, "SO4", -2, melts: 884),
        entry("NH4", 1, "SO4", -2),
        entry("Mg", 2, "SO4", -2),
        entry("Ca", 2, "SO4", -2),
        entry("Ba", 2, "SO4", -2, melts: 1580),
        entry("Zn", 2, "SO4", -2),
        entry("Al", 3, "SO4", -2),
        entry("Fe", 2, "SO4", -2, color: RGB(0.75, 0.85, 0.70), solution: paleGreenSolution),
        entry("Cu", 2, "SO4", -2, color: RGB(0.30, 0.55, 0.95), solution: blueSolution),
        entry("Pb", 2, "SO4", -2, melts: 1087),
    ]

    private static let nitrates: [Species] = [
        entry("Na", 1, "NO3", -1, melts: 308),
        entry("K", 1, "NO3", -1, melts: 334),
        entry("NH4", 1, "NO3", -1, melts: 170),
        entry("Ag", 1, "NO3", -1, melts: 212),
        entry("Ca", 2, "NO3", -1, melts: 561),
        entry("Mg", 2, "NO3", -1, melts: 129),
        entry("Zn", 2, "NO3", -1, melts: 110),
        entry("Cu", 2, "NO3", -1, melts: 114, color: RGB(0.30, 0.55, 0.85), solution: blueSolution),
        entry("Pb", 2, "NO3", -1, melts: 470),
        entry("Al", 3, "NO3", -1, melts: 73),
        entry("Fe", 3, "NO3", -1, melts: 47, color: RGB(0.75, 0.65, 0.85), solution: RGB(0.90, 0.80, 0.55)),
    ]

    private static let carbonates: [Species] = [
        entry("Na", 1, "CO3", -2, melts: 851),
        entry("K", 1, "CO3", -2, melts: 891),
        entry("Na", 1, "HCO3", -1),
        entry("Ca", 2, "CO3", -2),
        entry("Mg", 2, "CO3", -2),
        entry("Ba", 2, "CO3", -2),
        entry("Zn", 2, "CO3", -2),
        entry("Cu", 2, "CO3", -2, color: RGB(0.35, 0.65, 0.50)),
    ]

    private static let others: [Species] = [
        entry("Na", 1, "CH3COO", -1, melts: 324),
        entry("Na", 1, "ClO", -1),
        entry(
            "K", 1, "MnO4", -1, melts: 240, color: RGB(0.35, 0.05, 0.35),
            solution: RGB(0.75, 0.10, 0.65)),
        entry(
            "Na", 1, "S", -2,
            hazards: [
                HazardNote(.toxic, "Releases deadly hydrogen sulfide gas when mixed with acids."),
                HazardNote(.corrosive, "Its solutions are strongly alkaline and burn skin."),
            ]),
        entry("Fe", 2, "S", -2, color: RGB(0.15, 0.12, 0.10)),
        entry("Cu", 2, "S", -2, color: RGB(0.10, 0.10, 0.15)),
        entry("Zn", 2, "S", -2),
        entry("Pb", 2, "S", -2, color: RGB(0.20, 0.20, 0.22)),
        entry("Na", 1, "PO4", -3),
        entry("Ca", 2, "PO4", -3),
    ]
}
