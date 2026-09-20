/// How a reagent is supplied to the beaker.
public enum ReagentStrength: String, CaseIterable, Identifiable, Sendable {
    /// The strong solution you'd buy (68% nitric acid, 37% hydrochloric acid).
    case asSold
    /// About 1 mol per liter.
    case dilute

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .asSold: "As sold"
        case .dilute: "Dilute (about 1 M)"
        }
    }
}

extension Species {
    /// Moles of water per mole of substance in the reagent as sold. For example
    /// 68% nitric acid is about 1.9 mol of water per mol of HNO₃.
    private static let waterInConcentratedReagent: [String: Double] = {
        let table: [(String, Double)] = [
            ("HCl", 3.5), ("HBr", 4.9), ("HI", 5.4), ("HNO3", 1.9), ("H2SO4", 0.11),
            ("H3PO4", 0.96), ("CH3COOH", 0), ("NH3", 2.4),
        ]
        var result: [String: Double] = [:]
        for (text, water) in table {
            if let formula = Formula(parsing: text) { result[formula.hill] = water }
        }
        return result
    }()

    /// Roughly 1 L of water per mole, which makes a 1 M solution.
    private static let waterPerMoleAtOneMolar = 55.0

    /// Water (moles per mole of substance) that comes with this species when it is
    /// added as a solution, or nil when it is only ever added as it is (metals,
    /// salts, gases). Acids and ammonia are liquids or solutions; bases are sold as
    /// solids, so only their dilute form is a solution.
    public func solutionWaterPerMole(_ strength: ReagentStrength) -> Double? {
        switch role {
        case .acid, .ammonia:
            switch strength {
            case .asSold: return Species.waterInConcentratedReagent[id] ?? 2
            case .dilute: return Species.waterPerMoleAtOneMolar
            }
        case .base:
            return strength == .dilute ? Species.waterPerMoleAtOneMolar : nil
        default:
            return nil
        }
    }

    /// True when the UI should offer a strength choice for this species.
    public var hasSolutionForm: Bool { solutionWaterPerMole(.dilute) != nil }

    /// Small, medium and large amounts for the shelf's buttons: milliliters of
    /// water, liters of gas (at room conditions, about 24 L per mole), or grams.
    public var amountChoices: [AmountChoice] {
        if isWater {
            return [25.0, 100, 200].map {
                AmountChoice(label: "\(Int($0)) mL", moles: $0 / molarMass)  // 1 g per mL
            }
        }
        if roomState == .gas && !hasSolutionForm {
            return [("0.5 L", 0.5), ("2 L", 2), ("5 L", 5)].map {
                AmountChoice(label: $0.0, moles: $0.1 / 24)
            }
        }
        return [1.0, 5, 20].map { AmountChoice(label: "\(Int($0)) g", moles: $0 / molarMass) }
    }
}

/// One of the amounts offered for a species.
public struct AmountChoice: Identifiable, Sendable, Hashable {
    public let label: String
    public let moles: Double

    public var id: String { label }
}
