import Foundation

/// What the UI and the learning layer read from a beaker.
extension Beaker {
    /// Molarity of a species dissolved in the water. Infinite when there is no
    /// water (a neat acid), and zero when the species isn't there.
    public func molarity(ofID id: String) -> Double {
        let total = contents
            .filter { $0.species.id == id && $0.state != .solid }
            .reduce(0.0) { $0 + $1.moles }
        guard total > Beaker.tiny else { return 0 }
        return volumeLiters > 0 ? total / volumeLiters : .infinity
    }

    /// Rough pH of the solution, or nil with no water. Strong acids and bases
    /// count as fully split into ions and weak ones as barely split, so treat
    /// the number as a guide, not a measurement.
    public var pH: Double? {
        let liters = volumeLiters
        guard liters > 0.001 else { return nil }

        // Net hydrogen ions minus hydroxide ions, in mol/L.
        var net = 0.0
        for item in contents where item.state == .aqueous {
            let perLiter = item.moles / liters
            switch item.species.role {
            case .acid(_, let protons, let strong):
                net += (strong ? 1.0 : 0.01) * Double(protons) * perLiter
            case .base(let cation, let strong):
                net -= (strong ? 1.0 : 0.05) * Double(abs(cation.charge)) * perLiter
            case .ammonia:
                net -= 0.01 * perLiter
            case .salt(_, let anion) where ["CO3", "PO4", "S"].contains(anion.symbol):
                // These anions grab hydrogen ions from water, so the solution turns basic.
                net -= 0.02 * Double(abs(anion.charge)) * perLiter
            default:
                break
            }
        }
        if abs(net) < 1e-7 { return 7 }
        let value = net > 0 ? -log10(net) : 14 + log10(-net)
        return min(max(value, 0), 14)
    }

    /// Volume of liquid in liters, for drawing the fill level.
    public var liquidVolumeLiters: Double {
        let neat = contents
            .filter { $0.state == .liquid && !$0.species.isWater }
            .reduce(0.0) { $0 + $1.grams / 1000 }  // about 1 g/mL
        return volumeLiters + neat
    }

    /// Colour of the liquid, tinted by dissolved colored ions; nil with no liquid.
    public var liquidColor: RGB? {
        let liters = volumeLiters
        if liters > 0 {
            var color = RGB.water
            for item in contents where item.state == .aqueous {
                guard let tint = item.species.solutionColor else { continue }
                let strength = min(0.85, 0.1 + 0.55 * (item.moles / liters))
                color = color.blended(with: tint, amount: strength)
            }
            return color
        }
        return contents.first { $0.state == .liquid && !$0.species.isWater }?.species.color
    }

    /// Solids sitting in the beaker (precipitates, undissolved powders, metals).
    public var solids: [Contents] { contents.filter { $0.state == .solid } }

    /// Dissolved substances.
    public var dissolved: [Contents] { contents.filter { $0.state == .aqueous } }

    /// Everything that deserves a badge right now: hazards of the gases and
    /// substances present, then those of what has happened. Nothing is ever
    /// blocked; this is only for labelling.
    public var activeHazards: [HazardNote] {
        var result: [HazardNote] = []
        func add(_ notes: [HazardNote]) {
            for note in notes where !result.contains(note) { result.append(note) }
        }
        for item in gases where item.moles > Beaker.tiny { add(item.species.hazards) }
        for item in contents where item.moles > Beaker.tiny { add(item.species.hazards) }
        for event in events { add(event.hazards) }
        if temperature >= 60 {
            add([HazardNote(.exothermic, String(format: "The beaker is at %.0f °C and can burn skin.", temperature))])
        }
        return result
    }

    /// Distinct hazard kinds for compact badges.
    public var activeHazardKinds: [Hazard] {
        var seen = Set<Hazard>()
        return activeHazards.map(\.hazard).filter { seen.insert($0).inserted }
    }
}
