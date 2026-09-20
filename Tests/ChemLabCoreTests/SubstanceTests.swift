import Testing

@testable import ChemLabCore

@Suite("Structure parser")
struct StructureParserTests {
    @Test func chainsBranchesAndBondOrders() throws {
        let carbonicAcid = try StructureParser.parse("O=C(-O-H)-O-H")
        #expect(carbonicAcid.atoms.count == 6)
        #expect(carbonicAcid.bonds.count == 5)
        #expect(carbonicAcid.isComplete)
        #expect(Formula(carbonicAcid).hill == "CH2O3")

        let co2 = try StructureParser.parse("O=C=O")
        #expect(co2.isComplete)
        #expect(co2.bonds.allSatisfy { $0.order == 2 })
    }

    @Test func omittedBondSymbolMeansSingleBond() throws {
        let water = try StructureParser.parse("HOH")
        #expect(water.bonds.count == 2)
        #expect(water.isComplete)
    }

    @Test func ringDigitClosesBackToOpeningAtom() throws {
        let m = try StructureParser.parse("Cu1-O-S(=O)(=O)-O1")
        #expect(m.atoms.count == 6)
        #expect(m.bonds.count == 6)
        #expect(m.isComplete)
    }

    @Test func bracketedAtomsCarryFormalCharge() throws {
        let m = try StructureParser.parse("[N+](-H)(-H)(-H)-H")
        #expect(m.atoms.first?.formalCharge == 1)
        let anion = try StructureParser.parse("[O-]")
        #expect(anion.atoms.first?.formalCharge == -1)
        let doubly = try StructureParser.parse("[Ca+2]")
        #expect(doubly.atoms.first?.formalCharge == 2)
    }

    @Test func ignoresWhitespace() throws {
        #expect(try StructureParser.parse("H - O - H").bonds.count == 2)
    }

    @Test func reportsErrors() {
        #expect(throws: StructureParseError.unknownElement("Xx")) { try StructureParser.parse("Xx-H") }
        #expect(throws: StructureParseError.unclosedBranch) { try StructureParser.parse("C(-H") }
        #expect(throws: StructureParseError.unclosedRing(1)) { try StructureParser.parse("C1-C") }
        #expect(throws: StructureParseError.unclosedBracket) { try StructureParser.parse("[N+") }
        #expect(throws: StructureParseError.unexpectedCharacter(")", position: 1)) {
            try StructureParser.parse("C)")
        }
        #expect(throws: StructureParseError.unexpectedCharacter("1", position: 0)) {
            try StructureParser.parse("1C")
        }
        #expect(throws: StructureParseError.unexpectedCharacter("(", position: 0)) {
            try StructureParser.parse("(C)")
        }
    }
}

@Suite("Formal charges")
struct FormalChargeTests {
    @Test func nitricAcidIsCompleteNeutralAndNamed() throws {
        let m = try StructureParser.parse("H-O-[N+](=O)-[O-]")
        #expect(m.netCharge == 0)
        #expect(m.isComplete)
        #expect(Naming.identify(m)?.displayName == "Nitric acid")
    }

    @Test func carbonMonoxideNeedsChargesOnBothEnds() throws {
        let m = try StructureParser.parse("[C-]#[O+]")
        #expect(m.isComplete)
        #expect(Naming.identify(m)?.displayName == "Carbon monoxide")
    }

    @Test func ammoniumIsCompleteButChargedSpeciesAreNotNamedYet() throws {
        let m = try StructureParser.parse("[N+](-H)(-H)(-H)-H")
        #expect(m.isComplete)
        #expect(m.netCharge == 1)
        #expect(Naming.identify(m) == nil)
    }

    @Test func chargedAtomsUseTheirIsoelectronicElementsValence() throws {
        // O- has fluorine's electron count, so it takes one bond, not two.
        let tooMany = try StructureParser.parse("H-[O-]-H")
        #expect(tooMany.valenceState(of: 1) == .overValent)
        let fine = try StructureParser.parse("H-[O-]")
        #expect(fine.valenceState(of: 1) == .satisfied)
    }

    @Test func bareIonsTakeNoBonds() throws {
        let sodiumIon = try StructureParser.parse("[Na+]")
        #expect(sodiumIon.valenceState(of: 0) == .satisfied)
        let bonded = try StructureParser.parse("[Na+]-Cl")
        #expect(bonded.valenceState(of: 0) == .overValent)
    }

    @Test func chargeLabels() {
        let labels = [0, 1, -1, 2, -3].map { charge -> String in
            var m = Molecule()
            m.addAtom(PeriodicTable.element(symbol: "N")!, formalCharge: charge)
            return m.atoms[0].chargeLabel
        }
        #expect(labels == ["", "+", "\u{2212}", "2+", "3\u{2212}"])
    }

    @Test func insertCopiesAtomsBondsAndCharges() throws {
        let nitrate = try StructureParser.parse("H-O-[N+](=O)-[O-]")
        var target = try StructureParser.parse("H-H")
        let mapping = target.insert(nitrate)
        #expect(mapping.count == 5)
        #expect(target.atoms.count == 7)
        #expect(target.bonds.count == 1 + nitrate.bonds.count)
        #expect(target.netCharge == 0)
        #expect(target.connectedComponents().count == 2)
    }
}

@Suite("Substance library")
struct SubstanceLibraryTests {
    @Test func everySubstanceIsCompleteNeutralAndNamed() {
        for substance in SubstanceLibrary.all {
            let molecule = substance.makeMolecule()
            #expect(molecule.isComplete, "\(substance.structure) is not complete")
            #expect(molecule.netCharge == 0, "\(substance.structure) is charged")
            #expect(substance.identification != nil, "\(substance.structure) has no name")
        }
    }

    @Test func everySubstanceIsInTheCatalogOrNamedByRules() {
        // Anything with more than two elements can't be named by the generator.
        for substance in SubstanceLibrary.all where substance.formula.counts.count > 2 {
            #expect(
                substance.identification?.isCatalogued == true,
                "\(substance.structure) needs a catalog entry")
        }
    }

    @Test func idsAreUniqueAndGroupsAreFilled() {
        let ids = SubstanceLibrary.all.map(\.id)
        #expect(Set(ids).count == ids.count)
        for group in CommonSubstance.Group.allCases {
            #expect(!SubstanceLibrary.substances(in: group).isEmpty)
        }
    }

    @Test func containsTheCommonOnes() {
        func names(_ group: CommonSubstance.Group) -> [String] {
            SubstanceLibrary.substances(in: group).map(\.name)
        }
        let acids = names(.acid)
        #expect(acids.contains("Nitric acid"))
        #expect(acids.contains("Sulfuric acid"))
        #expect(acids.contains("Acetic acid"))
        let bases = names(.base)
        #expect(bases.contains("Sodium hydroxide"))
        #expect(bases.contains("Ammonia"))
        let salts = names(.salt)
        #expect(salts.contains("Table salt"))
        #expect(salts.contains("Silver nitrate"))
    }

    @Test func displayFormulasReadTheWayPeopleWriteThem() {
        func formula(_ name: String) -> String? {
            SubstanceLibrary.all.first { $0.name == name }?.displayFormula
        }
        #expect(formula("Sulfuric acid") == "H₂SO₄")
        #expect(formula("Table salt") == "NaCl")
        #expect(formula("Formic acid") == "HCOOH")
        #expect(formula("Slaked lime") == "Ca(OH)₂")
    }

    @Test func hazardsComeFromTheCatalog() {
        func hazards(_ name: String) -> [Hazard] {
            SubstanceLibrary.all.first { $0.name == name }?.hazards ?? []
        }
        #expect(hazards("Nitric acid").contains(.corrosive))
        #expect(hazards("Nitric acid").contains(.oxidizer))
        #expect(hazards("Sodium hypochlorite").contains(.toxic))
        #expect(hazards("Table salt").isEmpty)
        let sulfuric = hazards("Sulfuric acid")
        #expect(Set(sulfuric).count == sulfuric.count)
    }

    @Test func gasesOxidesAndOrganicsArePresent() {
        func names(_ group: CommonSubstance.Group) -> [String] {
            SubstanceLibrary.substances(in: group).map(\.name)
        }
        #expect(names(.gas).contains("Carbon dioxide"))
        #expect(names(.gas).contains("Carbon monoxide"))
        #expect(names(.gas).contains("Methane"))
        #expect(names(.oxide).contains("Water"))
        #expect(names(.oxide).contains("Rust"))
        #expect(names(.organic).contains("Ethanol"))
    }

    @Test func subscriptedHandlesParenthesesAndPlainText() {
        #expect(Formula.subscripted("Ca(OH)2") == "Ca(OH)₂")
        #expect(Formula.subscripted("NaCl") == "NaCl")
    }
}
