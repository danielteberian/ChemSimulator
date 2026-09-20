# ChemLab Roadmap

Legend: `[x]` done, `[~]` in progress, `[ ]` not started.

## Milestone 1 — Core `[x]`
- [x] 118 elements with mass, electronegativity, valences, ion charges
- [x] Molecule graph with valence validation
- [x] Hill formulas + parser
- [x] Naming: catalog (~50 compounds) + systematic generator
- [x] Hazard tags (the disclaimer text was removed on 2026-09-20)

## Milestone 2 — Molecule builder UI `[~]` (macOS done, iOS and polish left)
- [x] Roadmap, package restructure (`ChemLabCore`, `ChemLabUI`, `ChemLab` app)
- [x] Periodic table layout data (core, tested)
- [x] `BuilderModel`: add/move/bond/erase, auto-bond to selection (13 tests)
- [x] Periodic table picker (all 118, f-block rows, category colours)
- [x] Molecule canvas: atoms, 1–3 order bonds, valence rings, "+N" open-bond badges
- [x] Info panel: name, formula, aliases, molar mass, hazard badges with reasons
- [x] First-launch disclaimer + About/Safety screen (removed 2026-09-20, milestone 6)
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

## Milestone 6 — Simplify and smooth `[ ]` (added 2026-09-20, from you)
- [x] Remove the warning stuff (done 2026-09-20). Deleted `DisclaimerView` and
      `SafetyDisclaimer`, the first-launch sheet, both "About & Safety" buttons,
      the footer notices in the builder, lab and learn views, and the "not
      reviewed / not safe" and "dangerous in real life" text.
- [x] Show hazard icons only, with no explanations (done 2026-09-20: `HazardRow` is now `HazardIcons`, icons only). Drop the reason text from the
      badges in `InfoPanel`, `BenchPanel`, the beaker callouts and the
      encyclopedia. The icons stay; the hazard data and its reasons can stay in
      `Hazards.swift` for later. Still never block an experiment.
- [ ] Make the app feel smoother. Candidates, none measured yet: animate state
      changes (pouring, adding, temperature, fill level, panel switches), keep
      `mix()` fast (cache `ReactionGenerator` output by species set; see
      `ISSUES.md` section 0), avoid redrawing the whole beaker `Canvas` on every
      change, and drag-and-drop pouring instead of the menu. First find out
      where it feels rough (which action, which tab).

Follow-up when these land: the principle below says "explain everything" and
`ISSUES.md` sections 2 and 4 discuss reasons and disclaimers, so update them.

## Milestone 7 — "How do I make this?" guides `[ ]` (added 2026-09-20, from you)
Follow-along guides so a learner can produce each substance in the lab. Which
substances exist to be made is tracked in [SUBSTANCES.md](SUBSTANCES.md).
- [ ] Recipe data model: target, starting materials with amounts, ordered steps
      (add, heat, cool, stir, filter, evaporate, collect gas), what you should
      see after each step, and the "why" for each. Hazards show as icons only.
- [ ] Route finder: search backwards through `ReactionTable` and
      `ReactionGenerator` from a target to elements or stock reagents, and offer
      alternative routes (for example CuSO4 from Cu + H2SO4, or from CuO + H2SO4).
- [ ] Test every recipe by running it in a `Beaker`, the way challenges already
      check their `solution`, so a guide can never describe a reaction the
      engine wouldn't do.
- [ ] Guide UI: a "Make this" button on shelf, encyclopedia and info-panel
      entries. A step-by-step panel in the Lab that highlights the shelf item
      and amount for the current step and ticks steps off as you do them.
- [ ] Help levels: full walkthrough, hints only, or none.
- [ ] Hand-written recipes for the multi-step classics (copper cycle, lime
      cycle, silver mirror, iodine clock, nylon rope trick, soap, biodiesel).

## Milestone 8 — Make-it-yourself mode `[ ]` (added 2026-09-20, from you)
A mode where you can't just pick anything off the shelf: you make it, keep it,
and use it for the next reaction.
- [ ] Mode switch: Sandbox (today's unlimited shelf) and Fabricate.
- [ ] Stockroom for Fabricate: elements plus water and air. Everything else has
      to be made. Make the starting stock configurable.
- [ ] Separation and handling steps the engine lacks today: filter, decant,
      dissolve, evaporate and crystallise, distil, dry, collect a gas in a jar,
      weigh, transfer. `Beaker` has only add, pour, heat, cover and run.
- [ ] Inventory of labelled jars and bottles (species, grams, state), saved
      between launches next to the `Encyclopedia`. In Fabricate the shelf shows
      the inventory, and using something uses it up.
- [ ] Yield and purity: real yield below theoretical, and impurities carried
      into the next step (optional, later).
- [ ] Unlock map: a graph of what you've made and what it opens up.
- [ ] Tie challenges in ("make copper sulfate starting from copper").

## Milestone 9 — Many more substances `[ ]` (added 2026-09-20, from you)
- [ ] Work through [SUBSTANCES.md](SUBSTANCES.md), which lists what's in the app,
      what's missing, and where to look for more.
      What was left out, and how detailed some guides may be, is in
      [EXCLUSIONS.md](EXCLUSIONS.md).
- [ ] Engine features that the new substances need: variable oxidation states
      and redox balancing, complex ions, equilibria (Le Chatelier), electrolysis
      and cells, organic reaction rules (esterification, oxidation of alcohols,
      polymerisation, saponification), hydrates and dehydration.

## Milestone 10 — Test cases `[ ]` (added 2026-09-20, from you)
Nothing has been run since the lab was written, and the test target doesn't
compile yet, so the first two items come before any new tests.
- [ ] Make the test target compile. `LabModelTests.swift` has a "call can throw"
      error inside `#expect`. Then run the suite once (only when you say so) and
      fix what fails.
- [ ] Check the removed warnings stay removed: no disclaimer view or text in the
      builder, lab or learn screens, and hazards render as icons with no reason
      text (a snapshot test, or a test on `HazardIcons`).
- [ ] Substance data: every species in `SpeciesCatalog` has a name, formula, colour
      and a melting point where it makes sense. No duplicate formulas. Every
      reaction in the table balances. Every ion pair gives the right formula and
      charge.
- [ ] One test per new substance batch from [SUBSTANCES.md](SUBSTANCES.md), covering
      its route (the reaction that makes it), its solubility, and its colour.
- [ ] Recipes (milestone 7): every recipe runs in a `Beaker` and ends with the
      target present. The route finder returns a route for every target that has
      one, and none for elements. Steps are in a valid order.
- [ ] Guide progress: doing a step ticks it off, doing the wrong step doesn't, and
      the guide notices when the target already exists.
- [ ] Fabricate mode (milestone 8): using an ingredient uses it up from the
      inventory; the shelf shows only what you've made plus the stockroom; filter,
      evaporate, distil and gas collection give the right amounts; inventory
      survives save and load.
- [ ] Engine features as they land (redox, complexes, equilibria, hydrates,
      organic rules): a balanced-equation test and an example per feature.
- [ ] Never-block rule: a test that mixes every pair of shelf items and asserts
      nothing is refused (it can be slow, so run it on a sample).
- [ ] Performance: a timing test for `mix()` on a full beaker, so the caching
      work in milestone 6 has a number to beat.
- [ ] Snapshot tests for each new screen (guide panel, inventory, unlock map).
- [ ] iOS compact-layout snapshots, once the iOS target exists.

## Principle: experiment freely, explain everything

Users can build and mix anything, including dangerous things. The app never
blocks an experiment. It shows a hazard badge and says *why* it is dangerous,
because seeing what goes wrong and understanding it is the point. The
simulation disclaimer stays visible (see `SafetyDisclaimer`).
