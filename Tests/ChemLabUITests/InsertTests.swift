import ChemLabCore
import CoreGraphics
import Testing

@testable import ChemLabUI

@MainActor
@Suite("Inserting substances")
struct InsertTests {
    private func substance(_ name: String) -> CommonSubstance {
        SubstanceLibrary.all.first { $0.name == name }!
    }

    @Test func insertingSulfuricAcidAddsOneNamedMolecule() {
        let model = BuilderModel()
        model.insert(substance("Sulfuric acid"))
        #expect(model.molecule.atoms.count == 7)
        #expect(model.reports.count == 1)
        #expect(model.reports.first?.identification?.displayName == "Sulfuric acid")
        #expect(model.positions.count == 7)
    }

    @Test func insertingTwiceGivesTwoSeparateMolecules() {
        let model = BuilderModel()
        model.insert(substance("Sodium hydroxide"))
        model.insert(substance("Hydrogen chloride"))
        #expect(model.reports.count == 2)
    }

    @Test func insertedAtomsDoNotLandOnExistingOnes() {
        let model = BuilderModel()
        model.autoBond = false
        model.canvasCenter = CGPoint(x: 300, y: 250)
        model.addAtom(PeriodicTable.element(symbol: "Ne")!)
        model.insert(substance("Nitric acid"))
        let points = Array(model.positions.values)
        for (i, a) in points.enumerated() {
            for b in points[(i + 1)...] {
                #expect(Placement.distance(a, b) >= Placement.atomRadius * 1.8)
            }
        }
    }

    @Test func insertingLeavesTheSelectionAlone() {
        let model = BuilderModel()
        let o = model.addAtom(PeriodicTable.element(symbol: "O")!)
        model.insert(substance("Table salt"))
        #expect(model.selectedAtomID == o)
    }

    @Test func layoutKeepsEverySubstanceReadable() {
        for substance in SubstanceLibrary.all {
            let molecule = substance.makeMolecule()
            let layout = GraphLayout.positions(for: molecule)
            #expect(layout.count == molecule.atoms.count, "\(substance.structure)")

            for bond in molecule.bonds {
                let d = Placement.distance(layout[bond.a]!, layout[bond.b]!)
                #expect(d > Placement.atomRadius * 2, "\(substance.structure): bond too short")
                #expect(d < Placement.bondLength * 1.5, "\(substance.structure): bond too long")
            }

            let points = Array(layout.values)
            for (i, a) in points.enumerated() {
                for b in points[(i + 1)...] {
                    #expect(
                        Placement.distance(a, b) >= Placement.atomRadius * 1.8,
                        "\(substance.structure): atoms overlap")
                }
            }
        }
    }

    @Test func layoutIsCenteredOnTheOrigin() {
        let layout = GraphLayout.positions(for: substance("Sulfuric acid").makeMolecule())
        let count = CGFloat(layout.count)
        let cx = layout.values.reduce(0) { $0 + $1.x } / count
        let cy = layout.values.reduce(0) { $0 + $1.y } / count
        #expect(abs(cx) < 0.001)
        #expect(abs(cy) < 0.001)
    }

    @Test func chargedAtomsShowUpInTheModel() {
        let model = BuilderModel()
        model.insert(substance("Nitric acid"))
        #expect(model.molecule.atoms.filter { $0.formalCharge != 0 }.count == 2)
        #expect(model.molecule.netCharge == 0)
    }
}
