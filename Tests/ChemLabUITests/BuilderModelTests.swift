import ChemLabCore
import CoreGraphics
import Testing

@testable import ChemLabUI

private func el(_ symbol: String) -> Element { PeriodicTable.element(symbol: symbol)! }

@MainActor
@Suite("BuilderModel")
struct BuilderModelTests {
    @Test func tappingOThenHHBuildsWater() throws {
        let model = BuilderModel()
        model.addAtom(el("O"))
        model.addAtom(el("H"))
        model.addAtom(el("H"))

        #expect(model.molecule.atoms.count == 3)
        #expect(model.molecule.bonds.count == 2)
        let report = try #require(model.reports.first)
        #expect(report.isComplete)
        #expect(report.identification?.displayName == "Water")
    }

    @Test func firstAtomBecomesSelectedAndStaysSelected() {
        let model = BuilderModel()
        let o = model.addAtom(el("O"))
        #expect(model.selectedAtomID == o)
        model.addAtom(el("H"))
        #expect(model.selectedAtomID == o)
    }

    @Test func fullAnchorDoesNotAutoBondFurtherAtoms() {
        let model = BuilderModel()
        model.addAtom(el("O"))
        model.addAtom(el("H"))
        model.addAtom(el("H"))
        model.addAtom(el("H"))  // oxygen already has 2 of 2
        #expect(model.molecule.atoms.count == 4)
        #expect(model.molecule.bonds.count == 2)
        #expect(model.reports.count == 2)
    }

    @Test func autoBondCanBeTurnedOff() {
        let model = BuilderModel()
        model.autoBond = false
        model.addAtom(el("O"))
        model.addAtom(el("H"))
        #expect(model.molecule.bonds.isEmpty)
    }

    @Test func noBlePartnersDoNotAutoBond() {
        let model = BuilderModel()
        model.addAtom(el("C"))
        model.addAtom(el("He"))
        #expect(model.molecule.bonds.isEmpty)
    }

    @Test func newAtomsNeverOverlap() {
        let model = BuilderModel()
        model.autoBond = false
        for _ in 0..<12 { model.addAtom(el("Ne")) }
        let points = Array(model.positions.values)
        for (i, a) in points.enumerated() {
            for b in points[(i + 1)...] {
                #expect(Placement.distance(a, b) >= Placement.atomRadius * 2)
            }
        }
    }

    @Test func bondedAtomsSitAtBondLengthFromAnchor() throws {
        let model = BuilderModel()
        let c = model.addAtom(el("C"))
        for _ in 0..<4 { model.addAtom(el("H")) }
        let center = try #require(model.positions[c])
        for atom in model.molecule.atoms where atom.id != c {
            let d = Placement.distance(center, try #require(model.positions[atom.id]))
            #expect(abs(d - Placement.bondLength) < 0.001)
        }
        #expect(model.reports.first?.identification?.displayName == "Methane")
    }

    @Test func cycleBondGoesSingleDoubleTripleNone() {
        let model = BuilderModel()
        model.autoBond = false
        let a = model.addAtom(el("C"))
        let b = model.addAtom(el("C"))
        var orders: [Int] = []
        for _ in 0..<4 {
            model.cycleBond(a, b)
            orders.append(model.molecule.bonds.first?.order ?? 0)
        }
        #expect(orders == [1, 2, 3, 0])
    }

    @Test func erasingAtomClearsSelectionAndBonds() {
        let model = BuilderModel()
        let o = model.addAtom(el("O"))
        model.addAtom(el("H"))
        model.removeAtom(o)
        #expect(model.selectedAtomID == nil)
        #expect(model.molecule.bonds.isEmpty)
        #expect(model.positions.count == 1)
    }

    @Test func hitTesting() throws {
        let model = BuilderModel()
        let o = model.addAtom(el("O"))
        let h = model.addAtom(el("H"))
        let po = try #require(model.positions[o])
        let ph = try #require(model.positions[h])

        #expect(model.atomID(at: po) == o)
        #expect(model.atomID(at: CGPoint(x: po.x + 500, y: po.y)) == nil)

        let mid = CGPoint(x: (po.x + ph.x) / 2, y: (po.y + ph.y) / 2)
        #expect(model.atomID(at: mid) == nil)
        #expect(model.bond(at: mid) != nil)
        #expect(model.bond(at: CGPoint(x: mid.x, y: mid.y + 60)) == nil)
    }

    @Test func issuesExplainWhatIsMissing() throws {
        let model = BuilderModel()
        model.addAtom(el("O"))
        model.addAtom(el("H"))
        let report = try #require(model.reports.first)
        #expect(!report.isComplete)
        #expect(report.identification == nil)
        #expect(report.issues.contains("Oxygen has 1 of 2 bonds"))
    }

    @Test func overBondedAtomIsReported() throws {
        let model = BuilderModel()
        model.autoBond = false
        let h = model.addAtom(el("H"))
        let c1 = model.addAtom(el("C"))
        let c2 = model.addAtom(el("C"))
        model.cycleBond(h, c1)
        model.cycleBond(h, c2)
        let report = try #require(model.reports.first)
        #expect(report.issues.contains { $0.hasPrefix("Hydrogen has too many bonds") })
    }

    @Test func clearResetsEverything() {
        let model = BuilderModel()
        model.addAtom(el("O"))
        model.clear()
        #expect(model.molecule.atoms.isEmpty)
        #expect(model.positions.isEmpty)
        #expect(model.selectedAtomID == nil)
    }
}
