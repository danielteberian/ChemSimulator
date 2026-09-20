/// Hazard categories, modelled on the GHS pictograms so learners pick up the
/// real-world symbols.
public enum Hazard: String, Sendable, CaseIterable, Hashable {
    case corrosive
    case toxic
    case explosive
    case flammable
    case oxidizer
    case waterReactive
    case irritant
    case healthHazard
    case environmental
    case exothermic

    public var title: String {
        switch self {
        case .corrosive: "Corrosive"
        case .toxic: "Toxic"
        case .explosive: "Explosive"
        case .flammable: "Flammable"
        case .oxidizer: "Oxidizer"
        case .waterReactive: "Reacts with water"
        case .irritant: "Irritant"
        case .healthHazard: "Health hazard"
        case .environmental: "Environmental hazard"
        case .exothermic: "Releases heat"
        }
    }

    /// SF Symbols name the UI can use for the badge.
    public var symbolName: String {
        switch self {
        case .corrosive: "drop.triangle.fill"
        case .toxic: "exclamationmark.octagon.fill"
        case .explosive: "burst.fill"
        case .flammable: "flame.fill"
        case .oxidizer: "circle.dashed.inset.filled"
        case .waterReactive: "drop.fill"
        case .irritant: "exclamationmark.triangle.fill"
        case .healthHazard: "cross.case.fill"
        case .environmental: "leaf.fill"
        case .exothermic: "thermometer.high"
        }
    }
}

/// A hazard plus a one-line explanation of why, shown to the learner.
public struct HazardNote: Sendable, Hashable {
    public let hazard: Hazard
    public let reason: String

    public init(_ hazard: Hazard, _ reason: String) {
        self.hazard = hazard
        self.reason = reason
    }
}
