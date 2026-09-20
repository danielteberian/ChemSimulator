/// Works out the common reaction patterns from the species present, instead of
/// listing every combination by hand. Products are looked up (or built) from the
/// ions involved, and coefficients come from `EquationBalancer`.
///
/// Patterns: acid + base, acid + metal, metal + water, metal displacement,
/// double displacement (precipitation), acid + carbonate or sulfide, and
/// ammonium salt + base. Reactions with special products or conditions live in
/// `ReactionTable`.
public enum ReactionGenerator {
    public static func reactions(among present: [Species]) -> [Reaction] {
        var found: [Reaction] = []
        func add(_ reaction: Reaction?) {
            if let reaction { found.append(reaction) }
        }

        let metals = present.filter(\.isMetal)

        for acid in present where acid.isAcid {
            guard case .acid(let anion, _, _) = acid.role else { continue }
            for other in present {
                switch other.role {
                case .base(let cation, _), .basicOxide(let cation):
                    add(neutralization(acid: acid, anion: anion, base: other, cation: cation))
                case .ammonia:
                    add(ammoniaNeutralization(acid: acid, anion: anion, ammonia: other))
                case .salt:
                    add(gasEvolution(acid: acid, anion: anion, salt: other))
                default:
                    break
                }
            }
            for metal in metals { add(acidMetal(acid: acid, anion: anion, metal: metal)) }
        }

        for metal in metals {
            add(waterReaction(metal: metal))
            for salt in present { add(displacement(metal: metal, salt: salt)) }
        }

        for salt in present {
            for base in present { add(ammoniumRelease(salt: salt, base: base)) }
        }

        let dissolvable = present.filter { $0.ionPair != nil && $0.solubility == .soluble }
        for i in dissolvable.indices {
            for j in dissolvable.indices where j > i {
                add(precipitation(dissolvable[i], dissolvable[j]))
            }
        }
        return found
    }

    // MARK: Helpers

    private static func hill(_ formula: String) -> String {
        Formula(parsing: formula)?.hill ?? formula
    }

    private static func species(_ formula: String) -> Species? {
        SpeciesCatalog.species(formula: formula)
    }

    /// Balances and assembles a reaction. `kilojoules` is the heat change per unit
    /// coefficient of `heatOf`, so the total scales with the balanced equation.
    private static func build(
        _ kind: Reaction.Kind, reactants: [Species], products: [Species],
        conditions: ReactionConditions = ReactionConditions(),
        heatOf: Species? = nil, kilojoules: Double = 0, hazards: [HazardNote] = [], why: String
    ) -> Reaction? {
        // A species on both sides means nothing really changed.
        guard Set(reactants.map(\.id)).isDisjoint(with: products.map(\.id)) else { return nil }
        guard
            let coefficients = EquationBalancer.balance(
                reactants: reactants.map(\.formula), products: products.map(\.formula))
        else { return nil }

        let parts = zip(reactants + products, coefficients).map { Participant($0, $1) }
        var enthalpy = 0.0
        if let heatOf, let match = parts.first(where: { $0.species.id == heatOf.id }) {
            enthalpy = kilojoules * Double(match.coefficient)
        }
        return Reaction(
            kind, reactants: Array(parts.prefix(reactants.count)),
            products: Array(parts.dropFirst(reactants.count)), conditions: conditions,
            enthalpy: enthalpy, hazards: hazards, why: why)
    }

    // MARK: Patterns

    private static func neutralization(
        acid: Species, anion: Ion, base: Species, cation: Ion
    ) -> Reaction? {
        let salt = SpeciesCatalog.salt(cation: cation, anion: anion)
        let water = SpeciesCatalog.water
        return build(
            .neutralization, reactants: [acid, base], products: [salt, water],
            heatOf: water, kilojoules: -57,
            why: "An acid gives away hydrogen ions (H⁺) and a base supplies hydroxide (OH⁻) or takes "
                + "them. Together they make water, and the leftover ions form a salt: \(salt.name). "
                + "Neutralizing releases heat.")
    }

    private static func ammoniaNeutralization(acid: Species, anion: Ion, ammonia: Species) -> Reaction? {
        guard let ammonium = IonCatalog.cation("NH4", charge: 1) else { return nil }
        let salt = SpeciesCatalog.salt(cation: ammonium, anion: anion)
        return build(
            .neutralization, reactants: [acid, ammonia], products: [salt], heatOf: salt, kilojoules: -50,
            why: "Ammonia is a base without any hydroxide in it: it takes a hydrogen ion from the acid "
                + "and becomes the ammonium ion, which pairs with the acid's anion as \(salt.name).")
    }

    private static func acidMetal(acid: Species, anion: Ion, metal: Species) -> Reaction? {
        guard let symbol = metal.elementSymbol,
            ActivitySeries.displacesHydrogen(symbol),
            let profile = ActivitySeries.profile(of: symbol), profile.dissolvesInDiluteAcid,
            let cation = IonCatalog.cation(forMetal: symbol, charge: profile.charge),
            let hydrogen = species("H2")
        else { return nil }
        // Nitric acid oxidizes instead of releasing hydrogen; ReactionTable covers it.
        if acid.id == hill("HNO3") { return nil }
        // Concentrated sulfuric acid oxidizes too, so only the dilute acid gives hydrogen.
        let conditions =
            acid.id == hill("H2SO4") ? ReactionConditions(requiresDilute: acid.id) : ReactionConditions()

        let salt = SpeciesCatalog.salt(cation: cation, anion: anion)
        return build(
            .acidMetal, reactants: [metal, acid], products: [salt, hydrogen], conditions: conditions,
            heatOf: hydrogen, kilojoules: -150,
            why: "\(metal.name) is above hydrogen in the activity series, so it is more eager to be an "
                + "ion than hydrogen is. It gives its electrons to the acid's hydrogen ions, which "
                + "leave as hydrogen gas, and the metal dissolves as \(salt.name).")
    }

    private static func waterReaction(metal: Species) -> Reaction? {
        guard let symbol = metal.elementSymbol,
            let profile = ActivitySeries.profile(of: symbol), profile.waterReaction != .none,
            let cation = IonCatalog.cation(forMetal: symbol, charge: profile.charge),
            let hydroxide = SpeciesCatalog.base(cation: cation),
            let hydrogen = species("H2")
        else { return nil }

        let violent = profile.waterReaction == .violent
        var hazards: [HazardNote] = []
        if violent {
            hazards = [
                HazardNote(.explosive, "The heat of the reaction can ignite the hydrogen it releases."),
                HazardNote(.corrosive, "The hydroxide solution that forms is caustic and can spit."),
            ]
        }
        return build(
            .metalWater, reactants: [metal, SpeciesCatalog.water], products: [hydroxide, hydrogen],
            heatOf: hydrogen, kilojoules: violent ? -370 : -200, hazards: hazards,
            why: "\(metal.name) is so reactive that it pushes hydrogen out of water itself, with no acid "
                + "needed. What is left is \(hydroxide.name), a base, which is why the water turns "
                + "alkaline. The more reactive the metal, the faster and hotter this goes.")
    }

    private static func displacement(metal: Species, salt: Species) -> Reaction? {
        guard let symbol = metal.elementSymbol,
            let profile = ActivitySeries.profile(of: symbol), profile.waterReaction == .none,
            case .salt(let cation, let anion) = salt.role,
            salt.solubility == .soluble,
            cation.symbol != symbol,
            ActivitySeries.displaces(symbol, cation.symbol),
            let metalCation = IonCatalog.cation(forMetal: symbol, charge: profile.charge),
            let freed = SpeciesCatalog.metal(symbol: cation.symbol)
        else { return nil }

        let product = SpeciesCatalog.salt(cation: metalCation, anion: anion)
        return build(
            .displacement, reactants: [metal, salt], products: [product, freed], heatOf: freed, kilojoules: -150,
            why: "\(metal.name) is higher in the activity series than \(freed.name.lowercased()), so it "
                + "holds its electrons less tightly. It hands them to the \(cation.display) ions, which "
                + "turn into solid metal, while \(metal.name.lowercased()) goes into solution.")
    }

    private static func precipitation(_ x: Species, _ y: Species) -> Reaction? {
        guard let pairX = x.ionPair, let pairY = y.ionPair,
            pairX.cation != pairY.cation, pairX.anion != pairY.anion,
            let first = SpeciesCatalog.product(cation: pairX.cation, anion: pairY.anion),
            let second = SpeciesCatalog.product(cation: pairY.cation, anion: pairX.anion),
            first.solubility.precipitates || second.solubility.precipitates
        else { return nil }

        let solid = first.solubility.precipitates ? first : second
        return build(
            .precipitation, reactants: [x, y], products: [first, second], heatOf: solid, kilojoules: -20,
            why: "When both dissolve, their ions swap partners. \(solid.name) does not dissolve in "
                + "water, so its ions clump together and drop out as a solid (a precipitate). The "
                + "remaining ions stay dissolved and don't take part; they are called spectator ions.")
    }

    private static func gasEvolution(acid: Species, anion: Ion, salt: Species) -> Reaction? {
        guard case .salt(let cation, let saltAnion) = salt.role else { return nil }
        let released: [Species]
        let explanation: String
        switch saltAnion.symbol {
        case "CO3", "HCO3":
            guard let carbonDioxide = species("CO2") else { return nil }
            released = [SpeciesCatalog.water, carbonDioxide]
            explanation =
                "Acid turns carbonate into carbonic acid, which is unstable and falls apart into "
                + "water and carbon dioxide. The bubbles are CO₂ gas."
        case "S":
            guard let sulfide = species("H2S") else { return nil }
            released = [sulfide]
            explanation =
                "Acid turns sulfide into hydrogen sulfide, a gas that smells of rotten eggs and is "
                + "deadly in higher amounts."
        default:
            return nil
        }
        let product = SpeciesCatalog.salt(cation: cation, anion: anion)
        return build(
            .gasEvolution, reactants: [acid, salt], products: [product] + released, why: explanation)
    }

    private static func ammoniumRelease(salt: Species, base: Species) -> Reaction? {
        guard case .salt(let cation, let anion) = salt.role, cation.symbol == "NH4",
            case .base(let baseCation, _) = base.role, base.solubility != .insoluble,
            let ammonia = species("NH3")
        else { return nil }
        let product = SpeciesCatalog.salt(cation: baseCation, anion: anion)
        return build(
            .gasEvolution, reactants: [salt, base],
            products: [product, ammonia, SpeciesCatalog.water],
            why: "Hydroxide takes a hydrogen ion back from ammonium and turns it into ammonia gas, "
                + "which you smell as a sharp, choking odor.")
    }
}
