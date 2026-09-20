# ChemLab — Design

A Mac + iOS app for learning chemistry, in two halves:

1. **Molecule builder** — spawn atoms of any element, bond them, and see the
   compound's name (e.g. H₂O → "Water", also "dihydrogen monoxide").
2. **Virtual lab** — a 2D bench with beakers, acids/bases, metals, precipitation,
   heating, etc.

v1 focuses on the molecule builder. The lab reuses the same core.

## Architecture

```
ChemLab/                  one Swift package; `swift build` / `swift test` / `swift run`
├── Sources/ChemLabCore   chemistry logic, no UI
│   ├── Elements          118 elements: symbol, name, mass, valence, electronegativity
│   ├── Molecule          atom/bond graph + validation (valence checks)
│   ├── Formula           Hill-system formula string (H2O, C6H12O6, CH4O)
│   ├── Naming            formula -> common + systematic names
│   ├── Hazards           hazard tags (corrosive, toxic, explosive...) + explanations
│   └── Lab/              the lab engine and learning layer (see "Virtual lab")
│       ├── Ion, Solubility, ActivitySeries, EquationBalancer
│       ├── Species, SpeciesCatalog   what can go in a beaker
│       ├── Reaction, ReactionTable, ReactionGenerator   reaction rules as data
│       ├── Beaker        contents, temperature, and `mix()` (the engine)
│       └── Experiment, Challenge, Encyclopedia   learning layer
├── Sources/ChemLabUI     SwiftUI views shared by macOS and iOS
│   ├── BuilderModel      editing state and rules (testable, no views)
│   ├── Builder views     periodic table, canvas, info panel, disclaimer
│   ├── LabModel          bench state, shelf, progress (testable, no views)
│   └── Lab views         bench, beakers, shelf, bench panel, learn screens
├── Sources/ChemLab       macOS app entry point (`swift run ChemLab`)
└── iOS app               (needs full Xcode) thin app target importing ChemLabUI
```

- **SwiftUI multiplatform** app, one target for macOS and iOS.
- **Core has no UI dependency**, so all chemistry is unit-testable without Xcode.
- **Data-driven**: elements, known compounds and reactions are data tables, not
  hard-coded logic. Adding "Aspirin" or a new reaction is a one-line data change.

## Naming engine

Lookup order for a molecule:

1. **Known-compound table**, keyed by Hill formula (`H2O` → Water). Each entry
   holds a common name, systematic name, and aliases.
2. **Systematic generator** for simple binary compounds when not in the table:
   covalent (prefix rules: "carbon dioxide", "dinitrogen tetroxide") and ionic
   (metal + nonmetal with -ide suffix, e.g. "sodium chloride").
3. Otherwise show the formula only.

**Known limitation:** formula alone cannot distinguish isomers (ethanol vs.
dimethyl ether are both C₂H₆O). v1 keys on formula and flags ambiguous entries;
milestone 2 adds graph-based matching for isomers.

## Valence checking

Each atom has a list of allowed valences (C: 4; N: 3,5; S: 2,4,6...). The
builder shows a molecule as *complete*, *open* (free bonds), or *over-valent*
(invalid). Names appear only for complete molecules.

## Virtual lab (milestones 3 to 5)

Reactions are rules of the form `reactants -> products + conditions`:

- Acid + metal → salt + H₂ (gated by the activity series)
- Acid + base → salt + water
- Double displacement → precipitate, using a solubility-rules table
- Heat: decomposition, phase change (thresholds are data)

Not a physical simulation. Curated rules with a clear "why" shown to the learner.

### How the engine works

A `Beaker` holds `Contents` (a `Species`, an amount in moles, and a state:
solid, liquid, gas or dissolved), a gas headspace above the liquid, and a
temperature. Every action (add, heat, spark, pour) ends in `Beaker.mix()`:

1. **Settle.** Substances melt, freeze or boil at their data-driven points, and
   soluble ones dissolve when there is liquid water. Dissolving lye or sulfuric
   acid gives off heat.
2. **Find a reaction.** Candidates are the hand-written `ReactionTable` first
   (special products and conditions), then whatever `ReactionGenerator` works out
   from the species present. A reaction can run when its conditions hold (minimum
   temperature, concentrated or dilute acid, dissolved where it must be) and every
   reactant is available.
3. **Run it** to completion, limited by the scarcest reactant (the extent). Products
   land as solid (insoluble), dissolved (soluble), or gas. Heat is added or taken
   away. The event records the equation, heat, hazards and the "why" text.
4. **Repeat** until nothing more can happen (at most 60 steps).

Some choices that matter:

- **Species carry a role** (metal, acid, base, salt, gas, ...) so common patterns
  are generic. A new metal or salt needs data, not code. Salts and bases that
  aren't in the library are built from their ions on demand.
- **Coefficients are computed.** `EquationBalancer` balances every generated
  reaction, and a test balances every hand-written one.
- **Concentration is real.** Molarity is moles of a species over the liters of
  water. A "concentrated" reagent is added together with the water it comes in,
  so 68% nitric acid is 28 M and dilute is 1 M. Copper gives brown NO₂ in one and
  colorless NO in the other.
- **Air is unlimited oxygen** when the beaker is open. Burning needs an ignition
  temperature or a spark, so magnesium sits in air harmlessly until lit, and a
  covered beaker starves the flame.
- **Nothing is ever blocked.** Hazards come from the species present (static tags)
  and from what happened (reaction tags), and the UI just renders them.

### Learning layer

- Every `Reaction` has a `why` string, shown in the bench panel and saved in the
  encyclopedia.
- `ChallengeGoal` is a small data language (`contains`, `producedGas`, `phBetween`,
  `reactionKind`, `hazardShown`, `all`) so challenges can be listed and tested. Each
  challenge stores a solution, and a test checks that it meets its own goal.
- `ExperimentLibrary` holds guided setups that each state what they should produce.
- `Encyclopedia` is plain `Codable` data, so the app can store it anywhere.

## Safety and hazard awareness

### Disclaimer

The app is for education only. It must show a clear disclaimer:

- On first launch (must be acknowledged before use) and in an About/Safety screen.
- A short reminder near the lab bench, e.g. "Simulated. Do not attempt these
  experiments in real life."

Suggested wording: *"ChemLab is a simulation for learning. Many of the reactions
shown are dangerous in real life: they can release toxic gas, cause fires or
explosions, or burn skin and eyes. Never try them outside a properly equipped
lab with training and supervision."*

### Hazard icons

Whenever the user creates or combines something hazardous, the app shows a
hazard badge plus a one-line explanation of *why*. Icons follow the GHS
pictograms so the learner picks up real-world safety symbols.

| Hazard | Example |
|---|---|
| Corrosive | Nitric acid (HNO₃), lye (NaOH) |
| Toxic / poisonous | Nitrogen dioxide (NO₂), chlorine, carbon monoxide |
| Explosive / flammable | Hydrogen gas (H₂) |
| Oxidizer | Nitric acid, peroxides |
| Reactive (violent) | Sodium in water |
| Heat / thermal | Strongly exothermic mixing |

Hazards attach at two levels:

1. **Substances** carry static hazard tags (`HNO3`: corrosive, oxidizer).
2. **Reactions** carry event hazards for what happens, shown when it fires:
   - Cu + conc. HNO₃ → Cu(NO₃)₂ + NO₂ ↑ + H₂O — **toxic gas**: NO₂ is poisonous.
   - NaOH + H₂O + Al → H₂ ↑ + sodium aluminate — **explosive gas**: hydrogen
     is flammable and forms explosive mixtures with air. The reaction is also
     exothermic and lye is **corrosive**.

Both are data, not logic (see `Hazards` in the core). The UI only renders
whatever tags the substance or reaction carries, so new hazards need no UI changes.

### Experiment freely

The app is a sandbox. Users may build or mix anything, however dangerous. It
never blocks an experiment. It labels the hazard and explains why, which is
the learning.

## Milestones

Tracked with checklists in [ROADMAP.md](ROADMAP.md). In order: core, builder UI,
lab engine, lab UI, learning layer.

## Environment note

Xcode is not installed here, only the Command Line Tools. So the core and UI
libraries and the macOS app build with SwiftPM (`swift build`, `swift run`).
The iOS app needs Xcode and the iOS SDK; the UI library is written to be
multiplatform (no AppKit-only code outside `#if os(macOS)`).

**SDK workaround (Command Line Tools only):** the macOS 27 SDK's `@State` needs
the `SwiftUIMacros` plugin, which the Command Line Tools don't include. Build
against the macOS 26 SDK instead:

```
export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk
swift build && swift test && swift run ChemLab
```

With full Xcode installed this isn't needed. If `swift test` starts failing
with "TestingMacros not found", delete `.build` and rebuild.

**Visual checks without a screen:** the snapshot tests render the real view to
PNG. Run `CHEMLAB_SNAPSHOT_DIR=/some/dir swift test --filter Snapshot`. They do
nothing when the variable is unset.
