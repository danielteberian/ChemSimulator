import ChemLabCore
import CoreGraphics
import Testing

@testable import ChemLabUI

private func element(_ symbol: String) -> Element { PeriodicTable.element(symbol: symbol)! }

@MainActor
@Suite("Undo and redo")
struct UndoTests {
    @Test func undoRemovesTheLastAtomAndRedoBringsItBack() {
        let model = BuilderModel()
        model.addAtom(element("O"))
        model.addAtom(element("H"))
        #expect(model.molecule.atoms.count == 2)

        model.undo()
        #expect(model.molecule.atoms.count == 1)
        model.redo()
        #expect(model.molecule.atoms.count == 2)
        #expect(model.molecule.bonds.count == 1)
    }

    @Test func aNewEditClearsTheRedoHistory() {
        let model = BuilderModel()
        model.addAtom(element("O"))
        model.addAtom(element("H"))
        model.undo()
        #expect(model.canRedo)

        model.addAtom(element("Cl"))
        #expect(!model.canRedo)
    }

    @Test func clearCanBeUndone() {
        let model = BuilderModel()
        model.addAtom(element("O"))
        model.addAtom(element("H"))
        model.addAtom(element("H"))
        model.clear()
        #expect(model.molecule.atoms.isEmpty)

        model.undo()
        #expect(model.molecule.atoms.count == 3)
        #expect(model.molecule.bonds.count == 2)
    }

    @Test func aWholeDragIsOneUndoStep() throws {
        let model = BuilderModel()
        let id = model.addAtom(element("O"))
        let start = try #require(model.positions[id])

        for step in 1...10 {
            model.moveAtom(id, to: CGPoint(x: start.x + CGFloat(step) * 5, y: start.y))
        }
        model.undo()
        #expect(model.positions[id] == start)
    }

    @Test func undoWithNothingToUndoDoesNothing() {
        let model = BuilderModel()
        #expect(!model.canUndo)
        model.undo()
        model.redo()
        #expect(model.molecule.atoms.isEmpty)
    }

    @Test func insertingASubstanceCanBeUndone() throws {
        let model = BuilderModel()
        let water = try #require(SubstanceLibrary.all.first { $0.name == "Water" })
        model.insert(water)
        #expect(model.molecule.atoms.count == 3)
        model.undo()
        #expect(model.molecule.atoms.isEmpty)
    }
}
