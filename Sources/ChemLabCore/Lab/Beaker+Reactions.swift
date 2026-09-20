import Foundation

extension Beaker {
    /// Species id of oxygen, which an open beaker gets from the air.
    static let oxygenID = "O2"
    /// A safety net so a mistake in the data can't make `mix()` loop forever.
    static let maxReactionSteps = 60
    static let maxEvents = 100
    /// Below this many moles an amount counts as used up.
    static let tiny = 1e-10

    /// Lets everything that can react do so, one reaction at a time, until
    /// nothing more happens. Phases and dissolving are settled between steps.
    public mutating func mix() {
        settle()
        for _ in 0..<Beaker.maxReactionSteps {
            guard let next = nextReaction() else { break }
            apply(next.0, extent: next.1)
            settle()
        }
        flameActive = false
    }

    // MARK: Phases and dissolving

    /// Melts, freezes, boils and dissolves things according to the temperature
    /// and whether there is water to dissolve them in.
    mutating func settle() {
        let water = waterMoles
        let hasWater = water > 0
        let previous = contents
        contents = []
        var dissolvingHeat = 0.0

        for item in previous {
            let state = settledState(of: item, hasWater: hasWater)
            if state != item.state {
                noteChange(item.species, from: item.state, to: state)
                // Dissolving some things (lye, sulfuric acid) gives off a lot of heat. It
                // only counts when there is plenty of water to take it up.
                if state == .aqueous, item.species.hazards.contains(where: { $0.hazard == .exothermic }) {
                    let share = min(1, water / (10 * item.moles))
                    dissolvingHeat += 40_000 * item.moles * share
                }
            }
            deposit(item.species, moles: item.moles, state: state)
        }
        if dissolvingHeat > 0 { addEnergy(dissolvingHeat) }
    }

    private func settledState(of item: Contents, hasWater: Bool) -> MatterState {
        let species = item.species
        if species.isWater { return temperature <= 0 ? .solid : .liquid }
        if hasWater && species.solubility == .soluble { return .aqueous }
        return pureState(of: species)
    }

    /// State of the pure substance at the current temperature.
    private func pureState(of species: Species) -> MatterState {
        if let boil = species.boilingPoint, temperature >= boil { return .gas }
        if let melt = species.meltingPoint { return temperature >= melt ? .liquid : .solid }
        switch species.roomState {
        case .gas: return .gas
        case .aqueous: return .liquid
        default: return species.roomState
        }
    }

    private mutating func noteChange(_ species: Species, from old: MatterState, to new: MatterState) {
        switch (old, new) {
        case (_, .aqueous): log(.dissolved(species))
        case (.solid, .liquid): log(.melted(species))
        case (_, .gas): log(.boiled(species))
        default: break
        }
    }

    // MARK: Choosing a reaction

    private func nextReaction() -> (Reaction, Double)? {
        var seen = Set<String>()
        var present: [Species] = []
        for item in contents + gases {
            if seen.insert(item.species.id).inserted { present.append(item.species) }
        }
        guard !present.isEmpty else { return nil }

        // Hand-written rules first, since they cover the special cases.
        let candidates = ReactionTable.explicit + ReactionGenerator.reactions(among: present)
        for reaction in candidates {
            if let amount = extent(of: reaction), amount > Beaker.tiny { return (reaction, amount) }
        }
        return nil
    }

    /// How many times the reaction can run (in moles), or nil when it can't.
    func extent(of reaction: Reaction) -> Double? {
        guard conditionsMet(reaction.conditions) else { return nil }
        var limit = Double.infinity
        for part in reaction.reactants {
            let have = available(part.species, dry: reaction.conditions.worksDry)
            if have <= Beaker.tiny { return nil }
            limit = min(limit, have / Double(part.coefficient))
        }
        return limit.isFinite ? limit : nil
    }

    private func conditionsMet(_ conditions: ReactionConditions) -> Bool {
        if let minimum = conditions.minTemperature {
            // A flame or spark starts things without heating the whole beaker.
            let effective = flameActive ? max(temperature, 1000) : temperature
            guard effective >= minimum else { return false }
        }
        if let id = conditions.requiresConcentrated, molarity(ofID: id) < Beaker.concentratedMolarity {
            return false
        }
        if let id = conditions.requiresDilute, molarity(ofID: id) >= Beaker.concentratedMolarity {
            return false
        }
        return true
    }

    /// True for things that only react once dissolved: soluble acids, bases and salts.
    static func needsDissolving(_ species: Species) -> Bool {
        switch species.role {
        case .acid, .base, .salt, .ammonia: species.solubility == .soluble
        default: false
        }
    }

    /// Moles that can take part right now. Dry solid acids, bases and salts can't
    /// (they have to dissolve first, unless the reaction works dry), and ice is
    /// not liquid water.
    private func available(_ species: Species, dry: Bool) -> Double {
        if species.id == Beaker.oxygenID && openToAir { return .infinity }
        let skipsSolid = species.isWater || (!dry && Beaker.needsDissolving(species))
        var total = 0.0
        for item in contents where item.species.id == species.id {
            if item.state == .solid && skipsSolid { continue }
            total += item.moles
        }
        for item in gases where item.species.id == species.id { total += item.moles }
        return total
    }

    // MARK: Running a reaction

    private mutating func apply(_ reaction: Reaction, extent: Double) {
        let dry = reaction.conditions.worksDry
        for part in reaction.reactants {
            consume(part.species, moles: Double(part.coefficient) * extent, dry: dry)
        }
        // Water goes first, so the other products know whether there is a solvent.
        let products = reaction.products.sorted { $0.species.isWater && !$1.species.isWater }
        for part in products {
            produce(part.species, moles: Double(part.coefficient) * extent)
        }

        let released = -reaction.enthalpy * extent  // kJ
        if released >= 0 {
            addEnergy(released * 1000)
        } else {
            // Absorbing heat cools the beaker, but not by hundreds of degrees at once.
            let drop = min(25, -released * 1000 / heatCapacity)
            temperature = max(temperature - drop, -20)
        }

        var hazards = reaction.allHazards
        if released >= 50, !hazards.contains(where: { $0.hazard == .exothermic }) {
            hazards.append(
                HazardNote(.exothermic, String(format: "It gave off about %.0f kJ of heat.", released)))
        }
        events.append(
            ReactionEvent(
                id: nextEventID, reaction: reaction, extent: extent, heatReleased: released,
                temperatureAfter: temperature, hazards: hazards))
        nextEventID += 1
        if events.count > Beaker.maxEvents { events.removeFirst(events.count - Beaker.maxEvents) }
    }

    private mutating func consume(_ species: Species, moles: Double, dry: Bool) {
        if species.id == Beaker.oxygenID && openToAir { return }
        var remaining = moles
        let skipsSolid = species.isWater || (!dry && Beaker.needsDissolving(species))

        for state in [MatterState.aqueous, .liquid, .gas, .solid] {
            if state == .solid && skipsSolid { continue }
            if state == .gas {
                for i in gases.indices where gases[i].species.id == species.id && remaining > 0 {
                    let taken = min(remaining, gases[i].moles)
                    gases[i].moles -= taken
                    remaining -= taken
                }
            } else {
                for i in contents.indices
                where contents[i].species.id == species.id && contents[i].state == state && remaining > 0 {
                    let taken = min(remaining, contents[i].moles)
                    contents[i].moles -= taken
                    remaining -= taken
                }
            }
        }
        contents.removeAll { $0.moles <= Beaker.tiny }
        gases.removeAll { $0.moles <= Beaker.tiny }
    }

    private mutating func produce(_ species: Species, moles: Double) {
        let state = productState(for: species)
        deposit(species, moles: moles, state: state)
        switch state {
        case .solid: log(.solidFormed(species))
        case .gas: log(.gasReleased(species))
        default: break
        }
    }

    /// Where a newly made substance ends up. Gases bubble out even when they are
    /// soluble (a simplification that keeps toxic gases visible), soluble things
    /// dissolve when there is water, and insoluble things fall out as solids.
    private func productState(for species: Species) -> MatterState {
        if species.roomState == .gas { return .gas }
        if species.isWater { return .liquid }
        if waterMoles > 0 {
            return species.solubility == .soluble ? .aqueous : .solid
        }
        return pureState(of: species)
    }
}
