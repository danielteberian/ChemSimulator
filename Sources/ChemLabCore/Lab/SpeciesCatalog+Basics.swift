/// Water, gases, metals, other elements and metal oxides. Names and standing
/// hazards come from `CompoundCatalog` where it has an entry; the notes here
/// cover what the catalog doesn't (mostly the bare metals). Notes are written for
/// learners and have not been reviewed by a chemist.
extension SpeciesCatalog {
    static let library: [Species] = basics + acidsAndBases + salts

    /// An ion from the catalog, for writing data tables. Fails loudly on a typo.
    static func ion(_ symbol: String, _ charge: Int) -> Ion {
        guard
            let found = (IonCatalog.cations + IonCatalog.anions).first(where: {
                $0.symbol == symbol && $0.charge == charge
            })
        else { preconditionFailure("No such ion: \(symbol) \(charge)") }
        return found
    }

    private static func metal(
        _ symbol: String, melts: Double, boils: Double? = nil,
        color: RGB = RGB(0.78, 0.79, 0.82), hazards: [HazardNote] = []
    ) -> Species {
        guard let profile = ActivitySeries.profile(of: symbol) else {
            preconditionFailure("\(symbol) is not in the activity series")
        }
        return Species(
            symbol, role: .metal(charge: profile.charge), melts: melts, boils: boils,
            hazards: hazards, color: color)
    }

    private static func gas(
        _ formula: String, boils: Double, color: RGB = RGB(0.92, 0.94, 0.97), name: String? = nil
    ) -> Species {
        Species(formula, name: name, role: .gas, state: .gas, boils: boils, color: color)
    }

    private static func oxide(
        _ formula: String, cation: Ion, melts: Double, color: RGB = .white
    ) -> Species {
        Species(formula, role: .basicOxide(cation: cation), melts: melts, color: color)
    }

    static let basics: [Species] = [
        Species("H2O", role: .water, state: .liquid, melts: 0, boils: 100, color: .water),

        // Gases
        gas("H2", boils: -253),
        gas("O2", boils: -183),
        gas("N2", boils: -196),
        gas("CO2", boils: -78),
        gas("Cl2", boils: -34, color: RGB(0.75, 0.85, 0.35), name: "Chlorine gas"),
        gas("NO2", boils: 21, color: RGB(0.65, 0.33, 0.10)),
        gas("NO", boils: -152),
        gas("N2O", boils: -88),
        gas("SO2", boils: -10),
        gas("H2S", boils: -60),
        gas("CH4", boils: -162),
        Species("NH3", role: .ammonia, state: .gas, melts: -78, boils: -33),

        // Metals
        metal(
            "Li", melts: 181, boils: 1342,
            hazards: [HazardNote(.waterReactive, "Reacts with water and gives off flammable hydrogen.")]),
        metal(
            "Na", melts: 98, boils: 883,
            hazards: [
                HazardNote(.waterReactive, "Reacts violently with water; the hydrogen it releases can ignite."),
                HazardNote(.corrosive, "The hydroxide it forms on skin or in water burns."),
            ]),
        metal(
            "K", melts: 63, boils: 759,
            hazards: [
                HazardNote(.waterReactive, "Reacts even more violently than sodium; the hydrogen ignites at once."),
                HazardNote(.corrosive, "The hydroxide it forms on skin or in water burns."),
            ]),
        metal(
            "Mg", melts: 650, boils: 1090,
            hazards: [HazardNote(.flammable, "Burns with a blinding white flame that can damage eyes.")]),
        metal(
            "Ca", melts: 842, boils: 1484,
            hazards: [HazardNote(.waterReactive, "Reacts with water and gives off flammable hydrogen.")]),
        metal(
            "Ba", melts: 727, boils: 1897,
            hazards: [
                HazardNote(.waterReactive, "Reacts with water and gives off flammable hydrogen."),
                HazardNote(.toxic, "Barium and its soluble compounds are poisonous."),
            ]),
        metal("Al", melts: 660, boils: 2470),
        metal("Zn", melts: 420, boils: 907, color: RGB(0.62, 0.66, 0.72)),
        metal("Fe", melts: 1538, boils: 2862, color: RGB(0.45, 0.46, 0.50)),
        metal(
            "Ni", melts: 1455, boils: 2913,
            hazards: [HazardNote(.healthHazard, "Causes allergic skin reactions and may cause cancer.")]),
        metal(
            "Pb", melts: 327, boils: 1749, color: RGB(0.42, 0.44, 0.50),
            hazards: [
                HazardNote(.toxic, "Lead is poisonous and builds up in the body."),
                HazardNote(.healthHazard, "Can harm fertility and children's development."),
            ]),
        metal("Cu", melts: 1085, boils: 2562, color: RGB(0.80, 0.47, 0.25)),
        metal("Ag", melts: 962, boils: 2162, color: RGB(0.85, 0.86, 0.88)),

        // Other elements and organics
        Species(
            "S", name: "Sulfur", role: .other, melts: 115, boils: 445,
            hazards: [HazardNote(.flammable, "Burns with a blue flame and makes choking sulfur dioxide.")],
            color: RGB(0.95, 0.85, 0.15), solubility: .insoluble),
        Species(
            "C", name: "Carbon", role: .other, melts: 3550,
            hazards: [HazardNote(.flammable, "Burns in air, and in low oxygen makes carbon monoxide.")],
            color: RGB(0.14, 0.14, 0.15), solubility: .insoluble),
        Species(
            "C12H22O11", name: "Sugar (sucrose)", role: .other, melts: 186,
            color: RGB(0.97, 0.96, 0.92), solubility: .soluble),
        Species(
            "H2O2", role: .other, state: .liquid, melts: 0, boils: 150,
            color: .water, solubility: .soluble),
        Species(
            "NaAl(OH)4", name: "Sodium aluminate", role: .other,
            hazards: [HazardNote(.corrosive, "Strongly alkaline; burns skin and eyes.")],
            solubility: .soluble),
        Species(
            "Al2O3", name: "Aluminum oxide", role: .other, melts: 2072, solubility: .insoluble),

        // Metal oxides (they make bases with water and neutralize acids)
        oxide("CaO", cation: ion("Ca", 2), melts: 2613),
        oxide("MgO", cation: ion("Mg", 2), melts: 2852),
        oxide("CuO", cation: ion("Cu", 2), melts: 1326, color: RGB(0.10, 0.10, 0.12)),
        oxide("ZnO", cation: ion("Zn", 2), melts: 1975),
        oxide("Fe2O3", cation: ion("Fe", 3), melts: 1565, color: RGB(0.55, 0.22, 0.12)),
    ]
}
