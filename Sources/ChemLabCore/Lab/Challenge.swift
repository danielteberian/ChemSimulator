/// What a beaker has to show for a challenge to count as done. Written as data
/// so challenges can be listed, saved and tested.
public indirect enum ChallengeGoal: Sendable, Hashable {
    /// The beaker holds some of the species with this formula, in this state
    /// (any state when nil).
    case contains(String, state: MatterState?)
    /// The gas above the liquid includes this species.
    case gasPresent(String)
    /// The gas above the liquid includes this species, and a reaction made it
    /// (adding the gas straight from the shelf doesn't count).
    case producedGas(String)
    /// A reaction made a gas that carries this hazard, and it is still in the beaker.
    case gasFromReaction(Hazard)
    case phBetween(low: Double, high: Double)
    case reactionKind(Reaction.Kind)
    case temperatureAtLeast(Double)
    /// A hazard of this kind is being shown for the beaker.
    case hazardShown(Hazard)
    /// Every one of these.
    case all([ChallengeGoal])

    public func isMet(by beaker: Beaker) -> Bool {
        switch self {
        case .contains(let formula, let state):
            guard let id = Formula(parsing: formula)?.hill else { return false }
            let inside = beaker.contents.contains {
                $0.species.id == id && $0.moles > Beaker.tiny && (state == nil || $0.state == state)
            }
            let inGas = (state == nil || state == .gas)
                && beaker.gases.contains { $0.species.id == id && $0.moles > Beaker.tiny }
            return inside || inGas
        case .gasPresent(let formula):
            guard let id = Formula(parsing: formula)?.hill else { return false }
            return beaker.gases.contains { $0.species.id == id && $0.moles > Beaker.tiny }
        case .producedGas(let formula):
            guard let id = Formula(parsing: formula)?.hill else { return false }
            let present = beaker.gases.contains { $0.species.id == id && $0.moles > Beaker.tiny }
            let made = beaker.events.contains { event in
                event.reaction.products.contains { $0.species.id == id }
            }
            return present && made
        case .gasFromReaction(let hazard):
            let madeGases = beaker.events.flatMap { event in
                event.reaction.products.map(\.species).filter { $0.roomState == .gas }
            }
            return beaker.gases.contains { item in
                item.moles > Beaker.tiny
                    && item.species.hazards.contains { $0.hazard == hazard }
                    && madeGases.contains { $0.id == item.species.id }
            }
        case .phBetween(let low, let high):
            guard let pH = beaker.pH else { return false }
            return pH >= low && pH <= high
        case .reactionKind(let kind):
            return beaker.events.contains { $0.reaction.kind == kind }
        case .temperatureAtLeast(let degrees):
            return beaker.temperature >= degrees
        case .hazardShown(let hazard):
            return beaker.activeHazardKinds.contains(hazard)
        case .all(let goals):
            return goals.allSatisfy { $0.isMet(by: beaker) }
        }
    }
}

public struct Challenge: Identifiable, Sendable, Hashable {
    public let id: String
    public let title: String
    /// What to do, in plain words.
    public let prompt: String
    public let hint: String
    public let goal: ChallengeGoal
    /// One way to do it, so "Show me" can play it on the bench.
    public let solution: [LabStep]
    /// What the learner should take away, shown when it's done.
    public let learned: String
}

public enum ChallengeLibrary {
    public static let all: [Challenge] = [
        Challenge(
            id: "make-salt", title: "Make table salt",
            prompt: "Start with an acid and a base, and end up with sodium chloride dissolved in water.",
            hint: "Hydrochloric acid supplies the chloride and lye supplies the sodium. Use water as the solvent.",
            goal: .all([.reactionKind(.neutralization), .contains("NaCl", state: .aqueous)]),
            solution: [
                .put("H2O", moles: 5, strength: nil),
                .put("HCl", moles: 0.05, strength: nil),
                .put("NaOH", moles: 0.05, strength: nil),
            ],
            learned: "Acid + base gives a salt and water. The salt's name comes from the base's metal and the acid's anion."),
        Challenge(
            id: "neutralize", title: "Neutralize an acid",
            prompt: "Bring an acid's pH to about 7 (between 6.5 and 7.5) by adding a base.",
            hint: "Add a base a little at a time and watch the pH. Exactly matching amounts of a strong acid and base gives 7.",
            goal: .all([.reactionKind(.neutralization), .phBetween(low: 6.5, high: 7.5)]),
            solution: [
                .put("H2O", moles: 5, strength: nil),
                .put("HCl", moles: 0.05, strength: nil),
                .put("NaOH", moles: 0.05, strength: nil),
            ],
            learned: "Neutralizing means matching hydrogen ions with hydroxide ions until neither is left over. Too much base overshoots to alkaline."),
        Challenge(
            id: "make-hydrogen", title: "Make hydrogen gas",
            prompt: "Release hydrogen gas from a reaction.",
            hint: "A metal above hydrogen in the activity series will push hydrogen out of an acid.",
            goal: .producedGas("H2"),
            solution: [
                .put("H2O", moles: 5, strength: nil),
                .put("HCl", moles: 0.1, strength: nil),
                .put("Zn", moles: 0.05, strength: nil),
            ],
            learned: "Metals above hydrogen in the activity series release it from acids. Hydrogen is flammable and explosive, which is why the badge appears."),
        Challenge(
            id: "fizz", title: "Make it fizz",
            prompt: "Produce carbon dioxide gas without heating anything.",
            hint: "Acids attack carbonates. Baking soda and vinegar are both in the kitchen.",
            goal: .producedGas("CO2"),
            solution: [
                .put("H2O", moles: 5, strength: nil),
                .put("NaHCO3", moles: 0.05, strength: nil),
                .put("CH3COOH", moles: 0.05, strength: .dilute),
            ],
            learned: "An acid turns carbonate into carbonic acid, which falls apart into water and carbon dioxide."),
        Challenge(
            id: "precipitate", title: "Make a solid from two liquids",
            prompt: "Mix two clear solutions so that a solid forms.",
            hint: "Check the solubility rules: silver chloride and lead iodide do not dissolve in water.",
            goal: .all([.reactionKind(.precipitation)]),
            solution: [
                .put("H2O", moles: 5, strength: nil),
                .put("AgNO3", moles: 0.05, strength: nil),
                .put("NaCl", moles: 0.05, strength: nil),
            ],
            learned: "Ions swap partners. If a new pairing is insoluble, it leaves the solution as a precipitate; the other ions are just spectators."),
        Challenge(
            id: "golden-rain", title: "Golden rain",
            prompt: "Make yellow lead iodide.",
            hint: "Mix a soluble lead salt with a soluble iodide, in water.",
            goal: .contains("PbI2", state: .solid),
            solution: [
                .put("H2O", moles: 10, strength: nil),
                .put("Pb(NO3)2", moles: 0.01, strength: nil),
                .put("KI", moles: 0.02, strength: nil),
            ],
            learned: "A striking precipitate, and also a toxic one: lead compounds never go down the drain."),
        Challenge(
            id: "displace-copper", title: "Take copper out of solution",
            prompt: "Turn dissolved copper back into copper metal.",
            hint: "A metal higher in the activity series will push copper out of its salt.",
            goal: .all([.reactionKind(.displacement), .contains("Cu", state: .solid)]),
            solution: [
                .put("H2O", moles: 5, strength: nil),
                .put("CuSO4", moles: 0.05, strength: nil),
                .put("Zn", moles: 0.05, strength: nil),
            ],
            learned: "The more reactive metal gives electrons to the copper ions. That is the activity series in action."),
        Challenge(
            id: "toxic-gas", title: "Discover a toxic gas",
            prompt: "Make a reaction that releases a poisonous gas, so you know what to avoid.",
            hint: "Copper in concentrated nitric acid, or bleach with an acid, both do it. Both are real accidents.",
            goal: .gasFromReaction(.toxic),
            solution: [
                .put("HNO3", moles: 0.4, strength: .asSold),
                .put("Cu", moles: 0.1, strength: nil),
            ],
            learned: "Nitric acid is an oxidizer, so it doesn't just release hydrogen. Brown NO₂ is poisonous. Knowing which combinations do this is the point of lab safety."),
        Challenge(
            id: "explosive-gas", title: "Make an explosive gas",
            prompt: "Produce a gas that forms explosive mixtures with air, using an everyday material.",
            hint: "Lye, water and a piece of aluminum foil.",
            goal: .all([.gasPresent("H2"), .contains("NaAl(OH)4", state: .aqueous)]),
            solution: [
                .put("H2O", moles: 5, strength: nil),
                .put("NaOH", moles: 0.1, strength: nil),
                .put("Al", moles: 0.1, strength: nil),
            ],
            learned: "Aluminum is amphoteric: strong bases dissolve it too. The reaction is hot and makes hydrogen quickly, so drain cleaners with aluminum are dangerous."),
        Challenge(
            id: "ignite", title: "Light something",
            prompt: "Set off a combustion reaction.",
            hint: "Combustion needs oxygen and enough heat to start. Try magnesium and a flame.",
            goal: .reactionKind(.combustion),
            solution: [
                .put("Mg", moles: 0.1, strength: nil),
                .flame,
            ],
            learned: "Burning needs fuel, oxygen and heat. Once it starts, the heat it gives off keeps it going."),
        Challenge(
            id: "boil", title: "Boil water",
            prompt: "Heat a beaker of water until it boils.",
            hint: "Use the heat button. The temperature stops rising at the boiling point while water turns to steam.",
            goal: .all([.temperatureAtLeast(100), .contains("H2O", state: .liquid)]),
            solution: [
                .put("H2O", moles: 2, strength: nil),
                .heat(times: 4, kilojoules: 5),
            ],
            learned: "While water boils, all the added heat goes into turning it into steam, so the temperature holds at 100 °C."),
        Challenge(
            id: "quicklime", title: "Bake limestone",
            prompt: "Break limestone (calcium carbonate) down into quicklime.",
            hint: "It takes a lot of heat, about 825 °C.",
            goal: .contains("CaO", state: .solid),
            solution: [
                .put("CaCO3", moles: 0.1, strength: nil),
                .heat(times: 45, kilojoules: 5),
            ],
            learned: "Some compounds only break apart when they are very hot. Limestone loses CO₂ to make lime, which is the start of cement."),
    ]
}
