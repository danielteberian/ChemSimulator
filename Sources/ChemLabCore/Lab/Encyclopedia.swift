/// A hazard note in a form that can be saved.
public struct StoredHazard: Codable, Sendable, Hashable {
    public let hazard: String
    public let reason: String

    public init(_ note: HazardNote) {
        self.hazard = note.hazard.rawValue
        self.reason = note.reason
    }

    public init(hazard: String, reason: String) {
        self.hazard = hazard
        self.reason = reason
    }

    /// Nil if a saved hazard kind no longer exists.
    public var note: HazardNote? {
        Hazard(rawValue: hazard).map { HazardNote($0, reason) }
    }
}

public struct DiscoveredSpecies: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    public let name: String
    public let formula: String
    /// `SpeciesGroup` raw value.
    public let group: String
    public let hazards: [StoredHazard]

    init(_ species: Species) {
        self.id = species.id
        self.name = species.name
        self.formula = species.displayFormula
        self.group = species.group.rawValue
        self.hazards = species.hazards.map(StoredHazard.init)
    }

    public var hazardNotes: [HazardNote] { hazards.compactMap(\.note) }
}

public struct DiscoveredReaction: Codable, Identifiable, Sendable, Hashable {
    public let id: String
    /// `Reaction.Kind` raw value.
    public let kind: String
    public let equation: String
    public let why: String
    public let hazards: [StoredHazard]
    /// Order of discovery, oldest first.
    public let sequence: Int

    init(_ reaction: Reaction, sequence: Int) {
        self.id = reaction.id
        self.kind = reaction.kind.rawValue
        self.equation = reaction.equation
        self.why = reaction.why
        self.hazards = reaction.allHazards.map(StoredHazard.init)
        self.sequence = sequence
    }

    public var kindTitle: String { Reaction.Kind(rawValue: kind)?.title ?? "Reaction" }
    public var hazardNotes: [HazardNote] { hazards.compactMap(\.note) }
}

/// Everything the learner has seen and done: substances, reactions and
/// challenges. Plain data, so the app can save it however it likes.
public struct Encyclopedia: Codable, Sendable, Equatable {
    public private(set) var species: [String: DiscoveredSpecies] = [:]
    public private(set) var reactions: [String: DiscoveredReaction] = [:]
    public private(set) var completedChallenges: Set<String> = []

    public init() {}

    /// Notes what is in the beaker and what has happened in it. Returns a short
    /// line for each new reaction or newly made substance, for a "you found
    /// something" message. Substances you only added are recorded silently.
    @discardableResult
    public mutating func record(_ beaker: Beaker) -> [String] {
        var news: [String] = []

        for event in beaker.events {
            let reaction = event.reaction
            if reactions[reaction.id] == nil {
                reactions[reaction.id] = DiscoveredReaction(reaction, sequence: reactions.count)
                news.append("New reaction: \(reaction.equation)")
            }
            for product in reaction.products where species[product.species.id] == nil {
                species[product.species.id] = DiscoveredSpecies(product.species)
                news.append("New substance: \(product.species.name)")
            }
        }
        for item in beaker.contents + beaker.gases where species[item.species.id] == nil {
            species[item.species.id] = DiscoveredSpecies(item.species)
        }
        return news
    }

    /// Marks a challenge done if the beaker meets its goal. Returns true the
    /// first time only.
    @discardableResult
    public mutating func complete(_ challenge: Challenge, in beaker: Beaker) -> Bool {
        guard !completedChallenges.contains(challenge.id), challenge.goal.isMet(by: beaker) else {
            return false
        }
        completedChallenges.insert(challenge.id)
        return true
    }

    public var speciesList: [DiscoveredSpecies] {
        species.values.sorted { $0.name < $1.name }
    }

    public var reactionList: [DiscoveredReaction] {
        reactions.values.sorted { $0.sequence < $1.sequence }
    }

    /// How many of the lab's library substances have been seen.
    public var libraryProgress: (found: Int, total: Int) {
        let known = Set(SpeciesCatalog.all.map(\.id))
        return (species.keys.filter { known.contains($0) }.count, known.count)
    }
}
