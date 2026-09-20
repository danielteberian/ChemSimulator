# ChemLab Progress Log

A record of what has been built so far, what was checked, and what wasn't.
Written 2026-09-18, updated 2026-09-19. See `ROADMAP.md` for what's next and
`ISSUES.md` for known problems.

## Goal

A Mac and iOS app for learning chemistry, in two halves:

1. A **molecule builder**: create atoms of any element, bond them, and see the
   compound's name (H₂O shows "Water", also "dihydrogen monoxide").
2. A **virtual 2D lab**: acids and bases, dissolving metals, precipitates,
   heating, and so on. (Not started; milestones 3 and 4.)

Decisions made with you along the way:

- Build the design doc and a working chemistry core first, and the molecule
  builder before the lab.
- Show a disclaimer that this is a simulation, and mark hazards (poisonous,
  explosive, corrosive) with an icon and a reason. Example: copper in nitric
  acid gives toxic NO₂; lye, water and aluminum give explosive hydrogen.
- **Experiment freely.** Users can make scary things for educational purposes.
  The app never blocks anything. It labels the hazard and explains why.

## Timeline

### 1. Design and core (milestone 1)

- Wrote `DESIGN.md`: architecture, naming approach, valence checking, lab
  concept, safety section, milestones.
- Built the chemistry core (`Sources/ChemLabCore`):
  - All 118 elements with mass, electronegativity, bonding valences, ion charges.
  - Molecule graph (atoms, bonds of order 1 to 3) with valence checking that
    reports each atom as satisfied, open or over-valent.
  - Hill-system formulas, plus a formula parser that handles parentheses.
  - Naming: a catalog of known compounds keyed by formula, with a fallback
    generator for simple binary compounds ("dinitrogen tetroxide",
    "iron(III) chloride").
  - Hazard tags modeled on the GHS pictograms, each with a reason, and the
    safety disclaimer text.
- 28 tests passed.

### 2. Molecule builder (milestone 2)

- Restructured into one Swift package at the project root with three targets:
  `ChemLabCore`, `ChemLabUI` (SwiftUI views for macOS and iOS) and `ChemLab`
  (the macOS app).
- Created `ROADMAP.md` with the five milestones as checklists.
- Added the periodic table grid layout to the core (tested).
- Built `BuilderModel`, the editing logic with no views: add, move, bond,
  erase, and auto-bond to the selected atom. Tapping O, H, H makes water.
- Built the views:
  - Periodic table picker.
  - Molecule canvas with 1 to 3 order bonds, valence rings and "+N"
    open-bond badges.
  - Info panel with name, formula, molar mass, aliases, hazard badges with
    reasons, and what's missing on an unfinished molecule.
  - First-launch disclaimer and an About & Safety sheet.
  - A wide layout for Mac and a compact layout for phones.
- Rendered the real window to images to check the layout. That caught two bugs
  the mock renderer had hidden (the table drifting off-center, and dead space
  beside the tool picker), both fixed.
- Confirmed the app launches and stays running.
- Result: 48 tests passing (31 core, 17 UI including snapshot renders).

### 3. Environment findings

- Xcode wasn't installed, and you later said you had deleted it.
- The macOS 27 SDK can't compile SwiftUI's `@State` with only the Command Line
  Tools, because the macros plugin is missing. Building against the macOS 26
  SDK works. The commands are in `DESIGN.md`.
- A stale `.build` folder once caused a "TestingMacros not found" error. Deleting
  it fixed it.

### 4. Issues list and substance picker (written without building)

You asked me to list everything that needed addressing and to add a picker for
common acids, bases and salts, and to write code only, with no builds or tests.

- Wrote `ISSUES.md`: about 80 open items across seven sections, prioritized.
- **Formal charges** on atoms, so nitric acid (N⁺ and O⁻) and carbon monoxide
  can exist. Charged atoms take the valence of the neutral element with the
  same electron count.
- **Structure parser** (`StructureParser`): builds a molecule from a string like
  `H-O-[N+](=O)-[O-]`. Supports bond orders, branches, ring closures and
  bracketed charges.
- **Substance library**: 44 acids, bases and salts, each defined by a structure
  string. Names, formulas and hazards come from the compound catalog. I added
  17 catalog entries for substances it lacked.
- **Layout** (`GraphLayout`): a tree layout from the best-connected atom, then
  spring relaxation, to position an inserted molecule.
- **Add panel**: Elements, Acids, Bases and Salts tabs. Substances show as
  cards with name, formula and hazard icons.
- Small fixes: formulas now show as people write them ("H₂SO₄", "NaCl") instead
  of Hill order; hazard text uses US spelling; snapshot tests are guarded to
  macOS only.
- New tests written: `SubstanceTests.swift` (parser, formal charges, library)
  and `InsertTests.swift` (insertion and layout).

### 5. Milestones 3, 4 and 5 (written 2026-09-19, again without building)

You asked me to go through the milestones and do them, with no running: no
`swift build`, no `swift test`, no launching the app. So all of this is
**uncompiled and untested**. I traced the engine tests by hand while writing
them, which caught a few design bugs (below), but that is not the same as
running them.

**Milestone 3, the lab engine** (`Sources/ChemLabCore/Lab/`, 18 files):

- `Ion` / `IonCatalog`: cations and anions (including polyatomic ones) that
  build salt formulas and names. `Ca(OH)₂`, `Al₂(SO₄)₃` and `(NH₄)₂SO₄` come out
  of the charge ratio.
- `SolubilityRules`: the textbook rules as data (soluble / slightly soluble /
  insoluble), used to decide what precipitates.
- `EquationBalancer`: solves for the smallest whole-number coefficients with
  exact fractions. It balances every generated reaction, and checks every
  hand-written one in the tests.
- `Species` (role, state, melting and boiling point, colors, hazards) and
  `SpeciesCatalog`: about 115 substances (water, gases, 13 metals, oxides,
  7 acids, 12 bases, 58 salts). Names and hazards come from the existing
  `CompoundCatalog`. Salts and bases the library doesn't list are built on the
  spot from their ions, so any exchange of known ions gives a real product.
- `ActivitySeries`: Li to Ag with hydrogen in place, and how each metal treats
  water and dilute acid.
- `Reaction` (data: reactants, products, conditions, heat, hazards, "why") and
  `ReactionTable` (hand-written: nitric acid on Cu, Ag and Zn with separate
  concentrated and dilute reactions, hot sulfuric acid on copper, lye on
  aluminum, decompositions, combustion, thermite, bleach and acid).
- `ReactionGenerator`: neutralization, acid + metal, metal + water,
  displacement, precipitation, acid + carbonate or sulfide, and ammonium salt +
  base, all worked out from the species present.
- `Beaker`: contents in four states, a gas headspace, temperature, and
  everything in `mix()`: dissolving, melting, boiling, then reactions until
  nothing more happens. Water holds at 100 °C while it boils away. Reactions
  release or absorb heat. Dry salts don't react until water is added. Burning
  needs oxygen (open beaker) and either heat or a spark. Nothing is ever
  blocked; hazards from the substances and from what happened are collected in
  `activeHazards`. Readouts: a rough pH, solution color, fill level, solids.

Design bugs found while tracing the tests by hand, and fixed:

- A static-initialization cycle: the library called the salt builder, which
  looked itself up in the library. Split into `buildSalt` (no lookup) and
  `makeSalt`.
- Concentrated acids added neat have no water, so the heat of reaction boiled
  the few drops of water they made and cascaded into decomposing the product.
  Real concentrated reagents are solutions, so `add(_:moles:water:)` and
  `ReagentStrength` (as sold / dilute) now add the water that comes with them.
  "Concentrated" is decided from molarity (8 M and up), not a flag.
- Dissolving heat (lye, sulfuric acid) now scales with the water available to
  absorb it, so a splash of water on acid doesn't boil instantly.
- Two challenges could be completed trivially (adding hydrogen or chlorine gas
  directly). New goals `producedGas` and `gasFromReaction` require a reaction to
  have made the gas.
- Endothermic reactions could cool a beaker by hundreds of degrees at once, so
  the drop is capped at 25 °C a step.
- A type named `Observation` in `ChemLabCore` would shadow Swift's `Observation`
  module, which the `@Observable` macro refers to by name, and break
  `BuilderModel` and `LabModel`. Renamed to `LabNote`. Avoid type names that
  match Apple module names (`Observation`, `SwiftUI`, `Foundation`, ...).

**Milestone 4, the lab UI** (`Sources/ChemLabUI/Lab/`, `RootView.swift`):

- `LabModel`: three beakers, the shelf, amounts, add / heat / burner / spark /
  stir / cool / vent / cover / pour (liquid only, so a precipitate stays behind)
  / empty. Saves progress; tested without any views.
- `BeakerView`: a `Canvas` drawing of the glass with liquid at the right level
  and color, solid piles, bubbles, gas and fumes rising past the rim, a burner
  flame, graduation marks, temperature, pH and hazard icons.
- `ShelfView`: groups, small / medium / large, and an "as sold / dilute"
  choice for acids, ammonia and bases. `BenchPanel`: what's inside, hazards with
  reasons, every reaction with its equation, heat and "Why did that happen?".
- `LabView` (toolbar, toasts, wide and phone layouts) and `ChemLabRootView`
  (Builder | Lab | Learn). The macOS app now opens on the root view.

**Milestone 5, the learning layer:**

- `Reaction.why` on every reaction, written for learners.
- `ChallengeLibrary`: 12 challenges (make salt, neutralize an acid, hydrogen,
  fizz, precipitate, golden rain, displace copper, discover a toxic gas,
  explosive gas, ignite, boil, bake limestone). Each has a hint, a stored
  solution for "Show me", and a "what you learned" card.
- `ExperimentLibrary`: 15 guided experiments, including the hazardous ones you
  asked for (copper in concentrated nitric acid, lye and aluminum, sodium in
  water, bleach and acid). Each declares what it should produce.
- `Encyclopedia`: every substance and reaction seen, and completed challenges,
  as saved data.
- `LearnView`: challenges, experiments and the encyclopedia.

**Leftovers from milestone 2 and the issues list that I also did:**

- Undo / redo in the builder (snapshots; a whole drag is one step).
- Gases, Oxides and Organics tabs in the builder's picker (28 structures).
- "Hazards not reviewed" in the info panel, so an empty list can't read as safe.

**Tests written (all unrun):** `LabDataTests` (balancer, ions, solubility, data
integrity, every reaction balanced, every generated reaction balanced),
`LabEngineTests` (26 scenarios), `LabLearningTests` (every challenge
solution meets its own goal, every experiment produces what it claims, the
encyclopedia), `LabModelTests`, `UndoTests`, and 6 more snapshot renders.

### 6. Runner script (2026-09-20, not run)

Added `run.sh` at the project root to build and launch the app on this Mac.
It picks the macOS 26 SDK when only the Command Line Tools are installed,
runs `swift build`, then starts the `ChemLab` executable. Options: `--clean`,
`--release`, `--build-only`. It writes `.runlogs/build.log`,
`.runlogs/last-errors.txt` (paste this if the build fails),
`.runlogs/last-warnings.txt` and `.runlogs/app.log`. Only its syntax was
checked (`bash -n`); it has never been executed.

## What is verified and what isn't

| Area | Status |
|---|---|
| Elements, molecules, formulas, naming, hazards (sections 1 and 2 above) | Built, 48 tests passing |
| Builder views on macOS | Built, rendered to images, launched without crashing |
| Drag and bond gestures | **Not tried.** Model logic is tested; gesture wiring isn't |
| iOS and the phone layout | **Never built or seen** (no iOS SDK) |
| Dark mode | Never viewed |
| Section 4 above (charges, parser, library, layout, add panel, new tests) | Built and run in Xcode by you on 2026-09-20 ("works perfectly"). I have not seen the build output or test results |
| Section 5 above (lab engine, lab UI, learning layer, undo, new presets, new tests) | Built and run in Xcode by you on 2026-09-20 ("works perfectly"). I have not seen the build output or test results |
| Chemistry content in the lab (hazard text, "why" text, enthalpies) | **Not reviewed by a chemist** |

Reported working, but not checked by me. Which tests were run and whether they
passed isn't recorded. The likeliest trouble spots if something looks off: SwiftUI `Canvas` arithmetic and
`@Bindable` in the lab views, hand-traced numbers in the engine tests
(temperatures, boiling), the layout of ring-shaped salts, and the hand-written
structure strings and catalog entries. `ISSUES.md` sections 0 and 8 list them.

## File map

```
ChemLab/
├── DESIGN.md          architecture, safety design, environment notes
├── ROADMAP.md         five milestones as checklists
├── ISSUES.md          known issues and limitations, prioritized
├── PROGRESS.md        this file
├── Package.swift
├── run.sh             build and launch the app (see section 6)
├── Sources/
│   ├── ChemLabCore/   Element, PeriodicTable(+Layout), Molecule, Formula,
│   │                  Naming, Hazards, CompoundCatalog (+Organic,
│   │                  +AcidsBasesSalts), StructureParser, CommonSubstance,
│   │                  SubstanceLibrary
│   │   └── Lab/       Ion, Solubility, EquationBalancer, Species,
│   │                  Species+Reagent, SpeciesCatalog (+Basics, +Compounds),
│   │                  ActivitySeries, Reaction, ReactionTable,
│   │                  ReactionGenerator, Beaker (+Reactions, +Readouts),
│   │                  Experiment, Challenge, Encyclopedia
│   ├── ChemLabUI/     BuilderModel, BuilderView, MoleculeCanvas, InfoPanel,
│   │                  PeriodicTablePicker, AddPanel, DisclaimerView, Placement,
│   │                  GraphLayout, Styles, RootView
│   │   └── Lab/       LabModel, LabView, BeakerView, ShelfView, BenchPanel,
│   │                  LearnView
│   └── ChemLab/       ChemLabApp.swift (macOS entry point)
└── Tests/
    ├── ChemLabCoreTests/   ChemLabCoreTests, SubstanceTests, LabDataTests,
    │                       LabEngineTests, LabLearningTests
    └── ChemLabUITests/     BuilderModelTests, InsertTests, UndoTests,
                            LabModelTests, SnapshotTests
```

## Next steps

1. Build and test everything. Nothing from sections 4 and 5 has ever been
   compiled. Expect compile errors first, then some failing assertions in the
   engine tests. `ISSUES.md` section 0 lists the suspects in order.
2. Look at the Lab, Learn and Builder tabs in a real window
   (`CHEMLAB_SNAPSHOT_DIR=... swift test --filter Snapshot`).
3. Have someone with chemistry training review the reaction data, hazard notes and
   "why" text (`ISSUES.md` section 8).
4. Reinstall Xcode, then add the iOS app target.
5. Then the top correctness gaps: isomer-aware matching, radicals, naming for ions
   in the builder, net ionic equations in the lab, equilibrium and rates.
