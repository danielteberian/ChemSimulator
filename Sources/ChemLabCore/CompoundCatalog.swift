public struct KnownCompound: Sendable, Hashable {
    /// Hill formula, the lookup key.
    public let formula: String
    /// Formula as people write it, with subscripts: "H₂SO₄", "NaCl", "HCOOH".
    public let displayFormula: String
    /// The name people use ("Water", "Table salt").
    public let commonName: String
    /// The systematic name ("dihydrogen monoxide", "sodium chloride").
    public let systematicName: String
    public let aliases: [String]
    public let hazards: [HazardNote]
    /// Set when other compounds share this formula (isomers), so the UI can
    /// say the name is a best guess.
    public let isomerNote: String?

    init(
        _ formula: String, _ commonName: String, systematic: String,
        aliases: [String] = [], hazards: [HazardNote] = [], isomers: String? = nil
    ) {
        guard let parsed = Formula(parsing: formula) else {
            preconditionFailure("Catalog formula does not parse: \(formula)")
        }
        self.formula = parsed.hill
        self.displayFormula = Formula.subscripted(formula)
        self.commonName = commonName
        self.systematicName = systematic
        self.aliases = aliases
        self.hazards = hazards
        self.isomerNote = isomers
    }
}

public enum CompoundCatalog {
    public static let all: [KnownCompound] = inorganic + organic + acidsBasesSalts

    private static let byFormula: [String: KnownCompound] =
        Dictionary(all.map { ($0.formula, $0) }, uniquingKeysWith: { first, _ in first })

    public static func lookup(_ formula: Formula) -> KnownCompound? {
        byFormula[formula.hill]
    }
}

extension CompoundCatalog {
    static let inorganic: [KnownCompound] = [
        KnownCompound("H2O", "Water", systematic: "dihydrogen monoxide"),
        KnownCompound("H2O2", "Hydrogen peroxide", systematic: "dioxidane",
            hazards: [HazardNote(.oxidizer, "Feeds fires and reacts violently with many materials."),
                      HazardNote(.corrosive, "Concentrated solutions burn skin and eyes.")]),
        KnownCompound("H2", "Hydrogen gas", systematic: "dihydrogen",
            hazards: [HazardNote(.flammable, "Ignites very easily."),
                      HazardNote(.explosive, "Mixed with air it forms explosive mixtures.")]),
        KnownCompound("O2", "Oxygen gas", systematic: "dioxygen",
            hazards: [HazardNote(.oxidizer, "Makes fires burn much hotter and faster.")]),
        KnownCompound("O3", "Ozone", systematic: "trioxygen",
            hazards: [HazardNote(.toxic, "Damages the lungs when breathed in."),
                      HazardNote(.oxidizer, "Strong oxidizer.")]),
        KnownCompound("N2", "Nitrogen gas", systematic: "dinitrogen"),
        KnownCompound("Cl2", "Chlorine gas", systematic: "dichlorine",
            hazards: [HazardNote(.toxic, "Poisonous gas that damages the lungs."),
                      HazardNote(.environmental, "Very toxic to aquatic life.")]),
        KnownCompound("CO2", "Carbon dioxide", systematic: "carbon dioxide", aliases: ["Dry ice (solid)"]),
        KnownCompound("CO", "Carbon monoxide", systematic: "carbon monoxide",
            hazards: [HazardNote(.toxic, "Colorless, odorless poison that blocks oxygen transport in blood."),
                      HazardNote(.flammable, "Burns in air.")]),
        KnownCompound("CH4", "Methane", systematic: "methane", aliases: ["Natural gas"],
            hazards: [HazardNote(.flammable, "Ignites easily."),
                      HazardNote(.explosive, "Explosive when mixed with air in the right proportion.")]),
        KnownCompound("NH3", "Ammonia", systematic: "azane",
            hazards: [HazardNote(.corrosive, "Burns eyes, skin and airways."),
                      HazardNote(.toxic, "Harmful to breathe.")]),
        KnownCompound("NO", "Nitric oxide", systematic: "nitrogen monoxide",
            hazards: [HazardNote(.toxic, "Poisonous gas; turns into NO₂ in air.")]),
        KnownCompound("NO2", "Nitrogen dioxide", systematic: "nitrogen dioxide",
            hazards: [HazardNote(.toxic, "Poisonous brown gas that damages the lungs."),
                      HazardNote(.oxidizer, "Supports combustion.")]),
        KnownCompound("N2O", "Nitrous oxide", systematic: "dinitrogen monoxide", aliases: ["Laughing gas"],
            hazards: [HazardNote(.oxidizer, "Supports combustion.")]),
        KnownCompound("SO2", "Sulfur dioxide", systematic: "sulfur dioxide",
            hazards: [HazardNote(.toxic, "Choking gas that irritates and damages the lungs.")]),
        KnownCompound("SO3", "Sulfur trioxide", systematic: "sulfur trioxide",
            hazards: [HazardNote(.corrosive, "Burns on contact."),
                      HazardNote(.waterReactive, "Reacts violently with water to make sulfuric acid.")]),
        KnownCompound("H2S", "Hydrogen sulfide", systematic: "hydrogen sulfide", aliases: ["Rotten egg gas"],
            hazards: [HazardNote(.toxic, "Deadly gas; it deadens your sense of smell so you stop noticing it."),
                      HazardNote(.flammable, "Burns in air.")]),
        KnownCompound("HCl", "Hydrogen chloride", systematic: "hydrogen chloride",
            aliases: ["Hydrochloric acid (in water)"],
            hazards: [HazardNote(.corrosive, "Burns skin and eyes."),
                      HazardNote(.toxic, "The gas damages the airways.")]),
        KnownCompound("HF", "Hydrogen fluoride", systematic: "hydrogen fluoride",
            aliases: ["Hydrofluoric acid (in water)"],
            hazards: [HazardNote(.toxic, "Absorbs through skin and attacks bone and the heart."),
                      HazardNote(.corrosive, "Causes severe, delayed burns.")]),
        KnownCompound("HNO3", "Nitric acid", systematic: "hydrogen nitrate", aliases: ["Aqua fortis"],
            hazards: [HazardNote(.corrosive, "Burns skin and eyes and stains skin yellow."),
                      HazardNote(.oxidizer, "Reacts violently with many organic materials.")]),
        KnownCompound("H2SO4", "Sulfuric acid", systematic: "dihydrogen sulfate", aliases: ["Oil of vitriol"],
            hazards: [HazardNote(.corrosive, "Destroys skin, eyes and many materials."),
                      HazardNote(.exothermic, "Mixing with water gives off a lot of heat and can spit.")]),
        KnownCompound("H3PO4", "Phosphoric acid", systematic: "trihydrogen phosphate",
            hazards: [HazardNote(.corrosive, "Burns skin and eyes.")]),
        KnownCompound("NaOH", "Sodium hydroxide", systematic: "sodium hydroxide",
            aliases: ["Lye", "Caustic soda"],
            hazards: [HazardNote(.corrosive, "Burns skin and eyes, and dissolves fats and proteins."),
                      HazardNote(.exothermic, "Dissolving in water gives off a lot of heat.")]),
        KnownCompound("KOH", "Potassium hydroxide", systematic: "potassium hydroxide",
            aliases: ["Caustic potash"],
            hazards: [HazardNote(.corrosive, "Burns skin and eyes.")]),
        KnownCompound("Ca(OH)2", "Slaked lime", systematic: "calcium hydroxide", aliases: ["Hydrated lime"],
            hazards: [HazardNote(.irritant, "Irritates skin, eyes and lungs.")]),
        KnownCompound("Mg(OH)2", "Milk of magnesia", systematic: "magnesium hydroxide"),
        KnownCompound("CaO", "Quicklime", systematic: "calcium oxide",
            hazards: [HazardNote(.corrosive, "Burns skin and eyes."),
                      HazardNote(.waterReactive, "Reacts with water and releases a lot of heat.")]),
        KnownCompound("MgO", "Magnesia", systematic: "magnesium oxide"),
        KnownCompound("SiO2", "Silica", systematic: "silicon dioxide", aliases: ["Quartz", "Sand"]),
        KnownCompound("Fe2O3", "Rust", systematic: "iron(III) oxide", aliases: ["Hematite"]),
        KnownCompound("NaCl", "Table salt", systematic: "sodium chloride", aliases: ["Halite"]),
        KnownCompound("KCl", "Potassium chloride", systematic: "potassium chloride", aliases: ["Sylvite"]),
        KnownCompound("CaCl2", "Calcium chloride", systematic: "calcium chloride",
            hazards: [HazardNote(.irritant, "Irritates eyes; dissolving in water gives off heat.")]),
        KnownCompound("AgCl", "Silver chloride", systematic: "silver chloride"),
        KnownCompound("NaHCO3", "Baking soda", systematic: "sodium hydrogencarbonate",
            aliases: ["Sodium bicarbonate"]),
        KnownCompound("Na2CO3", "Washing soda", systematic: "sodium carbonate", aliases: ["Soda ash"],
            hazards: [HazardNote(.irritant, "Irritates eyes.")]),
        KnownCompound("CaCO3", "Limestone", systematic: "calcium carbonate", aliases: ["Chalk", "Marble"]),
        KnownCompound("CuSO4", "Copper(II) sulfate", systematic: "copper(II) sulfate",
            aliases: ["Blue vitriol (as the hydrate)"],
            hazards: [HazardNote(.irritant, "Harmful if swallowed and irritates eyes."),
                      HazardNote(.environmental, "Very toxic to aquatic life.")]),
        KnownCompound("Cu(NO3)2", "Copper(II) nitrate", systematic: "copper(II) nitrate",
            hazards: [HazardNote(.oxidizer, "Can make combustible materials burn more fiercely."),
                      HazardNote(.irritant, "Burns skin and eyes.")]),
        KnownCompound("AgNO3", "Silver nitrate", systematic: "silver nitrate", aliases: ["Lunar caustic"],
            hazards: [HazardNote(.corrosive, "Burns skin and stains it black."),
                      HazardNote(.oxidizer, "Can intensify fires."),
                      HazardNote(.environmental, "Very toxic to aquatic life.")]),
        KnownCompound("NH4NO3", "Ammonium nitrate", systematic: "ammonium nitrate",
            hazards: [HazardNote(.oxidizer, "Strong oxidizer."),
                      HazardNote(.explosive, "Can detonate when heated under confinement or contaminated.")]),
        KnownCompound("KMnO4", "Potassium permanganate", systematic: "potassium manganate(VII)",
            hazards: [HazardNote(.oxidizer, "Can ignite combustible materials on contact."),
                      HazardNote(.corrosive, "Burns skin and eyes.")]),
        KnownCompound("PbI2", "Lead(II) iodide", systematic: "lead(II) iodide",
            hazards: [HazardNote(.toxic, "Lead compounds are poisonous."),
                      HazardNote(.healthHazard, "Can harm fertility and development."),
                      HazardNote(.environmental, "Toxic to aquatic life.")]),
    ]
}
