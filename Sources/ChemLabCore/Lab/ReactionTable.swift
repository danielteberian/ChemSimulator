/// Reactions that need their own rule: the ones with special products, special
/// conditions or a special hazard. Common patterns (acid + base, precipitation,
/// acid + metal, metal + water, displacement) come from `ReactionGenerator`.
///
/// Enthalpies are rough teaching values in kJ for the equation as written, not
/// lab-grade data. Hazard and "why" text is written for learners and has not
/// been reviewed by a chemist.
public enum ReactionTable {
    public static let explicit: [Reaction] =
        nitricAcid + hotAcid + amphoteric + decompositions + combustion + hazardousMixes

    private static func id(_ formula: String) -> String {
        Formula(parsing: formula)?.hill ?? formula
    }

    private static func make(
        _ equation: String, _ kind: Reaction.Kind, conditions: ReactionConditions = ReactionConditions(),
        enthalpy: Double = 0, hazards: [HazardNote] = [], why: String
    ) -> Reaction {
        guard
            let reaction = Reaction.parse(
                equation, kind, conditions: conditions, enthalpy: enthalpy, hazards: hazards, why: why)
        else { preconditionFailure("Bad reaction: \(equation)") }
        return reaction
    }

    // MARK: Nitric acid

    private static let concentratedNitric = ReactionConditions(requiresConcentrated: id("HNO3"))
    private static let dilutedNitric = ReactionConditions(requiresDilute: id("HNO3"))

    private static let nitrogenDioxide = HazardNote(
        .toxic, "Nitrogen dioxide is a poisonous brown gas that damages the lungs.")
    private static let nitricOxide = HazardNote(
        .toxic, "Nitric oxide is poisonous, and it turns into brown NO₂ as soon as it meets air.")

    private static let concentratedWhy =
        "Nitric acid is an oxidizer, not just an acid. Instead of releasing hydrogen it takes "
        + "electrons from the metal, and the nitrate itself is reduced to brown nitrogen dioxide."
    private static let dilutedWhy =
        "In dilute nitric acid the nitrate is only partly reduced, so the gas is colorless nitric "
        + "oxide rather than brown NO₂. Real reactions give a mix of nitrogen oxides."

    static let nitricAcid: [Reaction] = [
        make(
            "Cu + 4 HNO3 -> Cu(NO3)2 + 2 NO2 + 2 H2O", .redox, conditions: concentratedNitric,
            enthalpy: -160, hazards: [nitrogenDioxide], why: concentratedWhy),
        make(
            "3 Cu + 8 HNO3 -> 3 Cu(NO3)2 + 2 NO + 4 H2O", .redox, conditions: dilutedNitric,
            enthalpy: -150, hazards: [nitricOxide], why: dilutedWhy),
        make(
            "Ag + 2 HNO3 -> AgNO3 + NO2 + H2O", .redox, conditions: concentratedNitric,
            enthalpy: -60, hazards: [nitrogenDioxide], why: concentratedWhy),
        make(
            "3 Ag + 4 HNO3 -> 3 AgNO3 + NO + 2 H2O", .redox, conditions: dilutedNitric,
            enthalpy: -50, hazards: [nitricOxide], why: dilutedWhy),
        make(
            "Zn + 4 HNO3 -> Zn(NO3)2 + 2 NO2 + 2 H2O", .redox, conditions: concentratedNitric,
            enthalpy: -300, hazards: [nitrogenDioxide], why: concentratedWhy),
        make(
            "3 Zn + 8 HNO3 -> 3 Zn(NO3)2 + 2 NO + 4 H2O", .redox, conditions: dilutedNitric,
            enthalpy: -250, hazards: [nitricOxide], why: dilutedWhy),
    ]

    // MARK: Hot concentrated sulfuric acid

    static let hotAcid: [Reaction] = [
        make(
            "Cu + 2 H2SO4 -> CuSO4 + SO2 + 2 H2O", .redox,
            conditions: ReactionConditions(minTemperature: 100, requiresConcentrated: id("H2SO4")),
            enthalpy: -50,
            hazards: [HazardNote(.toxic, "Sulfur dioxide is a choking gas that damages the lungs.")],
            why: "Copper sits below hydrogen, so no acid can push hydrogen out of it. Hot concentrated "
                + "sulfuric acid is an oxidizer though: it takes electrons from the copper and is itself "
                + "reduced to sulfur dioxide."),
    ]

    // MARK: Amphoteric metals

    static let amphoteric: [Reaction] = [
        make(
            "2 Al + 2 NaOH + 6 H2O -> 2 NaAl(OH)4 + 3 H2", .redox, enthalpy: -280,
            hazards: [
                HazardNote(.explosive, "The hydrogen it makes is flammable and forms explosive mixtures with air."),
                HazardNote(.corrosive, "Lye is caustic, and the hot solution splashes."),
            ],
            why: "Aluminum is amphoteric: it dissolves in strong bases as well as acids. Lye strips away "
                + "the protective oxide film, and the metal then reduces water to hydrogen gas while it "
                + "dissolves as sodium aluminate. The reaction gives off a lot of heat."),
    ]

    // MARK: Heating: decomposition

    private static func hot(_ degrees: Double) -> ReactionConditions {
        ReactionConditions(minTemperature: degrees, worksDry: true)
    }

    private static let decompositionWhy =
        "Heat gives the atoms enough energy to break the bonds holding the compound together, "
        + "so it splits into simpler substances."

    static let decompositions: [Reaction] = [
        make(
            "CaCO3 -> CaO + CO2", .decomposition, conditions: hot(825), enthalpy: 178,
            why: "Limestone is stable until it is heated to about 825 °C. Then it loses carbon dioxide "
                + "and leaves quicklime. This is how lime for cement is made."),
        make(
            "MgCO3 -> MgO + CO2", .decomposition, conditions: hot(350), enthalpy: 117,
            why: decompositionWhy),
        make(
            "CuCO3 -> CuO + CO2", .decomposition, conditions: hot(200), enthalpy: 50,
            why: "Green copper carbonate turns black as it loses carbon dioxide and becomes copper oxide."),
        make(
            "Cu(OH)2 -> CuO + H2O", .decomposition, conditions: hot(80), enthalpy: 10,
            why: "Blue copper hydroxide loses water when warmed and turns into black copper oxide."),
        make(
            "Ca(OH)2 -> CaO + H2O", .decomposition, conditions: hot(580), enthalpy: 65,
            why: decompositionWhy),
        make(
            "2 NaHCO3 -> Na2CO3 + H2O + CO2", .decomposition, conditions: hot(100), enthalpy: 129,
            why: "Baking soda breaks down when hot, releasing carbon dioxide. That gas is what makes "
                + "cakes rise."),
        make(
            "2 H2O2 -> 2 H2O + O2", .decomposition, conditions: hot(60), enthalpy: -196,
            hazards: [HazardNote(.oxidizer, "The oxygen it releases makes fires burn much hotter.")],
            why: "Hydrogen peroxide is unstable: it slowly turns into water and oxygen, and heat or a "
                + "catalyst speeds that up a lot."),
        make(
            "2 Cu(NO3)2 -> 2 CuO + 4 NO2 + O2", .decomposition, conditions: hot(170), enthalpy: 420,
            hazards: [nitrogenDioxide],
            why: "Heating a metal nitrate breaks the nitrate apart, and here it gives brown, poisonous "
                + "nitrogen dioxide plus oxygen. Blue crystals turn into black copper oxide."),
        make(
            "2 AgNO3 -> 2 Ag + 2 NO2 + O2", .decomposition, conditions: hot(440), enthalpy: 316,
            hazards: [nitrogenDioxide],
            why: "Silver is so unreactive that heat is enough to strip the nitrate away and leave the "
                + "pure metal, along with brown nitrogen dioxide."),
        make(
            "NH4NO3 -> N2O + 2 H2O", .decomposition, conditions: hot(210), enthalpy: -36,
            hazards: [
                HazardNote(.explosive, "Hot ammonium nitrate can detonate, especially when confined."),
                HazardNote(.oxidizer, "It is a strong oxidizer, and the gases it makes support fire."),
            ],
            why: "Ammonium nitrate holds both a fuel part (ammonium) and an oxidizer part (nitrate) in one "
                + "crystal. Heated, they react with each other and release gas and heat fast, which is "
                + "why it is used in fertilizer and in explosives."),
        make(
            "C12H22O11 -> 12 C + 11 H2O", .decomposition, conditions: hot(186), enthalpy: 200,
            why: "Sugar melts, then heat pulls the water out of the molecule. What is left is carbon: "
                + "black char with the smell of burnt caramel."),
    ]

    // MARK: Heating: burning and combining

    private static let flameWhy =
        "Burning is a reaction with oxygen. It needs enough heat to get started (the ignition "
        + "temperature) and then gives off more heat than it took, so it keeps itself going."

    static let combustion: [Reaction] = [
        make(
            "2 Mg + O2 -> 2 MgO", .combustion, conditions: hot(473), enthalpy: -1204,
            hazards: [HazardNote(.flammable, "Burns with a blinding white light that can damage eyes.")],
            why: flameWhy + " Magnesium is so eager that it burns even in carbon dioxide, so water "
                + "and CO₂ extinguishers don't put it out."),
        make(
            "2 H2 + O2 -> 2 H2O", .combustion, conditions: hot(500), enthalpy: -572,
            hazards: [
                HazardNote(.explosive, "Hydrogen and oxygen react explosively in the right mix."),
                HazardNote(.flammable, "The flame is almost invisible."),
            ],
            why: flameWhy + " Hydrogen mixed with air is explosive over a very wide range of mixes, "
                + "and the only product is water."),
        make(
            "CH4 + 2 O2 -> CO2 + 2 H2O", .combustion, conditions: hot(540), enthalpy: -890,
            hazards: [HazardNote(.explosive, "Methane mixed with air explodes when lit.")],
            why: flameWhy + " Methane is natural gas, and this is the reaction in a gas stove."),
        make(
            "S + O2 -> SO2", .combustion, conditions: hot(250), enthalpy: -297,
            hazards: [HazardNote(.toxic, "Sulfur dioxide is a choking gas that damages the lungs.")],
            why: flameWhy + " Sulfur burns with a pale blue flame and makes sulfur dioxide, which "
                + "goes on to cause acid rain."),
        make(
            "C + O2 -> CO2", .combustion, conditions: hot(400), enthalpy: -394,
            hazards: [HazardNote(.toxic, "With too little air, carbon burns to poisonous carbon monoxide instead.")],
            why: flameWhy),
        make(
            "Fe + S -> FeS", .other, conditions: hot(120), enthalpy: -100,
            why: "Once the sulfur melts, iron and sulfur combine and give off heat. The product, iron "
                + "sulfide, is black and is nothing like either ingredient."),
        make(
            "2 Al + Fe2O3 -> Al2O3 + 2 Fe", .redox, conditions: hot(900), enthalpy: -852,
            hazards: [
                HazardNote(.explosive, "Thermite burns fiercely and throws out molten iron."),
                HazardNote(.exothermic, "It reaches about 2,500 °C, hot enough to melt steel."),
            ],
            why: "Aluminum holds on to oxygen more strongly than iron does, so it pulls the oxygen out "
                + "of rust. The energy released is enough to melt the iron it frees."),
        make(
            "2 Na + Cl2 -> 2 NaCl", .other, conditions: ReactionConditions(worksDry: true),
            enthalpy: -822,
            hazards: [
                HazardNote(.toxic, "Chlorine is a poisonous gas."),
                HazardNote(.flammable, "The metal can burn with a bright yellow flame."),
            ],
            why: "A metal that gives electrons away easily meets a gas that takes them easily. Two "
                + "hazardous elements combine into harmless table salt, giving off a great deal of heat."),
    ]

    // MARK: Dangerous mixes from everyday products

    static let hazardousMixes: [Reaction] = [
        make(
            "NaClO + 2 HCl -> NaCl + Cl2 + H2O", .gasEvolution, enthalpy: -60,
            hazards: [HazardNote(.toxic, "Chlorine gas is poisonous and damages the lungs; it was used as a weapon.")],
            why: "Bleach is a chlorine-releasing oxidizer. Acid pushes the reaction the wrong way and "
                + "frees chlorine gas. This is why bleach must never be mixed with acidic cleaners."),
    ]
}
