import Foundation

/// An amount of one species in a given state.
public struct Contents: Identifiable, Sendable, Hashable {
    public let species: Species
    public var moles: Double
    public var state: MatterState

    public var id: String { "\(species.id)/\(state.rawValue)" }
    public var grams: Double { moles * species.molarMass }

    public init(species: Species, moles: Double, state: MatterState) {
        self.species = species
        self.moles = moles
        self.state = state
    }
}

/// One reaction that ran inside a beaker.
public struct ReactionEvent: Identifiable, Sendable {
    public let id: Int
    public let reaction: Reaction
    /// How many times the equation ran, in moles.
    public let extent: Double
    /// Heat given off in kJ (negative when the reaction absorbed heat).
    public let heatReleased: Double
    public let temperatureAfter: Double
    /// Reaction hazards plus those of what it made, without repeats.
    public let hazards: [HazardNote]

    public var why: String { reaction.why }
}

/// Something worth telling the learner about, in the order it happened. (Not
/// called `Observation`: that would shadow Swift's `Observation` module, which
/// the `@Observable` macro refers to by name.)
public enum LabNote: Sendable, Hashable {
    case added(Species, moles: Double)
    case dissolved(Species)
    case melted(Species)
    case boiled(Species)
    case solidFormed(Species)
    case gasReleased(Species)

    public var text: String {
        switch self {
        case .added(let species, let moles):
            "Added \(Beaker.amountText(species, moles: moles)) of \(species.name)."
        case .dissolved(let species):
            "\(species.name) dissolved in the water."
        case .melted(let species):
            "\(species.name) melted."
        case .boiled(let species):
            "\(species.name) boiled away."
        case .solidFormed(let species):
            "A solid formed: \(species.name)."
        case .gasReleased(let species):
            "Gas released: \(species.name)."
        }
    }
}

/// A beaker and everything in it. All the lab's rules run inside `mix()`.
public struct Beaker: Sendable {
    public static let roomTemperature = 20.0
    /// Molarity at or above which an acid counts as concentrated.
    public static let concentratedMolarity = 8.0
    static let litersPerMoleOfWater = 0.018
    static let waterBoilingPoint = 100.0
    static let latentHeatOfWater = 40_700.0
    static let maxLogLength = 200

    public var name: String
    /// Solids, liquids and dissolved substances.
    public internal(set) var contents: [Contents] = []
    /// Gas above the liquid. It stays until the beaker is ventilated.
    public internal(set) var gases: [Contents] = []
    /// Degrees Celsius.
    public internal(set) var temperature = Beaker.roomTemperature
    /// When true, air supplies oxygen for burning.
    public var openToAir = true
    public internal(set) var events: [ReactionEvent] = []
    public internal(set) var observations: [LabNote] = []
    /// True for the length of one `mix()`, after a spark or flame is applied.
    var flameActive = false
    var nextEventID = 0

    public init(name: String = "Beaker") {
        self.name = name
    }

    public var isEmpty: Bool { contents.isEmpty && gases.isEmpty }

    // MARK: Adding

    /// Puts an amount of `species` in the beaker and lets everything react.
    /// `water` is moles of water that come with it, for reagents sold as
    /// solutions (see `Species.solutionWaterPerMole`); it goes in first.
    public mutating func add(_ species: Species, moles: Double, water: Double = 0) {
        guard moles > 0 else { return }
        if water > 0 { deposit(SpeciesCatalog.water, moles: water, state: .liquid) }
        deposit(species, moles: moles, state: entryState(for: species))
        log(.added(species, moles: moles))
        mix()
    }

    /// Adds `grams` of a species; convenient for the UI's portions.
    public mutating func add(_ species: Species, grams: Double, water: Double = 0) {
        guard species.molarMass > 0 else { return }
        add(species, moles: grams / species.molarMass, water: water)
    }

    private func entryState(for species: Species) -> MatterState {
        switch species.roomState {
        case .gas:
            // Very soluble gases (ammonia) go into water when there is some.
            return species.solubility == .soluble && waterMoles > 0 ? .aqueous : .gas
        case .liquid, .aqueous:
            return .liquid
        case .solid:
            return .solid
        }
    }

    // MARK: Actions

    /// Adds heat, in kilojoules. Water boils at 100 °C and holds the temperature
    /// there until it has all gone.
    public mutating func heat(kilojoules: Double = 4) {
        addEnergy(kilojoules * 1000)
        mix()
    }

    /// Cools toward `target` degrees (an ice bath, or just waiting).
    public mutating func cool(to target: Double = Beaker.roomTemperature) {
        if temperature > target { temperature = max(target, -20) }
        mix()
    }

    /// A spark or open flame: enough to start burning things that have an
    /// ignition temperature, without heating the beaker itself.
    public mutating func applyFlame() {
        flameActive = true
        mix()
    }

    /// Swirls the beaker so anything that can react gets the chance to.
    public mutating func stir() {
        mix()
    }

    /// Clears the gas above the liquid, like opening a window or a fume hood.
    public mutating func ventilate() {
        gases = []
    }

    public mutating func empty() {
        contents = []
        gases = []
        openToAir = true
        temperature = Beaker.roomTemperature
        events = []
        observations = []
    }

    // MARK: Pouring

    /// What comes out when a beaker is poured into another.
    public struct Portion: Sendable {
        public var contents: [Contents]
        public var temperature: Double
        public var heatCapacity: Double
    }

    /// Pours off `fraction` of the liquid. Undissolved solids stay behind (this is
    /// how you decant off a precipitate) unless `includingSolids` is set.
    public mutating func pourOut(fraction: Double, includingSolids: Bool = false) -> Portion {
        let f = min(max(fraction, 0), 1)
        var poured: [Contents] = []
        for index in contents.indices {
            let item = contents[index]
            if item.state == .solid && !includingSolids { continue }
            let moved = item.moles * f
            guard moved > 0 else { continue }
            contents[index].moles -= moved
            poured.append(Contents(species: item.species, moles: moved, state: item.state))
        }
        let capacity = poured.reduce(0.0) { $0 + Beaker.capacity(of: $1) }
        contents.removeAll { $0.moles <= 1e-12 }
        return Portion(contents: poured, temperature: temperature, heatCapacity: capacity)
    }

    /// Pours a portion in, blending temperatures, and lets everything react.
    public mutating func pourIn(_ portion: Portion) {
        let own = heatCapacity
        let total = own + portion.heatCapacity
        if total > 0 {
            temperature = (temperature * own + portion.temperature * portion.heatCapacity) / total
        }
        for item in portion.contents { deposit(item.species, moles: item.moles, state: item.state) }
        mix()
    }

    // MARK: Bookkeeping shared with the other files

    mutating func deposit(_ species: Species, moles: Double, state: MatterState) {
        guard moles > 0 else { return }
        if state == .gas {
            if let index = gases.firstIndex(where: { $0.species.id == species.id }) {
                gases[index].moles += moles
            } else {
                gases.append(Contents(species: species, moles: moles, state: .gas))
            }
        } else if let index = contents.firstIndex(where: { $0.species.id == species.id && $0.state == state }) {
            contents[index].moles += moles
        } else {
            contents.append(Contents(species: species, moles: moles, state: state))
        }
    }

    mutating func log(_ observation: LabNote) {
        observations.append(observation)
        if observations.count > Beaker.maxLogLength {
            observations.removeFirst(observations.count - Beaker.maxLogLength)
        }
    }

    /// Heat capacity contribution in J/K: water is 75.3 per mole, everything else is a rough 50.
    static func capacity(of item: Contents) -> Double {
        item.species.isWater ? 75.3 * item.moles : 50 * item.moles
    }

    /// Heat capacity of the beaker and contents in J/K (the glass counts for 40).
    public var heatCapacity: Double {
        40 + contents.reduce(0.0) { $0 + Beaker.capacity(of: $1) }
    }

    /// Moles of liquid water, which is the solvent.
    public var waterMoles: Double {
        contents.filter { $0.species.isWater && $0.state == .liquid }.reduce(0.0) { $0 + $1.moles }
    }

    /// Liters of solvent.
    public var volumeLiters: Double { waterMoles * Beaker.litersPerMoleOfWater }

    /// Applies energy in joules. Below the boiling point it changes the
    /// temperature; at the boiling point of water it boils water away instead.
    mutating func addEnergy(_ joules: Double) {
        var remaining = joules
        if remaining > 0, waterMoles > 0 {
            if temperature < Beaker.waterBoilingPoint {
                let toBoil = (Beaker.waterBoilingPoint - temperature) * heatCapacity
                if remaining <= toBoil {
                    temperature += remaining / heatCapacity
                    return
                }
                remaining -= toBoil
                temperature = Beaker.waterBoilingPoint
            }
            let boiled = min(waterMoles, remaining / Beaker.latentHeatOfWater)
            removeWater(moles: boiled)
            remaining -= boiled * Beaker.latentHeatOfWater
            if waterMoles > 0 { return }
        }
        temperature = min(max(temperature + remaining / heatCapacity, -20), 1800)
    }

    private mutating func removeWater(moles: Double) {
        guard moles > 0, let index = contents.firstIndex(where: { $0.species.isWater && $0.state == .liquid })
        else { return }
        if contents[index].moles - moles < 1e-9 {
            log(.boiled(contents[index].species))
            contents.remove(at: index)
        } else {
            contents[index].moles -= moles
        }
    }

    static func amountText(_ species: Species, moles: Double) -> String {
        let grams = moles * species.molarMass
        if grams >= 100 { return String(format: "%.0f g", grams) }
        if grams >= 10 { return String(format: "%.1f g", grams) }
        return String(format: "%.2f g", grams)
    }
}
