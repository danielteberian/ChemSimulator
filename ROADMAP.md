# ChemLab Roadmap

Legend: `[x]` done, `[~]` in progress, `[ ]` not started.

## Milestone 1 — Core `[x]`
- [x] 118 elements with mass, electronegativity, valences, ion charges
- [x] Molecule graph with valence validation
- [x] Hill formulas + parser
- [x] Naming: catalog (~50 compounds) + systematic generator
- [x] Hazard tags, safety disclaimer text

## Milestone 2 — Molecule builder UI `[~]` (macOS done, iOS and polish left)
- [x] Roadmap, package restructure (`ChemLabCore`, `ChemLabUI`, `ChemLab` app)
- [x] Periodic table layout data (core, tested)
- [x] `BuilderModel`: add/move/bond/erase, auto-bond to selection (13 tests)
- [x] Periodic table picker (all 118, f-block rows, category colours)
- [x] Molecule canvas: atoms, 1–3 order bonds, valence rings, "+N" open-bond badges
- [x] Info panel: name, formula, aliases, molar mass, hazard badges with reasons
- [x] First-launch disclaimer + About/Safety screen
- [x] macOS app builds and launches via `swift run` (see SDK note in DESIGN.md)
- [ ] Try the drag/bond gestures by hand. The model logic is tested and the
      static layout was checked in snapshots, but the gesture wiring in
      `MoleculeCanvas` was not exercised by an automated test.
- [ ] iOS app target (needs full Xcode). The compact (phone) layout and iOS
      compile have never been built or seen.
- [ ] Isomer-aware matching (structure, not just formula)
- [~] Formal charges (written, unverified): nitric acid and carbon monoxide
      are representable. Still open: radicals (NO₂), a UI to set charges, and
      naming charged ions.
- [~] Acids / bases / salts picker (written, unverified): ~45 substances with
      structure strings, catalog names and hazards, plus a tree-and-spring
      layout to place them.
- [~] Undo/redo (written, unverified): snapshot stack in `BuilderModel`, toolbar
      buttons, ⌘Z / ⇧⌘Z, tests in `UndoTests.swift`. A whole drag is one step.
- [~] More presets (written, unverified): Gases, Oxides and Organics tabs
      (28 more structure strings).
- [~] "Hazards not reviewed" state (written, unverified): an empty hazard list
      no longer reads as an all-clear in the info panel.
- [ ] Work through [ISSUES.md](ISSUES.md), starting with section 0

## Milestone 3 — Lab engine `[~]` (written, never compiled or run)
Code is in `Sources/ChemLabCore/Lab/`, tests in `LabDataTests.swift` and
`LabEngineTests.swift`. Nothing here has been built. See PROGRESS.md section 5.
- [x] Substances with state (solid/liquid/gas/aqueous), amounts, temperature
      (`Species`, `Beaker`, `Contents`)
- [x] Reaction rules as data: acid + metal, acid + base, displacement, decomposition
      (`Reaction`, `ReactionTable` for hand-written ones, `ReactionGenerator` for patterns)
- [x] Activity series, solubility rules -> precipitates
- [x] Heat: phase change, decomposition thresholds, boiling holds at 100 °C
- [x] Reaction hazards: toxic gas, explosive gas, exothermic, corrosive
- [x] Polyatomic ions (sulfate, nitrate, hydroxide, ...) as `Ion`
- [x] Equation balancer (also used to check every reaction in the data)
- [x] pH estimate, solution color, concentrated vs. dilute reagents
- [ ] Compile it, run the tests, fix what breaks

## Milestone 4 — Lab UI `[~]` (written, never compiled or seen)
Code is in `Sources/ChemLabUI/Lab/` plus `RootView.swift`. The macOS app now
opens on `ChemLabRootView` (Builder | Lab | Learn).
- [x] 2D bench: three beakers and a burner (`BeakerView`). No flasks yet.
- [x] Pour (liquid only, or everything), add solid/liquid/gas from a shelf, heat,
      burner, spark, stir, cool, vent, cover
- [x] Visual effects: bubbles, precipitate and solid piles, solution color, gas
      and fumes, flame, boiling
- [x] Hazard callouts with GHS-style icons (per beaker, and full reasons in
      `BenchPanel`)
- [ ] Look at it in a real window (snapshot tests exist: `lab-*.png`, `learn.png`)
- [ ] Drag-and-drop pouring (pouring is a menu for now)
- [ ] iOS: the compact layout was written but never built

## Milestone 5 — Learning layer `[~]` (written, never compiled or seen)
- [x] "Why did that happen?" text on every reaction (`Reaction.why`), shown in
      `BenchPanel` and kept in the encyclopedia
- [x] 12 challenges with hints, "show me", and a "what you learned" card
- [x] Encyclopedia of every substance and reaction seen, saved between launches
- [x] 15 guided experiments that set up a beaker for you (each declares what it
      should produce, and a test runs them all)
- [x] More builder presets (see milestone 2)
- [ ] Quizzes / explanations that adapt to what the learner did
- [ ] Net ionic equations and spectator ions shown explicitly

## Principle: experiment freely, explain everything

Users can build and mix anything, including dangerous things. The app never
blocks an experiment. It shows a hazard badge and says *why* it is dangerous,
because seeing what goes wrong and understanding it is the point. The
simulation disclaimer stays visible (see `SafetyDisclaimer`).
