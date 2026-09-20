import Testing

@testable import ChemLabCore

private func labSpecies(_ formula: String) -> Species {
    guard let species = SpeciesCatalog.species(formula: formula) else {
        preconditionFailure("No species \(formula)")
    }
    return species
}

private func labAmount(_ beaker: Beaker, _ formula: String, _ state: MatterState) -> Double {
    let id = labSpecies(formula).id
    return beaker.contents
        .filter { $0.species.id == id && $0.state == state }
        .reduce(0.0) { $0 + $1.moles }
}

private func labGas(_ beaker: Beaker, _ formula: String) -> Double {
    let id = labSpecies(formula).id
    return beaker.gases.filter { $0.species.id == id }.reduce(0.0) { $0 + $1.moles }
}

@Suite("Lab: acids, bases and salts")
struct WetChemistryTests {
    @Test func zincInAcidMakesHydrogen() {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.water, moles: 5)
        beaker.add(labSpecies("HCl"), moles: 0.1)
        beaker.add(labSpecies("Zn"), moles: 0.05)

        #expect(labGas(beaker, "H2") > 0.04)
        #expect(labAmount(beaker, "ZnCl2", .aqueous) > 0.04)
        #expect(labAmount(beaker, "Zn", .solid) < 1e-6)
        #expect(beaker.activeHazardKinds.contains(.explosive))
        #expect(beaker.events.count == 1)
    }

    @Test func copperDoesNotReactWithDiluteAcid() {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.water, moles: 5)
        beaker.add(labSpecies("HCl"), moles: 0.1)
        beaker.add(labSpecies("Cu"), moles: 0.05)
        #expect(beaker.events.isEmpty)
        #expect(labAmount(beaker, "Cu", .solid) == 0.05)
    }

    @Test func neutralizingAcidWithBaseGivesNeutralSaltWater() throws {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.water, moles: 5)
        beaker.add(labSpecies("HCl"), moles: 0.1)
        let acidic = try #require(beaker.pH)
        beaker.add(labSpecies("NaOH"), moles: 0.1)
        let neutral = try #require(beaker.pH)

        #expect(acidic < 1)
        #expect(neutral > 6.5 && neutral < 7.5)
        #expect(labAmount(beaker, "NaCl", .aqueous) > 0.09)
    }

    @Test func lyeIsStronglyBasic() throws {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.water, moles: 5.5)
        beaker.add(labSpecies("NaOH"), moles: 0.1)
        #expect(try #require(beaker.pH) > 13)
        // Dissolving lye gives off heat.
        #expect(beaker.temperature > Beaker.roomTemperature)
    }

    @Test func mixingSilverNitrateAndSaltMakesAPrecipitate() {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.water, moles: 5)
        beaker.add(labSpecies("AgNO3"), moles: 0.05)
        beaker.add(labSpecies("NaCl"), moles: 0.05)

        #expect(labAmount(beaker, "AgCl", .solid) > 0.04)
        #expect(labAmount(beaker, "NaNO3", .aqueous) > 0.04)
        #expect(beaker.solids.contains { $0.species.id == labSpecies("AgCl").id })
    }

    @Test func leadNitrateAndIodideMakeYellowToxicSolid() {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.water, moles: 10)
        beaker.add(labSpecies("Pb(NO3)2"), moles: 0.01)
        beaker.add(labSpecies("KI"), moles: 0.02)

        #expect(labAmount(beaker, "PbI2", .solid) > 0.009)
        #expect(beaker.activeHazardKinds.contains(.toxic))
    }

    @Test func drySaltsDoNotReactUntilWaterIsAdded() {
        var beaker = Beaker()
        beaker.add(labSpecies("AgNO3"), moles: 0.05)
        beaker.add(labSpecies("NaCl"), moles: 0.05)
        #expect(beaker.events.isEmpty)

        beaker.add(SpeciesCatalog.water, moles: 3)
        #expect(!beaker.events.isEmpty)
        #expect(labAmount(beaker, "AgCl", .solid) > 0.04)
    }

    @Test func zincDisplacesCopperAndTheBlueFades() throws {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.water, moles: 5)
        beaker.add(labSpecies("CuSO4"), moles: 0.05)
        let before = try #require(beaker.liquidColor)
        beaker.add(labSpecies("Zn"), moles: 0.05)
        let after = try #require(beaker.liquidColor)

        #expect(labAmount(beaker, "Cu", .solid) > 0.04)
        #expect(labAmount(beaker, "ZnSO4", .aqueous) > 0.04)
        // Copper ions tint the water blue (less red); without them it is clear again.
        #expect(after.red > before.red)
    }

    @Test func acidOnBakingSodaFizzes() {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.water, moles: 5)
        beaker.add(labSpecies("NaHCO3"), moles: 0.05)
        let vinegar = labSpecies("CH3COOH")
        beaker.add(vinegar, moles: 0.05, water: 0.05 * (vinegar.solutionWaterPerMole(.dilute) ?? 0))
        #expect(labGas(beaker, "CO2") > 0.04)
    }

    @Test func ammoniumSaltWithLyeReleasesAmmonia() {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.water, moles: 5)
        beaker.add(labSpecies("NH4Cl"), moles: 0.05)
        beaker.add(labSpecies("NaOH"), moles: 0.05)
        #expect(labGas(beaker, "NH3") > 0.04)
        #expect(beaker.activeHazardKinds.contains(.toxic))
    }

    @Test func pouringOffLeavesThePrecipitateBehind() {
        var source = Beaker()
        source.add(SpeciesCatalog.water, moles: 5)
        source.add(labSpecies("AgNO3"), moles: 0.05)
        source.add(labSpecies("NaCl"), moles: 0.05)

        var target = Beaker()
        target.pourIn(source.pourOut(fraction: 1))

        #expect(labAmount(source, "AgCl", .solid) > 0.04)
        #expect(labAmount(target, "AgCl", .solid) < 1e-9)
        #expect(labAmount(target, "NaNO3", .aqueous) > 0.04)
    }
}

@Suite("Lab: the dangerous ones")
struct HazardousReactionTests {
    @Test func concentratedNitricAcidOnCopperMakesToxicBrownGas() {
        let nitric = labSpecies("HNO3")
        let water = 0.4 * (nitric.solutionWaterPerMole(.asSold) ?? 0)
        var beaker = Beaker()
        beaker.add(nitric, moles: 0.4, water: water)
        beaker.add(labSpecies("Cu"), moles: 0.1)

        #expect(labGas(beaker, "NO2") > 0.15)
        #expect(labAmount(beaker, "Cu", .solid) < 1e-6)
        #expect(beaker.activeHazardKinds.contains(.toxic))
    }

    @Test func diluteNitricAcidGivesColorlessNitricOxideInstead() {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.water, moles: 5)
        beaker.add(labSpecies("HNO3"), moles: 0.1)
        beaker.add(labSpecies("Cu"), moles: 0.03)

        #expect(labGas(beaker, "NO") > 0.015)
        #expect(labGas(beaker, "NO2") == 0)
    }

    @Test func lyeAndAluminumMakeExplosiveHydrogen() {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.water, moles: 5)
        beaker.add(labSpecies("NaOH"), moles: 0.1)
        beaker.add(labSpecies("Al"), moles: 0.1)

        #expect(labGas(beaker, "H2") > 0.07)
        #expect(beaker.activeHazardKinds.contains(.explosive))
        #expect(beaker.activeHazardKinds.contains(.corrosive))
    }

    @Test func sodiumInWaterIsViolent() {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.water, moles: 2)
        beaker.add(labSpecies("Na"), moles: 0.05)

        #expect(labGas(beaker, "H2") > 0.02)
        #expect(labAmount(beaker, "NaOH", .aqueous) > 0.04)
        #expect(beaker.activeHazardKinds.contains(.explosive))
    }

    @Test func bleachPlusAcidReleasesChlorine() {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.water, moles: 5)
        beaker.add(labSpecies("NaClO"), moles: 0.05)
        beaker.add(labSpecies("HCl"), moles: 0.1)

        #expect(labGas(beaker, "Cl2") > 0.04)
        #expect(beaker.activeHazardKinds.contains(.toxic))
    }

    @Test func hydrogenNeedsASparkThenBurns() {
        var beaker = Beaker()
        beaker.add(labSpecies("H2"), moles: 0.1)
        #expect(beaker.events.isEmpty)

        beaker.applyFlame()
        #expect(labGas(beaker, "H2") < 1e-9)
        #expect(beaker.activeHazardKinds.contains(.explosive))
    }

    @Test func magnesiumBurnsOnlyOnceLit() {
        var beaker = Beaker()
        beaker.add(labSpecies("Mg"), moles: 0.1)
        #expect(beaker.events.isEmpty)

        beaker.applyFlame()
        #expect(labAmount(beaker, "MgO", .solid) > 0.09)
        #expect(beaker.activeHazardKinds.contains(.flammable))
    }

    @Test func closingTheBeakerStarvesTheFlame() {
        var beaker = Beaker()
        beaker.openToAir = false
        beaker.add(labSpecies("Mg"), moles: 0.1)
        beaker.applyFlame()
        #expect(labAmount(beaker, "Mg", .solid) == 0.1)
    }

    @Test func thermiteNeedsALotOfHeat() {
        var beaker = Beaker()
        beaker.add(labSpecies("Al"), moles: 0.1)
        beaker.add(labSpecies("Fe2O3"), moles: 0.05)
        #expect(beaker.events.isEmpty)

        beaker.applyFlame()
        #expect(labAmount(beaker, "Fe", .solid) + labAmount(beaker, "Fe", .liquid) > 0.09)
        #expect(beaker.activeHazardKinds.contains(.explosive))
    }

    @Test func anythingCanBeAddedToAnythingWithoutBlocking() {
        // The sandbox never refuses; the engine just has to stay finite and sane.
        for species in SpeciesCatalog.all {
            var beaker = Beaker()
            beaker.add(SpeciesCatalog.water, moles: 2)
            beaker.add(species, moles: 0.01)
            #expect(!beaker.observations.isEmpty, "\(species.id) was not added")
        }

        var everything = Beaker()
        for species in SpeciesCatalog.all { everything.add(species, moles: 0.01) }
        #expect(!everything.isEmpty)
        #expect(everything.events.count <= Beaker.maxEvents)
    }
}

@Suite("Lab: heat")
struct HeatTests {
    @Test func limestoneDecomposesOnlyWhenVeryHot() {
        var beaker = Beaker()
        beaker.add(labSpecies("CaCO3"), moles: 0.1)
        beaker.heat(kilojoules: 5)
        #expect(labAmount(beaker, "CaCO3", .solid) == 0.1)

        for _ in 0..<40 { beaker.heat(kilojoules: 5) }
        #expect(labAmount(beaker, "CaO", .solid) > 0.09)
        #expect(labGas(beaker, "CO2") > 0.09)
    }

    @Test func waterHoldsAtTheBoilingPointWhileItBoilsAway() {
        var beaker = Beaker()
        beaker.add(SpeciesCatalog.water, moles: 1)
        for _ in 0..<3 { beaker.heat(kilojoules: 10) }

        #expect(abs(beaker.temperature - 100) < 0.01)
        #expect(beaker.waterMoles > 0)
        #expect(beaker.waterMoles < 1)
    }

    @Test func heatedSugarChars() {
        var beaker = Beaker()
        // Closed, so the char can't burn away in the air once it is hot enough.
        beaker.openToAir = false
        beaker.add(labSpecies("C12H22O11"), moles: 0.01)
        for _ in 0..<20 { beaker.heat(kilojoules: 1) }
        #expect(labAmount(beaker, "C", .solid) > 0.1)
    }

    @Test func copperNitrateGivesOffToxicGasWhenHeated() {
        var beaker = Beaker()
        beaker.add(labSpecies("Cu(NO3)2"), moles: 0.05)
        for _ in 0..<20 { beaker.heat(kilojoules: 2) }
        #expect(labGas(beaker, "NO2") > 0.05)
        #expect(beaker.activeHazardKinds.contains(.toxic))
    }

    @Test func ventilatingClearsGas() {
        var beaker = Beaker()
        beaker.add(labSpecies("Cl2"), moles: 0.1)
        #expect(labGas(beaker, "Cl2") == 0.1)
        beaker.ventilate()
        #expect(beaker.gases.isEmpty)
    }
}
