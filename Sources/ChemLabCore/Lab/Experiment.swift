import Foundation

/// Something the bench can be asked to do, used to script experiments.
public enum LabStep: Sendable, Hashable {
    /// Add `moles` of the species with this formula. `strength` chooses the
    /// solution form for acids, ammonia and bases (nil adds it as it is).
    case put(String, moles: Double, strength: ReagentStrength?)
    case heat(times: Int, kilojoules: Double)
    case flame
    case closeBeaker

    /// One line for the UI: "Add 0.05 mol of Zinc".
    public var text: String {
        switch self {
        case .put(let formula, let moles, let strength):
            let name = SpeciesCatalog.species(formula: formula)?.name ?? formula
            let form = strength.map { $0 == .asSold ? ", concentrated" : ", dilute" } ?? ""
            return "Add \(Beaker.formatMoles(moles)) of \(name)\(form)"
        case .heat(let times, let kilojoules):
            return "Heat it with about \(Int(Double(times) * kilojoules)) kJ in total"
        case .flame:
            return "Hold a flame or spark to it"
        case .closeBeaker:
            return "Cover the beaker so no air gets in"
        }
    }
}

extension Beaker {
    /// Adds `moles` of a species, together with the water it comes in when a
    /// strength is given (a concentrated acid is a solution, not a pure liquid).
    public mutating func add(_ species: Species, moles: Double, strength: ReagentStrength?) {
        let perMole = strength.flatMap { species.solutionWaterPerMole($0) } ?? 0
        add(species, moles: moles, water: perMole * moles)
    }

    public mutating func run(_ step: LabStep) {
        switch step {
        case .put(let formula, let moles, let strength):
            guard let species = SpeciesCatalog.species(formula: formula) else { return }
            add(species, moles: moles, strength: strength)
        case .heat(let times, let kilojoules):
            for _ in 0..<max(times, 0) { heat(kilojoules: kilojoules) }
        case .flame:
            applyFlame()
        case .closeBeaker:
            openToAir = false
        }
    }

    public mutating func run(_ steps: [LabStep]) {
        for step in steps { run(step) }
    }

    static func formatMoles(_ moles: Double) -> String {
        moles >= 1 ? String(format: "%.1f mol", moles) : String(format: "%.2f mol", moles)
    }
}

/// A guided experiment: a recipe the learner can load onto the bench, and
/// what to look for. Each one says what it should produce so tests can run it.
public struct Experiment: Identifiable, Sendable, Hashable {
    public let id: String
    public let title: String
    public let summary: String
    /// What to notice.
    public let watchFor: String
    public let steps: [LabStep]
    /// What the beaker should hold or show afterward.
    public let expected: ChallengeGoal
}

public enum ExperimentLibrary {
    public static let all: [Experiment] = [
        Experiment(
            id: "volcano", title: "Fizzing baking-soda volcano",
            summary: "Vinegar on baking soda.",
            watchFor: "Bubbles of carbon dioxide. Watch the equation and where the gas comes from.",
            steps: [
                .put("H2O", moles: 5, strength: nil),
                .put("NaHCO3", moles: 0.05, strength: nil),
                .put("CH3COOH", moles: 0.05, strength: .dilute),
            ],
            expected: .gasPresent("CO2")),
        Experiment(
            id: "neutralize", title: "Neutralize an acid",
            summary: "Hydrochloric acid and lye make salt water.",
            watchFor: "The pH readout falls from acidic to about 7, and the beaker warms.",
            steps: [
                .put("H2O", moles: 5, strength: nil),
                .put("HCl", moles: 0.05, strength: nil),
                .put("NaOH", moles: 0.05, strength: nil),
            ],
            expected: .all([.reactionKind(.neutralization), .phBetween(low: 6.5, high: 7.5)])),
        Experiment(
            id: "silver-chloride", title: "A precipitate from two clear liquids",
            summary: "Silver nitrate meets table salt in water.",
            watchFor: "A white solid appears from two clear solutions. Then decant the liquid off.",
            steps: [
                .put("H2O", moles: 5, strength: nil),
                .put("AgNO3", moles: 0.05, strength: nil),
                .put("NaCl", moles: 0.05, strength: nil),
            ],
            expected: .contains("AgCl", state: .solid)),
        Experiment(
            id: "golden-rain", title: "Golden rain",
            summary: "Lead nitrate and potassium iodide.",
            watchFor: "Bright yellow lead iodide. It is toxic: see the hazard badge and why.",
            steps: [
                .put("H2O", moles: 10, strength: nil),
                .put("Pb(NO3)2", moles: 0.01, strength: nil),
                .put("KI", moles: 0.02, strength: nil),
            ],
            expected: .contains("PbI2", state: .solid)),
        Experiment(
            id: "copper-tree", title: "Zinc takes copper's place",
            summary: "Zinc in blue copper sulfate solution.",
            watchFor: "The blue color fades as copper metal appears. Zinc is higher in the activity series.",
            steps: [
                .put("H2O", moles: 5, strength: nil),
                .put("CuSO4", moles: 0.05, strength: nil),
                .put("Zn", moles: 0.05, strength: nil),
            ],
            expected: .contains("Cu", state: .solid)),
        Experiment(
            id: "ammonia", title: "Smelling salts",
            summary: "Lye frees ammonia from an ammonium salt.",
            watchFor: "Ammonia gas is toxic and corrosive to the airways. Ventilate afterward.",
            steps: [
                .put("H2O", moles: 5, strength: nil),
                .put("NH4Cl", moles: 0.05, strength: nil),
                .put("NaOH", moles: 0.05, strength: nil),
            ],
            expected: .gasPresent("NH3")),
        Experiment(
            id: "copper-nitric", title: "Copper in concentrated nitric acid",
            summary: "The classic brown-gas reaction.",
            watchFor: "Poisonous brown NO₂. Try dilute acid next: the gas changes.",
            steps: [
                .put("HNO3", moles: 0.4, strength: .asSold),
                .put("Cu", moles: 0.1, strength: nil),
            ],
            expected: .all([.gasPresent("NO2"), .hazardShown(.toxic)])),
        Experiment(
            id: "lye-aluminum", title: "Lye and aluminum",
            summary: "Aluminum dissolves in a strong base.",
            watchFor: "Hydrogen gas is explosive, and the mixture gets very hot.",
            steps: [
                .put("H2O", moles: 5, strength: nil),
                .put("NaOH", moles: 0.1, strength: nil),
                .put("Al", moles: 0.1, strength: nil),
            ],
            expected: .all([.gasPresent("H2"), .hazardShown(.explosive)])),
        Experiment(
            id: "sodium-water", title: "Sodium in water",
            summary: "The most famous violent reaction.",
            watchFor: "Hydrogen, heat and a strong base. The hydrogen can ignite from the heat.",
            steps: [
                .put("H2O", moles: 2, strength: nil),
                .put("Na", moles: 0.05, strength: nil),
            ],
            expected: .all([.reactionKind(.metalWater), .hazardShown(.explosive)])),
        Experiment(
            id: "bleach-acid", title: "Why you never mix bleach and acid",
            summary: "Household bleach with an acidic cleaner.",
            watchFor: "Chlorine gas. This is a real accident that happens in homes.",
            steps: [
                .put("H2O", moles: 5, strength: nil),
                .put("NaClO", moles: 0.05, strength: nil),
                .put("HCl", moles: 0.1, strength: nil),
            ],
            expected: .all([.gasPresent("Cl2"), .hazardShown(.toxic)])),
        Experiment(
            id: "magnesium", title: "Burning magnesium",
            summary: "A metal that burns in air.",
            watchFor: "It needs a flame to start, then keeps itself going. Close the beaker and try again.",
            steps: [
                .put("Mg", moles: 0.1, strength: nil),
                .flame,
            ],
            expected: .contains("MgO", state: .solid)),
        Experiment(
            id: "hydrogen-pop", title: "The hydrogen pop",
            summary: "Hydrogen and air, lit.",
            watchFor: "Nothing happens until the spark. Then it burns fast and releases a lot of energy.",
            steps: [
                .put("H2", moles: 0.1, strength: nil),
                .flame,
            ],
            expected: .all([.reactionKind(.combustion), .hazardShown(.explosive)])),
        Experiment(
            id: "thermite", title: "Thermite",
            summary: "Aluminum and rust.",
            watchFor: "Enormous heat from two solids. Aluminum grabs oxygen from iron.",
            steps: [
                .put("Al", moles: 0.1, strength: nil),
                .put("Fe2O3", moles: 0.05, strength: nil),
                .flame,
            ],
            expected: .contains("Fe", state: nil)),
        Experiment(
            id: "limestone", title: "Limestone to quicklime",
            summary: "Heat breaks down calcium carbonate.",
            watchFor: "Nothing until it is very hot. Then carbon dioxide escapes.",
            steps: [
                .put("CaCO3", moles: 0.1, strength: nil),
                .heat(times: 45, kilojoules: 5),
            ],
            expected: .contains("CaO", state: .solid)),
        Experiment(
            id: "sugar-char", title: "Charring sugar",
            summary: "Heat pulls the water out of sugar.",
            watchFor: "It melts, then goes black. What is left is carbon.",
            steps: [
                .closeBeaker,
                .put("C12H22O11", moles: 0.01, strength: nil),
                .heat(times: 20, kilojoules: 1),
            ],
            expected: .contains("C", state: .solid)),
    ]
}
