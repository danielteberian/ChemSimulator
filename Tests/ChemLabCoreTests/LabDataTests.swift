import Testing

@testable import ChemLabCore

@Suite("Equation balancer")
struct EquationBalancerTests {
    private func formulas(_ texts: [String]) -> [Formula] {
        texts.compactMap { Formula(parsing: $0) }
    }

    @Test func balancesSimpleEquations() {
        #expect(EquationBalancer.balance(reactants: formulas(["H2", "O2"]), products: formulas(["H2O"])) == [2, 1, 2])
        #expect(EquationBalancer.balance(reactants: formulas(["Al", "O2"]), products: formulas(["Al2O3"])) == [4, 3, 2])
        #expect(
            EquationBalancer.balance(
                reactants: formulas(["C6H12O6", "O2"]), products: formulas(["CO2", "H2O"])) == [1, 6, 6, 6])
    }

    @Test func balancesEquationsWithParentheses() {
        let result = EquationBalancer.balance(
            reactants: formulas(["Al", "CuSO4"]), products: formulas(["Al2(SO4)3", "Cu"]))
        #expect(result == [2, 3, 1, 3])
    }

    @Test func refusesImpossibleOrAmbiguousEquations() {
        // Nothing to turn hydrogen into oxygen.
        #expect(EquationBalancer.balance(reactants: formulas(["H2"]), products: formulas(["O2"])) == nil)
        // Two independent ways to balance it.
        #expect(
            EquationBalancer.balance(
                reactants: formulas(["H2", "O2"]), products: formulas(["H2O", "H2O2"])) == nil)
        #expect(EquationBalancer.balance(reactants: [], products: formulas(["H2O"])) == nil)
    }

    @Test func checksGivenCoefficients() throws {
        let h2 = try #require(Formula(parsing: "H2"))
        let o2 = try #require(Formula(parsing: "O2"))
        let water = try #require(Formula(parsing: "H2O"))
        #expect(EquationBalancer.isBalanced(reactants: [(h2, 2), (o2, 1)], products: [(water, 2)]))
        #expect(!EquationBalancer.isBalanced(reactants: [(h2, 1), (o2, 1)], products: [(water, 1)]))
    }
}

@Suite("Ions and solubility")
struct IonTests {
    private func cation(_ symbol: String, _ charge: Int) throws -> Ion {
        try #require(IonCatalog.cation(symbol, charge: charge))
    }

    private func anion(_ symbol: String, _ charge: Int) throws -> Ion {
        try #require(IonCatalog.anion(symbol, charge: charge))
    }

    @Test func saltFormulasCancelTheCharges() throws {
        #expect(IonCatalog.saltFormula(cation: try cation("Na", 1), anion: try anion("Cl", -1)) == "NaCl")
        #expect(IonCatalog.saltFormula(cation: try cation("Ca", 2), anion: try anion("OH", -1)) == "Ca(OH)2")
        #expect(IonCatalog.saltFormula(cation: try cation("Al", 3), anion: try anion("SO4", -2)) == "Al2(SO4)3")
        #expect(IonCatalog.saltFormula(cation: try cation("NH4", 1), anion: try anion("SO4", -2)) == "(NH4)2SO4")
        #expect(IonCatalog.saltFormula(cation: try cation("Fe", 3), anion: try anion("Cl", -1)) == "FeCl3")
        #expect(IonCatalog.saltFormula(cation: try cation("Mg", 2), anion: try anion("SO4", -2)) == "MgSO4")
    }

    @Test func ionsDisplayWithSubscriptsAndSuperscripts() throws {
        #expect(try cation("Na", 1).display == "Na⁺")
        #expect(try anion("SO4", -2).display == "SO₄²⁻")
        #expect(try cation("Fe", 3).display == "Fe³⁺")
    }

    @Test func textbookSolubilityRules() throws {
        func soluble(_ c: (String, Int), _ a: (String, Int)) throws -> Solubility {
            SolubilityRules.solubility(cation: try cation(c.0, c.1), anion: try anion(a.0, a.1))
        }
        #expect(try soluble(("Na", 1), ("Cl", -1)) == .soluble)
        #expect(try soluble(("Ag", 1), ("Cl", -1)) == .insoluble)
        #expect(try soluble(("Pb", 2), ("I", -1)) == .insoluble)
        #expect(try soluble(("Ba", 2), ("SO4", -2)) == .insoluble)
        #expect(try soluble(("Cu", 2), ("SO4", -2)) == .soluble)
        #expect(try soluble(("Ag", 1), ("NO3", -1)) == .soluble)
        #expect(try soluble(("Cu", 2), ("OH", -1)) == .insoluble)
        #expect(try soluble(("Na", 1), ("OH", -1)) == .soluble)
        #expect(try soluble(("Ca", 2), ("CO3", -2)) == .insoluble)
        #expect(try soluble(("K", 1), ("CO3", -2)) == .soluble)
        #expect(try soluble(("Ca", 2), ("OH", -1)).precipitates)
    }
}

@Suite("Species and reaction data")
struct LabDataTests {
    @Test func speciesIDsAreUniqueAndMatchTheirFormulas() {
        let ids = SpeciesCatalog.all.map(\.id)
        #expect(Set(ids).count == ids.count, "duplicate species id")
        for species in SpeciesCatalog.all {
            #expect(species.id == species.formula.hill)
            #expect(!species.name.isEmpty)
            #expect(species.molarMass > 0, "\(species.id) has no molar mass")
        }
    }

    @Test func everySaltIsElectricallyNeutral() {
        for species in SpeciesCatalog.all {
            guard case .salt(let cation, let anion) = species.role else { continue }
            let ratio = IonCatalog.ratio(cation: cation, anion: anion)
            #expect(
                ratio.cations * cation.charge + ratio.anions * anion.charge == 0,
                "\(species.id) is not neutral")
        }
    }

    @Test func everyBaseHasItsHydroxideCount() {
        for species in SpeciesCatalog.all {
            guard case .base(let cation, _) = species.role else { continue }
            #expect(
                species.formula.counts["O"] == abs(cation.charge),
                "\(species.id) should have \(abs(cation.charge)) hydroxides")
        }
    }

    @Test func everyHandWrittenReactionIsBalanced() {
        for reaction in ReactionTable.explicit {
            #expect(reaction.isBalanced, "\(reaction.equation) is not balanced")
            #expect(!reaction.why.isEmpty)
        }
        let ids = ReactionTable.explicit.map(\.id)
        #expect(Set(ids).count == ids.count, "duplicate reaction")
    }

    @Test func everyGeneratedReactionIsBalanced() {
        let generated = ReactionGenerator.reactions(among: SpeciesCatalog.all)
        #expect(!generated.isEmpty)
        for reaction in generated {
            #expect(reaction.isBalanced, "\(reaction.equation) is not balanced")
        }
    }

    @Test func reactionsCanBeWrittenAsText() {
        let reaction = Reaction.parse("2 H2 + O2 -> 2 H2O", .combustion, why: "test")
        #expect(reaction?.isBalanced == true)
        #expect(reaction?.equation == "2 H₂ + O₂ → 2 H₂O")
        #expect(Reaction.parse("H2 + Xx -> H2O", .other, why: "test") == nil)
        #expect(Reaction.parse("H2 + O2", .other, why: "test") == nil)
        let unbalanced = Reaction.parse("H2 + O2 -> H2O", .combustion, why: "test")
        #expect(unbalanced?.isBalanced == false)
    }

    @Test func activitySeriesOrdersMetals() {
        #expect(ActivitySeries.displacesHydrogen("Zn"))
        #expect(!ActivitySeries.displacesHydrogen("Cu"))
        #expect(ActivitySeries.displaces("Zn", "Cu"))
        #expect(!ActivitySeries.displaces("Cu", "Zn"))
        #expect(!ActivitySeries.displaces("Zn", "Zn"))
    }

    @Test func dangerousThingsCarryHazardNotes() {
        func hazards(_ formula: String) -> [Hazard] {
            SpeciesCatalog.species(formula: formula)?.hazards.map(\.hazard) ?? []
        }
        #expect(hazards("Na").contains(.waterReactive))
        #expect(hazards("NO2").contains(.toxic))
        #expect(hazards("HNO3").contains(.corrosive))
        #expect(hazards("Pb(NO3)2").contains(.toxic))
        #expect(hazards("NaCl").isEmpty)
    }
}
