import Testing
@testable import ChemLabCore

private func el(_ symbol: String) -> Element { PeriodicTable.element(symbol: symbol)! }

/// Builds a molecule from atoms and single bonds given as index pairs.
private func molecule(_ symbols: [String], bonds: [(Int, Int, Int)]) throws -> Molecule {
    var m = Molecule()
    let ids = symbols.map { m.addAtom(el($0)) }
    for (a, b, order) in bonds { try m.addBond(ids[a], ids[b], order: order) }
    return m
}

@Suite("Periodic table")
struct PeriodicTableTests {
    @Test func hasAll118InOrder() {
        #expect(PeriodicTable.all.count == 118)
        for (i, e) in PeriodicTable.all.enumerated() { #expect(e.number == i + 1) }
    }

    @Test func symbolsAreUnique() {
        #expect(Set(PeriodicTable.all.map(\.symbol)).count == 118)
    }

    @Test func gridPositionsAreUniqueAndInBounds() {
        let positions = PeriodicTable.all.map { PeriodicTable.gridPosition(of: $0) }
        #expect(Set(positions).count == 118)
        for p in positions {
            #expect((1...PeriodicTable.gridRows).contains(p.row))
            #expect((1...PeriodicTable.gridColumns).contains(p.column))
        }
    }

    @Test func gridPositionsMatchKnownLandmarks() {
        func pos(_ s: String) -> PeriodicTable.GridPosition {
            PeriodicTable.gridPosition(of: el(s))
        }
        #expect(pos("H") == .init(row: 1, column: 1))
        #expect(pos("He") == .init(row: 1, column: 18))
        #expect(pos("Na") == .init(row: 3, column: 1))
        #expect(pos("Fe") == .init(row: 4, column: 8))
        #expect(pos("Ne") == .init(row: 2, column: 18))
        #expect(pos("Hf") == .init(row: 6, column: 4))
        #expect(pos("Og") == .init(row: 7, column: 18))
        #expect(pos("La") == .init(row: 9, column: 3))
        #expect(pos("Lu") == .init(row: 9, column: 17))
        #expect(pos("Lr") == .init(row: 10, column: 17))
    }

    @Test func lookup() {
        #expect(PeriodicTable.element(symbol: "Fe")?.name == "Iron")
        #expect(PeriodicTable.element(number: 79)?.symbol == "Au")
        #expect(PeriodicTable.element(symbol: "Xx") == nil)
        #expect(PeriodicTable.element(number: 0) == nil)
        #expect(PeriodicTable.element(number: 119) == nil)
    }
}

@Suite("Formula")
struct FormulaTests {
    @Test func hillOrder() {
        #expect(Formula(parsing: "OH2")?.hill == "H2O")
        #expect(Formula(parsing: "C6H12O6")?.hill == "C6H12O6")
        #expect(Formula(parsing: "H6OC2")?.hill == "C2H6O")
        #expect(Formula(parsing: "NaCl")?.hill == "ClNa")
    }

    @Test func parenthesesAndDisplay() {
        #expect(Formula(parsing: "Ca(OH)2")?.hill == "CaH2O2")
        #expect(Formula(parsing: "Cu(NO3)2")?.counts["O"] == 6)
        #expect(Formula(parsing: "H2O")?.display == "H₂O")
    }

    @Test func rejectsBadInput() {
        #expect(Formula(parsing: "") == nil)
        #expect(Formula(parsing: "Xx2") == nil)
        #expect(Formula(parsing: "H2)") == nil)
        #expect(Formula(parsing: "(H2") == nil)
        #expect(Formula(parsing: "h2o") == nil)
    }

    @Test func molarMassOfWater() {
        let mass = Formula(parsing: "H2O")!.molarMass
        #expect(abs(mass - 18.015) < 0.01)
    }
}

@Suite("Molecule")
struct MoleculeTests {
    @Test func waterIsComplete() throws {
        let water = try molecule(["O", "H", "H"], bonds: [(0, 1, 1), (0, 2, 1)])
        #expect(water.isComplete)
        #expect(Formula(water).hill == "H2O")
    }

    @Test func partialMoleculeIsOpen() throws {
        let m = try molecule(["O", "H"], bonds: [(0, 1, 1)])
        #expect(!m.isComplete)
        #expect(m.valenceState(of: 0) == .open)
    }

    @Test func overValentDetected() throws {
        let m = try molecule(
            ["H", "H", "H"], bonds: [(0, 1, 1), (0, 2, 1)])
        #expect(m.valenceState(of: 0) == .overValent)
        #expect(m.hasOverValentAtom)
        #expect(!m.isComplete)
    }

    @Test func loneMetalAtomIsTheElement() throws {
        var m = Molecule()
        m.addAtom(el("Fe"))
        #expect(m.isComplete)
        #expect(Naming.identify(m)?.displayName == "Iron")
        var h = Molecule()
        h.addAtom(el("H"))
        #expect(!h.isComplete)
    }

    @Test func doubleBondsCountByOrder() throws {
        let co2 = try molecule(["C", "O", "O"], bonds: [(0, 1, 2), (0, 2, 2)])
        #expect(co2.isComplete)
    }

    @Test func disconnectedPiecesAreNotOneMolecule() throws {
        var m = try molecule(["H", "H"], bonds: [(0, 1, 1)])
        m.addAtom(el("He"))
        #expect(m.connectedComponents().count == 2)
        #expect(!m.isComplete)
    }

    @Test func bondErrors() {
        var m = Molecule()
        let a = m.addAtom(el("H"))
        let b = m.addAtom(el("H"))
        #expect(throws: BondError.sameAtom) { try m.addBond(a, a) }
        #expect(throws: BondError.unknownAtom) { try m.addBond(a, 99) }
        #expect(throws: BondError.invalidOrder) { try m.addBond(a, b, order: 4) }
    }

    @Test func rebondingReplacesOrder() throws {
        var m = Molecule()
        let a = m.addAtom(el("C"))
        let b = m.addAtom(el("C"))
        try m.addBond(a, b, order: 1)
        try m.addBond(b, a, order: 2)
        #expect(m.bonds.count == 1)
        #expect(m.bondTotal(of: a) == 2)
    }

    @Test func removingAtomDropsItsBonds() throws {
        var m = try molecule(["O", "H", "H"], bonds: [(0, 1, 1), (0, 2, 1)])
        m.removeAtom(0)
        #expect(m.bonds.isEmpty)
        #expect(m.atoms.count == 2)
    }
}

@Suite("Naming")
struct NamingTests {
    @Test func waterFromBuiltMolecule() throws {
        let water = try molecule(["O", "H", "H"], bonds: [(0, 1, 1), (0, 2, 1)])
        let id = try #require(Naming.identify(water))
        #expect(id.displayName == "Water")
        #expect(id.systematicName == "dihydrogen monoxide")
        #expect(id.isCatalogued)
    }

    @Test func incompleteMoleculeGetsNoName() throws {
        let oh = try molecule(["O", "H"], bonds: [(0, 1, 1)])
        #expect(Naming.identify(oh) == nil)
    }

    @Test func catalogHits() throws {
        #expect(Naming.identify(Formula(parsing: "NaCl")!)?.displayName == "Table salt")
        #expect(Naming.identify(Formula(parsing: "NaOH")!)?.aliases.contains("Lye") == true)
        #expect(Naming.identify(Formula(parsing: "C2H6O")!)?.isomerNote != nil)
    }

    @Test func generatedCovalentNames() {
        func name(_ f: String) -> String? { Naming.systematicName(for: Formula(parsing: f)!) }
        #expect(name("N2O4") == "dinitrogen tetroxide")
        #expect(name("PCl5") == "phosphorus pentachloride")
        #expect(name("SF6") == "sulfur hexafluoride")
        #expect(name("Cl2O") == "dichlorine monoxide")
        #expect(name("CS2") == "carbon disulfide")
        #expect(name("P4") == "tetraphosphorus")
        #expect(name("He") == "helium")
    }

    @Test func generatedIonicNames() {
        func name(_ f: String) -> String? { Naming.systematicName(for: Formula(parsing: f)!) }
        #expect(name("MgBr2") == "magnesium bromide")
        #expect(name("Al2O3") == "aluminum oxide")
        #expect(name("FeCl2") == "iron(II) chloride")
        #expect(name("FeCl3") == "iron(III) chloride")
        #expect(name("Li3N") == "lithium nitride")
    }

    @Test func impossibleCombinationsGetNoName() {
        func name(_ f: String) -> String? { Naming.systematicName(for: Formula(parsing: f)!) }
        #expect(name("NaCl2") == nil)
        #expect(name("Fe2") == nil)
        #expect(name("NaK") == nil)
        #expect(name("C6H12O6N") == nil)
    }
}

@Suite("Catalog and hazards")
struct CatalogTests {
    @Test func noDuplicateFormulas() {
        let keys = CompoundCatalog.all.map(\.formula)
        #expect(Set(keys).count == keys.count)
    }

    @Test func everyHazardHasAReason() {
        for compound in CompoundCatalog.all {
            for note in compound.hazards { #expect(!note.reason.isEmpty, "\(compound.formula)") }
        }
    }

    @Test func nitricAcidIsCorrosiveOxidizer() {
        let hazards = Naming.identify(Formula(parsing: "HNO3")!)!.hazards.map(\.hazard)
        #expect(hazards.contains(.corrosive))
        #expect(hazards.contains(.oxidizer))
    }

    @Test func nitrogenDioxideIsToxic() {
        let hazards = Naming.identify(Formula(parsing: "NO2")!)!.hazards.map(\.hazard)
        #expect(hazards.contains(.toxic))
    }

    @Test func hydrogenIsFlammableAndExplosive() {
        let hazards = Naming.identify(Formula(parsing: "H2")!)!.hazards.map(\.hazard)
        #expect(hazards.contains(.flammable))
        #expect(hazards.contains(.explosive))
    }

    @Test func everyHazardHasTitleAndSymbol() {
        for hazard in Hazard.allCases {
            #expect(!hazard.title.isEmpty)
            #expect(!hazard.symbolName.isEmpty)
        }
    }
}
