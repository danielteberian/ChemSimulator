import ChemLabCore
import Foundation
import Testing

@testable import ChemLabUI

private func experiment(_ id: String) -> Experiment {
    ExperimentLibrary.all.first { $0.id == id }!
}

@MainActor
@Suite("LabModel")
struct LabModelTests {
    private func newModel() -> LabModel { LabModel(defaults: nil) }

    @Test func startsWithEmptyBeakers() {
        let lab = newModel()
        #expect(lab.beakers.count == LabModel.beakerCount)
        #expect(lab.beakers.allSatisfy(\.isEmpty))
        #expect(lab.selected == 0)
    }

    @Test func addingFromTheShelfGoesToTheSelectedBeaker() {
        let lab = newModel()
        lab.selected = 1
        lab.amountIndex = 1
        lab.add(SpeciesCatalog.water)

        #expect(lab.beakers[0].isEmpty)
        // The medium portion of water is 100 mL, which is about 5.5 mol.
        #expect(lab.beakers[1].waterMoles > 5)
    }

    @Test func acidsComeAsASolutionInTheChosenStrength() throws {
        let nitric = try #require(SpeciesCatalog.species(formula: "HNO3"))
        let lab = newModel()
        lab.strength = .asSold
        lab.add(nitric)
        let concentrated = lab.beaker.molarity(ofID: nitric.id)

        lab.emptySelected()
        lab.strength = .dilute
        lab.add(nitric)
        let dilute = lab.beaker.molarity(ofID: nitric.id)

        #expect(concentrated >= Beaker.concentratedMolarity)
        #expect(dilute < Beaker.concentratedMolarity)
    }

    @Test func pouringLeavesTheSolidBehind() {
        let lab = newModel()
        lab.load(experiment("silver-chloride"))
        lab.pour(from: 0, to: 1, fraction: 1)

        let agCl = SpeciesCatalog.species(formula: "AgCl")!.id
        #expect(lab.beakers[0].solids.contains { $0.species.id == agCl })
        #expect(!lab.beakers[1].solids.contains { $0.species.id == agCl })
        #expect(lab.beakers[1].waterMoles > 0)
    }

    @Test func pouringIntoTheSameBeakerDoesNothing() {
        let lab = newModel()
        lab.load(experiment("silver-chloride"))
        let before = lab.beakers[0].waterMoles
        lab.pour(from: 0, to: 0, fraction: 1)
        #expect(lab.beakers[0].waterMoles == before)
    }

    @Test func loadingAnExperimentRecordsWhatWasFound() {
        let lab = newModel()
        lab.load(experiment("volcano"))

        #expect(!lab.encyclopedia.reactionList.isEmpty)
        #expect(lab.messages.contains { $0.contains("New reaction") })
        #expect(lab.bubbleUntil[0] != nil)
    }

    @Test func finishingAChallengeIsRememberedAndExplained() throws {
        let lab = newModel()
        let challenge = try #require(ChallengeLibrary.all.first { $0.id == "fizz" })
        lab.showSolution(of: challenge)

        #expect(lab.encyclopedia.completedChallenges.contains("fizz"))
        #expect(lab.lastCompleted?.id == "fizz")
        #expect(lab.messages.contains { $0.contains("Challenge complete") })

        lab.dismissMessages()
        #expect(lab.messages.isEmpty)
        #expect(lab.lastCompleted == nil)
        #expect(lab.encyclopedia.completedChallenges.contains("fizz"))
    }

    @Test func progressIsSavedAndRestored() throws {
        let suite = "ChemLabTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let first = LabModel(defaults: defaults)
        first.load(experiment("volcano"))
        let count = first.encyclopedia.reactionList.count
        #expect(count > 0)

        let second = LabModel(defaults: defaults)
        #expect(second.encyclopedia.reactionList.count == count)

        second.resetProgress()
        let third = LabModel(defaults: defaults)
        #expect(third.encyclopedia.reactionList.isEmpty)
    }

    @Test func aNewBeakerStartsOpenAndEmptied() {
        let lab = newModel()
        lab.load(experiment("sugar-char"))  // this one covers the beaker
        #expect(!lab.beaker.openToAir)
        lab.emptySelected()
        #expect(lab.beaker.isEmpty)
        #expect(lab.beaker.openToAir)
    }

    @Test func theBurnerTogglesOnAndOff() {
        let lab = newModel()
        lab.toggleBurner()
        #expect(lab.burnerOn)
        lab.toggleBurner()
        #expect(!lab.burnerOn)
    }

    @Test func everySubstanceCanBeAddedWithEveryAmountAndStrength() {
        // The sandbox never refuses anything.
        let lab = newModel()
        for species in SpeciesCatalog.all {
            for strength in ReagentStrength.allCases {
                for amount in 0..<3 {
                    lab.emptySelected()
                    lab.strength = strength
                    lab.amountIndex = amount
                    lab.add(species)
                    #expect(!lab.beaker.isEmpty, "\(species.id) vanished when added")
                }
            }
        }
    }
}
