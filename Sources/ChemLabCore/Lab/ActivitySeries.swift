/// How a metal behaves with plain water.
public enum WaterReaction: Sendable {
    case none
    /// Fizzes steadily and makes hydrogen.
    case brisk
    /// So fast the metal melts and the hydrogen can ignite.
    case violent
}

public struct MetalProfile: Sendable {
    public let symbol: String
    /// Charge of the ion it forms when it dissolves or displaces another metal.
    public let charge: Int
    public let waterReaction: WaterReaction
    /// False when the salt it would form coats the metal and stops the reaction
    /// (lead in sulfuric or hydrochloric acid).
    public let dissolvesInDiluteAcid: Bool
}

/// The activity series: metals from most to least reactive, with hydrogen
/// placed where it falls. A metal above hydrogen pushes hydrogen out of acids,
/// and a metal displaces any metal below it from a salt solution.
public enum ActivitySeries {
    public static let metals: [MetalProfile] = [
        MetalProfile(symbol: "Li", charge: 1, waterReaction: .brisk, dissolvesInDiluteAcid: true),
        MetalProfile(symbol: "K", charge: 1, waterReaction: .violent, dissolvesInDiluteAcid: true),
        MetalProfile(symbol: "Ba", charge: 2, waterReaction: .brisk, dissolvesInDiluteAcid: true),
        MetalProfile(symbol: "Ca", charge: 2, waterReaction: .brisk, dissolvesInDiluteAcid: true),
        MetalProfile(symbol: "Na", charge: 1, waterReaction: .violent, dissolvesInDiluteAcid: true),
        MetalProfile(symbol: "Mg", charge: 2, waterReaction: .none, dissolvesInDiluteAcid: true),
        MetalProfile(symbol: "Al", charge: 3, waterReaction: .none, dissolvesInDiluteAcid: true),
        MetalProfile(symbol: "Zn", charge: 2, waterReaction: .none, dissolvesInDiluteAcid: true),
        MetalProfile(symbol: "Fe", charge: 2, waterReaction: .none, dissolvesInDiluteAcid: true),
        MetalProfile(symbol: "Ni", charge: 2, waterReaction: .none, dissolvesInDiluteAcid: true),
        MetalProfile(symbol: "Pb", charge: 2, waterReaction: .none, dissolvesInDiluteAcid: false),
        MetalProfile(symbol: "Cu", charge: 2, waterReaction: .none, dissolvesInDiluteAcid: false),
        MetalProfile(symbol: "Ag", charge: 1, waterReaction: .none, dissolvesInDiluteAcid: false),
    ]

    /// Symbols in order, with "H" where hydrogen sits.
    public static let order: [String] = [
        "Li", "K", "Ba", "Ca", "Na", "Mg", "Al", "Zn", "Fe", "Ni", "Pb", "H", "Cu", "Ag",
    ]

    public static func profile(of symbol: String) -> MetalProfile? {
        metals.first { $0.symbol == symbol }
    }

    /// True when `symbol` is above hydrogen, so it can release H₂ from an acid.
    public static func displacesHydrogen(_ symbol: String) -> Bool {
        guard let metal = order.firstIndex(of: symbol), let hydrogen = order.firstIndex(of: "H")
        else { return false }
        return metal < hydrogen
    }

    /// True when `symbol` is more reactive than `other`, so it can push `other`
    /// out of a solution of its salt.
    public static func displaces(_ symbol: String, _ other: String) -> Bool {
        guard let a = order.firstIndex(of: symbol), let b = order.firstIndex(of: other) else {
            return false
        }
        return a < b
    }
}
