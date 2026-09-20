import Foundation
import Testing

@testable import ChemLabCore

private func stepFormulas(_ steps: [LabStep]) -> [String] {
    steps.compactMap { step in
        if case .put(let formula, _, _) = step { return formula }
        return nil
    }
}

@Suite("Challenges and experiments")
struct ChallengeTests {
    @Test func everyChallengeSolutionMeetsItsOwnGoal() {
        for challenge in ChallengeLibrary.all {
            var beaker = Beaker()
            beaker.run(challenge.solution)
            #expect(challenge.goal.isMet(by: beaker), "\(challenge.id): its own solution doesn't work")
        }
    }

    @Test func nothingIsCompleteBeforeAnythingHappens() {
        for challenge in ChallengeLibrary.all {
            #expect(!challenge.goal.isMet(by: Beaker()), "\(challenge.id) is met by an empty beaker")
        }
    }

    @Test func everyExperimentProducesWhatItSays() {
        for experiment in ExperimentLibrary.all {
            var beaker = Beaker()
            beaker.run(experiment.steps)
            #expect(experiment.expected.isMet(by: beaker), "\(experiment.id) doesn't produce what it claims")
        }
    }

    @Test func idsAreUniqueAndEveryFormulaExists() {
        let challengeIDs = ChallengeLibrary.all.map(\.id)
        #expect(Set(challengeIDs).count == challengeIDs.count)
        let experimentIDs = ExperimentLibrary.all.map(\.id)
        #expect(Set(experimentIDs).count == experimentIDs.count)

        let steps = ChallengeLibrary.all.flatMap(\.solution) + ExperimentLibrary.all.flatMap(\.steps)
        for formula in stepFormulas(steps) {
            #expect(SpeciesCatalog.species(formula: formula) != nil, "\(formula) is not in the lab")
        }
        for challenge in ChallengeLibrary.all {
            #expect(!challenge.hint.isEmpty && !challenge.learned.isEmpty)
        }
    }

    @Test func addingAToxicGasDirectlyDoesNotCountAsMakingOne() {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.species(formula: "Cl2")!, moles: 0.1)
        let challenge = ChallengeLibrary.all.first { $0.id == "toxic-gas" }!
        #expect(!challenge.goal.isMet(by: beaker))
    }

    @Test func addingHydrogenDirectlyDoesNotCountAsMakingHydrogen() {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.species(formula: "H2")!, moles: 0.1)
        let challenge = ChallengeLibrary.all.first { $0.id == "make-hydrogen" }!
        #expect(!challenge.goal.isMet(by: beaker))
    }

    @Test func stepsDescribeThemselves() {
        #expect(LabStep.put("Zn", moles: 0.05, strength: nil).text == "Add 0.05 mol of Zinc")
        #expect(LabStep.put("HNO3", moles: 0.4, strength: .asSold).text.contains("concentrated"))
        #expect(LabStep.flame.text.contains("flame"))
    }

    @Test func concentratedReagentsComeWithTheirWater() throws {
        let nitric = try #require(SpeciesCatalog.species(formula: "HNO3"))
        var concentrated = Beaker()
        concentrated.add(nitric, moles: 1, strength: .asSold)
        var dilute = Beaker()
        dilute.add(nitric, moles: 1, strength: .dilute)

        #expect(concentrated.molarity(ofID: nitric.id) >= Beaker.concentratedMolarity)
        #expect(dilute.molarity(ofID: nitric.id) < Beaker.concentratedMolarity)
        #expect(dilute.waterMoles > concentrated.waterMoles)
    }
}

@Suite("Encyclopedia")
struct EncyclopediaTests {
    private func volcano() -> Beaker {
        var beaker = Beaker()
        beaker.run(ExperimentLibrary.all.first { $0.id == "volcano" }!.steps)
        return beaker
    }

    @Test func recordsWhatHappenedAndReportsItOnce() {
        var book = Encyclopedia()
        let beaker = volcano()

        let first = book.record(beaker)
        #expect(first.contains { $0.contains("New reaction") })
        #expect(first.contains { $0.contains("Carbon dioxide") })
        #expect(book.speciesList.contains { $0.name == "Carbon dioxide" })
        #expect(book.reactionList.count == 1)

        #expect(book.record(beaker).isEmpty)
        #expect(book.reactionList.count == 1)
    }

    @Test func completingAChallengeCountsOnlyOnce() {
        var book = Encyclopedia()
        var beaker = Beaker()
        let challenge = ChallengeLibrary.all.first { $0.id == "fizz" }!

        #expect(!book.complete(challenge, in: beaker))
        beaker.run(challenge.solution)
        #expect(book.complete(challenge, in: beaker))
        #expect(!book.complete(challenge, in: beaker))
        #expect(book.completedChallenges == [challenge.id])
    }

    @Test func survivesBeingSavedAndLoaded() throws {
        var book = Encyclopedia()
        book.record(volcano())

        let data = try JSONEncoder().encode(book)
        let loaded = try JSONDecoder().decode(Encyclopedia.self, from: data)
        #expect(loaded == book)
        #expect(loaded.reactionList.count == 1)
    }

    @Test func savedHazardsComeBackAsRealNotes() {
        let note = HazardNote(.toxic, "Poison")
        let stored = StoredHazard(note)
        #expect(stored.note == note)
        #expect(StoredHazard(hazard: "made-up", reason: "x").note == nil)
    }

    @Test func libraryProgressCountsOnlyLibrarySubstances() {
        var book = Encyclopedia()
        #expect(book.libraryProgress.found == 0)
        book.record(volcano())
        #expect(book.libraryProgress.found > 0)
        #expect(book.libraryProgress.total == SpeciesCatalog.all.count)
    }
}
