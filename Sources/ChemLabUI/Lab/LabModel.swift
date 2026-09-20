import ChemLabCore
import Foundation
import Observation

/// The lab bench: three beakers, what is selected on the shelf, and the
/// learner's progress. No views in here, so it can be tested on its own.
@MainActor @Observable
public final class LabModel {
    public static let beakerCount = 3
    private static let storageKey = "chemlab.encyclopedia.v1"
    private static let maxMessages = 6

    public private(set) var beakers: [Beaker]
    public var selected = 0
    public var group: SpeciesGroup = .acids
    public var strength: ReagentStrength = .asSold
    /// Index into the species' `amountChoices`.
    public var amountIndex = 1
    public private(set) var encyclopedia: Encyclopedia
    public private(set) var burnerOn = false
    /// Newest last: discoveries and finished challenges.
    public private(set) var messages: [String] = []
    /// The challenge finished most recently, for the "what you learned" card.
    public private(set) var lastCompleted: Challenge?
    /// Until when each beaker should show bubbles.
    public private(set) var bubbleUntil: [Int: Date] = [:]

    private var eventCounts: [Int]
    private var burnerTask: Task<Void, Never>?
    private let defaults: UserDefaults?

    /// `defaults` is where progress is saved; pass nil (as tests do) to keep it in memory only.
    public init(defaults: UserDefaults? = .standard) {
        self.defaults = defaults
        beakers = (1...Self.beakerCount).map { Beaker(name: "Beaker \($0)") }
        eventCounts = Array(repeating: 0, count: Self.beakerCount)
        if let data = defaults?.data(forKey: Self.storageKey),
            let saved = try? JSONDecoder().decode(Encyclopedia.self, from: data)
        {
            encyclopedia = saved
        } else {
            encyclopedia = Encyclopedia()
        }
    }

    public var beaker: Beaker { beakers[selected] }

    public var speciesOnShelf: [Species] { SpeciesCatalog.species(in: group) }

    // MARK: Adding

    /// Adds the chosen amount of a species to the selected beaker. Nothing is
    /// ever refused: dangerous combinations are allowed and labelled.
    public func add(_ species: Species) {
        let choices = species.amountChoices
        let choice = choices[min(max(amountIndex, 0), choices.count - 1)]
        let form: ReagentStrength? = species.hasSolutionForm ? strength : nil
        beakers[selected].add(species, moles: choice.moles, strength: form)
        afterChange(selected)
    }

    // MARK: Bench actions

    public func heatOnce() {
        beakers[selected].heat(kilojoules: 4)
        afterChange(selected)
    }

    public func toggleBurner() {
        burnerOn.toggle()
        burnerTask?.cancel()
        burnerTask = nil
        guard burnerOn else { return }
        burnerTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                self.beakers[self.selected].heat(kilojoules: 1.5)
                self.afterChange(self.selected)
                try? await Task.sleep(for: .milliseconds(250))
            }
        }
    }

    public func applyFlame() {
        beakers[selected].applyFlame()
        afterChange(selected)
    }

    public func stir() {
        beakers[selected].stir()
        afterChange(selected)
    }

    public func cool() {
        beakers[selected].cool()
        afterChange(selected)
    }

    public func ventilate() {
        beakers[selected].ventilate()
    }

    public func toggleAir() {
        beakers[selected].openToAir.toggle()
    }

    public func emptySelected() {
        beakers[selected].empty()
        eventCounts[selected] = 0
        bubbleUntil[selected] = nil
    }

    /// Pours from one beaker into another. Undissolved solids stay behind unless
    /// `includingSolids` is set, which is how you separate a precipitate.
    public func pour(from source: Int, to target: Int, fraction: Double, includingSolids: Bool = false) {
        guard source != target, beakers.indices.contains(source), beakers.indices.contains(target)
        else { return }
        let portion = beakers[source].pourOut(fraction: fraction, includingSolids: includingSolids)
        beakers[target].pourIn(portion)
        afterChange(source)
        afterChange(target)
    }

    // MARK: Scripted setups

    /// Clears the selected beaker and sets up an experiment in it.
    public func load(_ experiment: Experiment) {
        play(experiment.steps)
    }

    /// Plays a challenge's own solution, for "show me how".
    public func showSolution(of challenge: Challenge) {
        play(challenge.solution)
    }

    private func play(_ steps: [LabStep]) {
        emptySelected()
        beakers[selected].run(steps)
        afterChange(selected)
    }

    // MARK: Progress

    public func dismissMessages() {
        messages = []
        lastCompleted = nil
    }

    public func resetProgress() {
        encyclopedia = Encyclopedia()
        messages = []
        lastCompleted = nil
        save()
    }

    /// Records what happened in a beaker and checks the challenges.
    private func afterChange(_ index: Int) {
        let beaker = beakers[index]
        var notes = encyclopedia.record(beaker)
        for challenge in ChallengeLibrary.all {
            if encyclopedia.complete(challenge, in: beaker) {
                notes.append("Challenge complete: \(challenge.title)")
                lastCompleted = challenge
            }
        }
        if !notes.isEmpty {
            messages.append(contentsOf: notes)
            if messages.count > Self.maxMessages {
                messages.removeFirst(messages.count - Self.maxMessages)
            }
            save()
        }
        if beaker.events.count > eventCounts[index] {
            bubbleUntil[index] = Date().addingTimeInterval(3)
        }
        eventCounts[index] = beaker.events.count
    }

    private func save() {
        guard let defaults, let data = try? JSONEncoder().encode(encyclopedia) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
