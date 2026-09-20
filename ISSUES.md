# ChemLab: Known Issues, Limitations and Loose Ends

Priority: **High** = wrong answers or blocks progress, **Med** = should fix
before other people use it, **Low** = polish.

## 0. Written but never compiled or run (do this first)

Two batches of code have never been built. Everything in the second batch (the
lab engine, lab UI, learning layer, undo, new presets) was also written without
running anything, so expect compile errors before any test result means much.

**Batch 2 (milestones 3 to 5), in the order most likely to break:**

- [ ] **High** Build it. Most likely compile trouble: SwiftUI `Canvas` arithmetic
      in `BeakerView` (Double/CGFloat mixing), `@Bindable` in `LabView`,
      `LearnView` and `ShelfView`, Swift 6 concurrency in `LabModel`
      (burner `Task`), and `switch` expressions returning `Bool` in
      `Beaker+Reactions.swift`.
- [ ] **High** Run `LabDataTests`, `LabEngineTests`, `LabLearningTests`,
      `LabModelTests`, `UndoTests`. The engine tests were traced by hand, not
      run. Where a test and the code disagree, decide which is wrong: the
      hand-traced numbers (temperatures, boiling) are the most suspect.
- [ ] **High** `LabEngineTests.anythingCanBeAddedToAnythingWithoutBlocking` adds
      every species to one beaker in turn, and `LabModelTests` adds every species
      at every strength. Both are heavy (each `mix()` regenerates candidate
      reactions). If they are slow, cache `ReactionGenerator` output by species set.
- [ ] **Med** Check the new structure strings (gases, oxides, organics in
      `SubstanceLibrary`), especially `O=[O+]-[O-]` (ozone), `N#[N+]-[O-]` (N₂O)
      and `O=Fe-O-Fe=O`. `SubstanceLibraryTests` covers them.
- [ ] **Med** Look at the lab in a real window
      (`CHEMLAB_SNAPSHOT_DIR=... swift test --filter Snapshot`, then
      `lab-*.png` and `learn.png`).

**Batch 1 (formal charges, parser, library, layout):**

The formal-charge, structure-parser, substance-library and layout work was
written without a build. Before trusting any of it:

- [ ] **High** Build and run all tests. Expect some compile errors and some
      failing assertions. Suspects, in order:
  - `GraphLayout` (spring relaxation): the `layoutKeepsEverySubstanceReadable`
    test is the real check. Ring molecules (copper/magnesium/barium sulfate,
    calcium carbonate) are the likeliest to come out squashed.
  - `StructureParser`: ring digits, branches, and bracket charges.
  - Every structure string in `SubstanceLibrary`. The tests check that each is
    complete, neutral and named, but I checked the valences by hand only.
  - Catalog entries in `CompoundCatalog+AcidsBasesSalts.swift`.
- [ ] **High** Look at the new Acids / Bases / Salts tabs in a real window. The
      card grid, the panel height when switching tabs, and how inserted
      molecules look on the canvas have never been seen.
- [ ] **Med** Compiler warnings have never been reviewed. My earlier build
      output was filtered to errors only, so Swift 6 concurrency warnings could
      be sitting there.

## 1. Environment and build

- [ ] **Low** `run.sh` (build + launch) has never been executed, only
      syntax-checked. If it misbehaves, the manual commands in `DESIGN.md`
      still work. `.runlogs/` should go in `.gitignore` once there is one.
- [x] **High** Xcode was installed and then deleted. Xcode 27.0 is installed
      again (seen 2026-09-20). Open the package in it with `xed .`; the macOS 26
      SDK workaround in `DESIGN.md` is only for command-line builds. It is still
      needed for the iOS app, SwiftUI previews, and a real signed Mac app.
- [ ] **Med** The project is not under version control. `git init`, add a
      `.gitignore` (`.build/`, `.DS_Store`, `*.xcodeproj/xcuserdata`).
- [ ] **Med** No iOS app target exists. Options: an Xcode project that imports
      the local package, or XcodeGen. The iOS compile, the compact (phone)
      layout, `presentationDetents`, and `navigationBarTitleDisplayMode` have
      never been built or seen.
- [ ] **Med** No app bundle: no Info.plist, bundle ID, app icon, launch screen,
      entitlements, signing or notarization. `swift run` gives a windowed app
      with no Dock icon behavior or menus of its own.
- [ ] **Low** SwiftPM prints linker warnings about missing Command Line Tools
      search paths. Harmless, and they go away with Xcode.
- [ ] **Low** `swift test -c release` won't work because the tests use
      `@testable import`.
- [ ] **Low** No CI, README, or license.
- [ ] **Low** If `swift test` says "TestingMacros not found", delete `.build`.

## 2. Chemistry correctness

- [ ] **High** **Isomers get the wrong name.** Lookup is by formula only. Build
      dimethyl ether and the app says "Ethanol". Same for methyl formate vs.
      acetic acid, fructose vs. glucose, isobutane vs. butane. Needs structure
      matching (canonical graph comparison). Catalog entries carry an
      `isomerNote`, but the name is still shown as if certain.
- [~] **High** **No hazard icons does not mean safe.** Fixed in the builder's
      info panel and the encyclopedia (written, unverified): unknown compounds
      say "Hazards not reviewed" and catalogued ones with no hazards say the
      list being empty doesn't mean safe. Still open: the lab's beaker badges
      show nothing for a hazard-free beaker, and `BenchPanel` has no such line.
- [ ] **High** Hazard notes were written from general knowledge and have not been
      reviewed. They have no source, no GHS hazard codes, and ignore
      concentration and state (hydrochloric acid solution vs. HCl gas;
      "bleach" is a solution). Review against real safety data sheets.
- [ ] **Med** **Charged species can't be named.** Ammonium, hydroxide, nitrate,
      sulfate, hydronium and so on are buildable but show "no name". A formula
      alone would give wrong names, so naming is switched off for net charge
      other than zero. Needs an ion catalog keyed by formula and charge.
- [ ] **Med** No UI to set a formal charge. Only presets and the structure
      parser can make charged atoms. Nitric acid is buildable from the picker
      but not by hand.
- [ ] **Med** Radicals can't be built (NO, NO₂, hydroxyl). Nitrogen dioxide, one
      of the headline examples, is still impossible. Needs unpaired-electron
      support, or a radical flag on atoms.
- [ ] **Med** Valence data is coarse. Cl, Br, I are limited to 1 bond (no
      chlorate, perchlorate, ClO₂, interhalogens). Xe and Kr compounds are
      impossible. Transition metals list only common valences. Hg₂²⁺, Ce⁴⁺ and
      similar special cases are missing.
- [ ] **Med** **Ionic compounds are drawn as covalent bond graphs.** Na–Cl as a
      single bond is a textbook shortcut, but it teaches the wrong picture:
      real salts are ions in a lattice. Consider showing bond type from
      electronegativity difference, an "ions" view, and dissociation in water.
- [ ] **Med** The 2D layout has no molecular geometry. Water isn't drawn at
      104.5°, CO₂ isn't straight, methane isn't tetrahedral. The layout is a
      drawing aid only. Fine for now, but say so in the UI (or add VSEPR).
- [ ] **Med** The systematic-name generator is only a fallback and is wrong
      outside its rules. It orders elements by electronegativity, not IUPAC
      order, so hydrazine (N₂H₄) would come out as "tetrahydrogen dinitride".
      It can't do acids ("hydro-…ic"), oxoacids, polyatomic ions, organic
      chains, or Stock names beyond simple binary ionic compounds.
- [ ] **Low** "Monosilicon"-style edge cases: "silicon monocarbide" for SiC where
      convention says "silicon carbide".
- [ ] **Low** Not modeled: hydrates (CuSO₄·5H₂O), lone pairs, aromaticity and
      resonance (benzene is just a formula match), stereochemistry, isotopes,
      states of matter.
- [ ] **Low** Isoelectronic valence rule for charged atoms is an approximation.
      It's right for second-row atoms (N⁺, O⁻, C⁻) and rough elsewhere.
- [ ] **Low** Element data: some electronegativities are missing (Pm, Eu, Tb,
      Yb, superheavies) and several masses are mass numbers, not weighted
      averages. Lanthanide and actinide ion charges list only +3.
- [ ] **Low** Catalog naming choices to double check: "Rust" for Fe₂O₃,
      "Milk of magnesia" for Mg(OH)₂ (technically a suspension), "Blue vitriol"
      wording on CuSO₄.
- [ ] **Low** The acid/base/salt picker has no metadata: acid strength (strong or
      weak), pKa, solubility, color, state at room temperature. The lab
      (milestone 3) needs all of it.
- [ ] **Low** Ammonium salts (NH₄Cl, NH₄NO₃) are missing from the picker because
      they need a polyatomic cation plus a separate anion.

## 3. Builder UI behavior

- [ ] **High** Drag and bond gestures have never been exercised in a real window,
      only the model logic behind them.
- [~] **Med** Undo/redo added (written, unverified), and Clear can be undone.
      Clear still has no confirmation.
- [ ] **Med** No save, load, export or share of molecules.
- [ ] **Med** Atoms can be dragged off the visible canvas and lost. No pan, zoom,
      or "fit to view". Large molecules overflow.
- [ ] **Med** Can't move a whole molecule at once, or select several atoms.
- [ ] **Med** Tool behavior is inconsistent: tapping empty canvas deselects only
      in Move mode. Bond order cycles single → double → triple → none, which
      can surprise a user who over-taps.
- [ ] **Med** Window sizing is untested. There is no minimum size, so a small
      window may squash the canvas to nothing (the add panel keeps a fixed
      aspect ratio).
- [ ] **Med** The info panel could suggest completions ("add one more H") rather
      than only listing what's missing.
- [ ] **Low** A new atom that can't bond to the selection is placed separately
      with no hint about why.
- [ ] **Low** `MoleculeReport.id` is the lowest atom ID, which changes when that
      atom is erased, so a card can flicker.
- [ ] **Low** `reports` is recomputed on every read and uses linear lookups.
      Fine now, slow past a hundred or so atoms.
- [ ] **Low** The picker's selected tab resets when the phone sheet is reopened.
- [ ] **Low** The periodic table has no element detail view, search, category
      legend, or placeholders at La/Ac in the main table.
- [ ] **Low** Substance cards have no search or filter (fine at ~20 per tab).

## 4. Safety messaging

- [ ] **Med** The first-launch sheet's dismissal behavior on macOS isn't verified
      (Esc may close it without accepting).
- [ ] **Med** The disclaimer acceptance is stored as a plain flag. If the wording
      changes, existing users won't see the new text. Store a version.
- [ ] **Low** Hazard colors (yellow for oxidizer on a light background) are
      untested for contrast, and nothing conveys hazard by shape alone for
      color-blind users beyond the SF Symbol.
- [ ] **Low** App Store review and age-rating implications of an app that shows
      hazardous reactions haven't been checked.

## 5. Accessibility and appearance

- [ ] **Med** The canvas is invisible to VoiceOver. Only the info panel is
      readable. Atoms and bonds need accessibility elements or a text summary.
- [ ] **Med** Valence state is shown by ring color alone (green, orange, red),
      plus a "+N" badge for open bonds.
- [ ] **Med** Dark mode has never been viewed. All snapshots were light.
- [ ] **Low** No keyboard navigation for the periodic table or canvas on Mac.
- [ ] **Low** Fixed font sizes on the canvas and table ignore Dynamic Type.
- [ ] **Low** All strings are hard-coded English (no localization). Spelling is
      now US, but check the docs and data for stragglers.

## 6. Tests

- [ ] **Med** Snapshot tests write images but compare nothing, so a layout
      regression would not fail a test. They are macOS-only (guarded by
      `#if os(macOS)`).
- [ ] **Med** No tests exercise the views or gestures.
- [ ] **Low** Test data is checked for internal consistency (unique formulas,
      valid structures) but not against an outside reference (real atomic
      masses, IUPAC names).

## 7. Milestone 3 checklist (lab engine): status

Written in `Sources/ChemLabCore/Lab/`, never compiled. See section 8 for what
it does not do.

- [~] Reaction data model with per-reaction hazards: `Reaction`, `ReactionTable`.
- [~] Ions and polyatomic ions: `Ion`, `IonCatalog`. These are used to build
      salts and work out solubility, but the *builder* still can't name ions
      (section 2), and the lab doesn't track free ions in solution.
- [~] States of matter, amounts (moles), concentration (molarity from the water
      present), temperature.
- [~] Activity series, solubility rules, acid/base strength (strong or weak
      only, no pKa) and a rough pH.
- [~] Equation balancing (`EquationBalancer`). Net ionic equations: not done.
- [~] Heat effects: phase change, decomposition thresholds, boiling plateau.
- [~] Learning layer: "why did that happen?" text on every reaction.

## 8. Lab engine and lab UI: known limitations

The lab is a set of curated rules, not a physical simulation. These are the
places where it is knowingly wrong or thin.

**Chemistry**

- [ ] **High** All reaction hazard text, "why" text and enthalpies were written
      from general knowledge, without sources. Enthalpies are rough teaching
      numbers. Have a chemist review `ReactionTable.swift`,
      `ReactionGenerator.swift` and the hazard notes in `SpeciesCatalog+*.swift`.
- [ ] **High** Hazards ignore concentration. Dilute sulfuric acid shows the same
      "destroys skin" note as concentrated. Reaction gates on concentration
      exist only for nitric and sulfuric acid (8 M threshold), and everything
      else is treated as either present or not.
- [ ] **Med** Reactions run to completion, in one step, limited only by the
      scarcer reactant. There is no equilibrium (weak acids, ammonia), no
      reaction rate, and no partial reaction.
- [ ] **Med** Everything that can react does so instantly the moment the last
      ingredient is added. Concentrated acid poured on metal cannot "start
      slowly", and nothing needs a catalyst (hydrogen peroxide decomposes only by
      heat here, not with MnO₂ or KI).
- [ ] **Med** Solubility is yes / slightly / no. There is no saturation limit, so
      any amount of a soluble salt dissolves in any amount of water. There is no
      temperature dependence either.
- [ ] **Med** Gases made by a reaction always bubble out, even soluble ones
      (ammonia, HCl), so they show up as toxic fumes. Dissolved gases don't leave
      solution when heated.
- [ ] **Med** Reagents are added neat or as a strength preset (`as sold`, `dilute`).
      Water is always 1 g/mL, and volumes of solutes are ignored.
- [ ] **Med** Nitric acid is excluded from the generic acid + metal rule. Only
      copper, silver and zinc have nitric acid reactions in the table. Other
      metals (Fe, Mg, Al, Pb, Ni) in nitric acid do nothing. Concentrated
      sulfuric acid reacts only with copper.
- [ ] **Med** Iron metal always becomes Fe²⁺ with acids and in displacement, and
      Fe²⁺ never oxidizes to Fe³⁺. Rusting and iron(III) chemistry only work if
      you add the iron(III) compounds yourself. Transition-metal complexes
      (the deep-blue copper–ammonia ion) are missing.
- [ ] **Med** No radicals in the lab either: NO₂ is a species, but the builder
      can't draw it (section 2).
- [ ] **Low** The heat model is crude: one heat capacity per substance class, no
      heat loss, no latent heat of melting, and an endothermic reaction can only
      cool the beaker by 25 °C at a time.
- [ ] **Low** Air is only oxygen (unlimited when the beaker is open). Nitrogen,
      CO₂ and humidity are ignored, so nothing reacts with air except burning.
- [ ] **Low** Aqueous ions are not tracked, so "spectator ions" are described in
      words but not drawn.

**Interface**

- [ ] **Med** Nothing has been seen in a real window. Expect layout problems:
      the shelf card grid, three beakers in the bench row, and the tool bar.
- [ ] **Med** Beaker drawing scales to a 250 mL capacity; large amounts overflow
      the drawing (the liquid stops at 92%) while the data keeps growing.
- [ ] **Med** Pouring is a menu, not a drag. There is no amount slider, and
      `Pour half` is the only partial option.
- [ ] **Med** The burner heats the *selected* beaker, so changing selection while
      it is on moves the flame. That is deliberate but unexplained in the UI.
- [ ] **Med** The animation timeline runs while gas is present or the burner is on.
      Three beakers redrawing at 30 fps may be heavy; check CPU use.
- [ ] **Med** The beaker view is one VoiceOver element with a text summary; the
      `BenchPanel` is readable, but the effects are not described.
- [ ] **Low** Hazard badges on a beaker are icons only. The reasons are in
      `BenchPanel`, which is one tap (select) away.
- [ ] **Low** The "safety" wording on the first-launch sheet doesn't mention that
      the lab can show reactions that are dangerous to reproduce. Consider adding
      a line at the top of the Lab tab.
- [ ] **Low** Progress is stored as JSON in `UserDefaults` with no version, so a
      change to `Encyclopedia`'s fields would silently drop saved progress.
- [ ] **Low** Challenge completion only checks the beaker the change happened in,
      and only after each action, so it can't see a beaker's state before an
      app relaunch (the beakers themselves are not saved).

## Fixed in the latest pass (needs the verification above)

- Formula display now follows convention: "H₂SO₄" and "NaCl", not Hill order
  ("H₂O₄S", "ClNa"). Hill order stays as the lookup key.
- Hazard text uses US spelling (colorless, odorless, vapor).
- Nitric acid and carbon monoxide are now representable (formal charges).
- Acids, bases and salts can be picked from the add panel.
