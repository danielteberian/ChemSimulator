# Substances to add

A tracking list of things that can be made in a chemistry lab, starting from
elements and common reagents. Written 2026-09-20 from general chemistry
knowledge. **No chemist has reviewed it, and I have not opened any of the links
in "Where to find more".** Routes are textbook-level summaries meant to seed the
guides in ROADMAP milestones 7 and 8, not lab instructions.

Legend: `[x]` already in the lab catalog · `[~]` only in the builder catalog, or
partly there · `[ ]` not in the app yet.

"In the app" was read from `SpeciesCatalog*.swift` and `CompoundCatalog*.swift`
today. Re-check it before ticking anything off.

## Left out on purpose

The full, running list is in [EXCLUSIONS.md](EXCLUSIONS.md). Summary:

Chemical-warfare agents (nerve and blister agents, phosgene) and controlled
drugs are not on this list, and there are no production guides for them. The app
is about learning chemistry, not about the jump to weapons or drugs, and that
jump isn't covered.

Substances that are also explosive but have ordinary uses are fine to list
(nitroglycerin as the angina drug glyceryl trinitrate, nitrocellulose, ammonium
nitrate as fertiliser, thermite, sodium in water). Their guides stay at the
level of the equation and what you observe, with no quantities or temperature
control written out. Primary explosives and military or improvised explosives
(TATP, HMTD, RDX, PETN, TNT and the like) stay out.

## Sections

1. Elements · 2. Gases · 3. Oxides · 4. Hydroxides and hydrides · 5. Acids ·
6. Salts by anion · 7. Coloured chemistry and complexes · 8. Oxidisers,
reducers and reagents · 9. Organic compounds · 10. Materials and products ·
11. Classic multi-step demonstrations · 12. Industrial routes ·
13. Where to find more · 14. Engine features these need

---

## 1. Elements (the form you would hold in a lab)

Route for all of them: extract or buy. In Fabricate mode (milestone 8) these are
the starting stock.

Alkali and alkaline earth
- [x] Li lithium · [x] Na sodium · [x] K potassium
- [ ] Rb rubidium · [ ] Cs caesium
- [ ] Be beryllium
- [x] Mg magnesium · [x] Ca calcium · [ ] Sr strontium · [x] Ba barium

Main-group and post-transition metals
- [x] Al aluminium · [x] Pb lead
- [ ] Ga gallium · [ ] In indium · [ ] Sn tin · [ ] Bi bismuth · [ ] Sb antimony
- [ ] Tl thallium (skip, very toxic)

Transition metals
- [ ] Ti · [ ] V · [ ] Cr chromium · [ ] Mn manganese
- [x] Fe iron · [ ] Co cobalt · [x] Ni nickel · [x] Cu copper · [x] Zn zinc
- [ ] Mo · [ ] W · [ ] Cd cadmium
- [x] Ag silver · [ ] Au gold · [ ] Pt platinum · [ ] Pd palladium · [ ] Hg mercury

Non-metals and metalloids
- [x] H₂ · [x] O₂ · [x] N₂ · [x] Cl₂ · [ ] F₂ · [ ] Br₂ · [ ] I₂
- [x] C carbon (graphite) · [ ] C diamond · [ ] C charcoal
- [x] S sulfur · [ ] P red phosphorus · [ ] P white phosphorus
- [ ] Si silicon · [ ] B boron · [ ] Se selenium · [ ] As arsenic (skip, toxic)
- [ ] He · [ ] Ne · [ ] Ar · [ ] Kr · [ ] Xe (inert, for completeness)
- [ ] O₃ ozone

## 2. Gases and volatile liquids

Made from: acid + metal (H₂), acid + carbonate (CO₂), burning, decomposition,
displacement from a salt. Route notes are per item.

- [x] H₂ hydrogen (Zn + HCl) · [x] O₂ (H₂O₂ over a catalyst, heating KClO₃)
- [x] N₂ · [x] CO₂ · [x] Cl₂ · [x] NH₃ · [x] CH₄
- [x] NO · [x] NO₂ (Cu + conc. HNO₃) · [x] N₂O · [x] SO₂ (S burnt in air)
- [x] H₂S (FeS + HCl)
- [ ] CO carbon monoxide (incomplete burning; formic acid + conc. H₂SO₄)
- [ ] HCl(g) (NaCl + conc. H₂SO₄) · [ ] HBr(g) · [ ] HI(g) · [ ] HF(g)
- [ ] N₂O₄ (NO₂ dimer, equilibrium) · [ ] N₂O₃ · [ ] N₂O₅
- [ ] SO₃ (SO₂ + O₂, catalyst) · [ ] PH₃ phosphine · [ ] SiH₄ silane
- [ ] O₃ ozone · [ ] H₂Se
- [ ] C₂H₆ ethane · [ ] C₃H₈ propane · [ ] C₄H₁₀ butane (all `[~]` in the builder)
- [ ] C₂H₄ ethene (ethanol + conc. H₂SO₄) · [ ] C₃H₆ propene
- [ ] C₂H₂ ethyne (CaC₂ + water) · [ ] CaC₂ calcium carbide
- [ ] CH₃Cl chloromethane · [ ] CS₂ carbon disulfide (liquid)
- [ ] Water vapour and steam as a state of H₂O (`[x]` as a boiling point)

## 3. Oxides

Route for most metal oxides: burn the metal in oxygen, heat the carbonate or
hydroxide (thermal decomposition), or roast the sulfide. Non-metal oxides:
burn the element.

Metal, ionic
- [ ] Li₂O · [ ] Na₂O · [ ] Na₂O₂ peroxide · [ ] KO₂ superoxide
- [x] MgO · [x] CaO · [ ] SrO · [ ] BaO · [ ] BaO₂ barium peroxide
- [x] Al₂O₃ · [x] ZnO · [x] CuO · [x] Fe₂O₃
- [ ] FeO · [ ] Fe₃O₄ magnetite · [ ] Cu₂O (Fehling's red precipitate)
- [ ] Ag₂O (AgNO₃ + NaOH) · [ ] PbO · [ ] PbO₂ · [ ] Pb₃O₄ red lead
- [ ] MnO₂ · [ ] Mn₂O₃ · [ ] Cr₂O₃ · [ ] CrO₃ · [ ] TiO₂ · [ ] SnO · [ ] SnO₂
- [ ] NiO · [ ] CoO · [ ] Co₃O₄ · [ ] HgO (Priestley's oxygen) · [ ] V₂O₅ · [ ] WO₃

Non-metal, covalent
- [x] H₂O · [x] H₂O₂ · [ ] SiO₂ silica · [ ] B₂O₃
- [ ] P₄O₁₀ · [ ] P₄O₆ · [ ] CO · [ ] SO₃
- [ ] Cl₂O · [ ] ClO₂ (unstable, low priority)

## 4. Hydroxides and hydrides

Hydroxides: metal oxide + water, or a soluble metal salt + NaOH (precipitation).

- [x] NaOH · [x] KOH · [x] LiOH · [x] Ca(OH)₂ · [x] Ba(OH)₂ · [x] Mg(OH)₂
- [x] Al(OH)₃ · [x] Zn(OH)₂ · [x] Fe(OH)₂ · [x] Fe(OH)₃ · [x] Cu(OH)₂ · [x] Ni(OH)₂
- [x] NH₃(aq) ammonia solution
- [ ] Sr(OH)₂ · [ ] Cr(OH)₃ · [ ] Mn(OH)₂ · [ ] Co(OH)₂ · [ ] Pb(OH)₂ · [ ] Sn(OH)₂
- [ ] Zn(OH)₄²⁻ zincate and Cu(OH)₄²⁻ (excess hydroxide; `Na[Al(OH)₄]` is `[x]`)

Hydrides: metal + hydrogen when heated.
- [ ] LiH · [ ] NaH · [ ] CaH₂ · [ ] LiAlH₄ · [ ] NaBH₄ (reducing agents)
- [x] NH₃ · [x] H₂S · [ ] PH₃ · [ ] SiH₄ · [ ] CH₄ (`[x]`)

## 5. Acids

Mineral acids
- [x] HCl · [x] HBr · [x] HI · [x] HNO₃ · [x] H₂SO₄ · [x] H₃PO₄
- [ ] HF (glass-etching; route CaF₂ + conc. H₂SO₄)
- [ ] H₂SO₃ sulfurous (SO₂ + water) · [ ] HNO₂ nitrous · [ ] H₂CO₃ carbonic
- [ ] HClO hypochlorous (Cl₂ + water) · [ ] HClO₃ · [ ] HClO₄ perchloric
- [ ] H₃BO₃ boric · [ ] H₃PO₃ phosphorous · [ ] H₂CrO₄ chromic · [ ] H₂S(aq)
- [ ] Aqua regia (mixture of HNO₃ and HCl, dissolves gold)

Organic acids
- [x] CH₃COOH acetic
- [ ] HCOOH formic · [ ] H₂C₂O₄ oxalic · [ ] C₆H₈O₇ citric · [ ] C₄H₆O₆ tartaric
- [ ] C₆H₈O₆ ascorbic (vitamin C) · [ ] C₃H₆O₃ lactic · [ ] C₇H₆O₂ benzoic
- [ ] C₇H₆O₃ salicylic · [ ] C₁₈H₃₆O₂ stearic · [ ] C₁₆H₃₂O₂ palmitic · [ ] C₄H₈O₂ butanoic

## 6. Salts by anion

Cations: Li⁺ Na⁺ K⁺ NH₄⁺ · Mg²⁺ Ca²⁺ Sr²⁺ Ba²⁺ · Al³⁺ · Zn²⁺ Fe²⁺ Fe³⁺ Cu²⁺
Ag⁺ Pb²⁺ Ni²⁺ Co²⁺ Mn²⁺ Cr³⁺ Sn²⁺ Hg²⁺ Cu⁺. Ions the app knows today:
H Li Na K NH₄ Ag · Mg Ca Ba Zn Fe(2) Ni Cu Pb · Al Fe(3) and F Cl Br I OH NO₃
CH₃COO HCO₃ ClO MnO₄ · S SO₄ CO₃ CrO₄ · PO₄. Adding a salt with a new cation or
anion means adding an ion first (`Ion.swift`).

Routes, by type:
- metal + acid → salt + H₂ (metals above H in the activity series)
- metal oxide or hydroxide + acid → salt + water
- carbonate + acid → salt + water + CO₂
- two soluble salts → an insoluble salt (precipitation), by the solubility rules
- direct combination of elements (Na + Cl₂, Fe + S)

### Chlorides
In app: NaCl KCl NH₄Cl CaCl₂ MgCl₂ BaCl₂ ZnCl₂ AlCl₃ FeCl₂ FeCl₃ CuCl₂ AgCl PbCl₂
- [ ] LiCl · [ ] SrCl₂ · [ ] NiCl₂ · [ ] CoCl₂ · [ ] MnCl₂ · [ ] CrCl₃ · [ ] SnCl₂
- [ ] SnCl₄ · [ ] CuCl · [ ] HgCl₂ · [ ] Hg₂Cl₂ · [ ] BiCl₃ · [ ] TiCl₄
- [ ] SiCl₄ · [ ] PCl₃ · [ ] PCl₅ · [ ] SOCl₂ (covalent chlorides, react with water)

### Bromides, iodides, fluorides
In app: NaBr KBr AgBr · KI AgI PbI₂
- [ ] LiBr · [ ] CaBr₂ · [ ] MgBr₂ · [ ] ZnBr₂ · [ ] CuBr · [ ] PbBr₂ · [ ] NH₄Br
- [ ] NaI · [ ] CaI₂ · [ ] ZnI₂ · [ ] CuI · [ ] HgI₂ · [ ] NH₄I · [ ] CHI₃ iodoform
- [ ] NaF · [ ] KF · [ ] CaF₂ fluorite · [ ] MgF₂ · [ ] AlF₃ · [ ] Na₃AlF₆ cryolite · [ ] NH₄F

### Sulfates
In app: Na₂SO₄ (NH₄)₂SO₄ MgSO₄ CaSO₄ BaSO₄ ZnSO₄ Al₂(SO₄)₃ FeSO₄ CuSO₄ PbSO₄
- [ ] Li₂SO₄ · [ ] K₂SO₄ · [ ] SrSO₄ · [ ] NiSO₄ · [ ] CoSO₄ · [ ] MnSO₄
- [ ] Fe₂(SO₄)₃ · [ ] Cr₂(SO₄)₃ · [ ] Ag₂SO₄ · [ ] Cu₂SO₄ · [ ] SnSO₄
- [ ] KAl(SO₄)₂ alum · [ ] (NH₄)₂Fe(SO₄)₂ Mohr's salt
- [ ] Hydrates: CuSO₄·5H₂O · MgSO₄·7H₂O Epsom · CaSO₄·2H₂O gypsum · CaSO₄·½H₂O
      plaster of Paris · FeSO₄·7H₂O · Na₂SO₄·10H₂O Glauber's (water of crystallisation)
- [ ] NaHSO₄ · [ ] KHSO₄ · [ ] Na₂SO₃ sulfite · [ ] NaHSO₃ · [ ] Na₂S₂O₃ thiosulfate

### Nitrates and nitrites
In app: NaNO₃ KNO₃ NH₄NO₃ AgNO₃ Ca(NO₃)₂ Mg(NO₃)₂ Zn(NO₃)₂ Cu(NO₃)₂ Pb(NO₃)₂
Al(NO₃)₃ Fe(NO₃)₃
- [ ] LiNO₃ · [ ] Sr(NO₃)₂ · [ ] Ba(NO₃)₂ · [ ] Ni(NO₃)₂ · [ ] Co(NO₃)₂ · [ ] Fe(NO₃)₂
- [ ] Mn(NO₃)₂ · [ ] Cr(NO₃)₃ · [ ] Hg(NO₃)₂ · [ ] Bi(NO₃)₃
- [ ] NaNO₂ · [ ] KNO₂ (thermal decomposition of nitrates gives nitrites and O₂)

### Carbonates and hydrogencarbonates
In app: Na₂CO₃ K₂CO₃ NaHCO₃ CaCO₃ MgCO₃ BaCO₃ ZnCO₃ CuCO₃
- [ ] Li₂CO₃ · [ ] (NH₄)₂CO₃ · [ ] SrCO₃ · [ ] FeCO₃ · [ ] NiCO₃ · [ ] MnCO₃
- [ ] PbCO₃ · [ ] Ag₂CO₃ · [ ] KHCO₃ · [ ] Ca(HCO₃)₂ (hard water, temporary)
- [ ] Malachite Cu₂CO₃(OH)₂ (green) · [ ] Trona and washing soda Na₂CO₃·10H₂O
- [ ] Basic lead carbonate (skip, toxic pigment)

### Sulfides
In app: FeS CuS ZnS PbS
- [ ] Na₂S · [ ] (NH₄)₂S · [ ] CaS · [ ] Ag₂S (tarnish) · [ ] NiS · [ ] CoS · [ ] MnS
- [ ] SnS · [ ] CdS (yellow pigment) · [ ] HgS · [ ] FeS₂ pyrite · [ ] Al₂S₃ · [ ] MoS₂

### Phosphates and phosphides
In app: Na₃PO₄ Ca₃(PO₄)₂
- [ ] K₃PO₄ · [ ] (NH₄)₃PO₄ · [ ] Na₂HPO₄ · [ ] NaH₂PO₄ · [ ] Mg₃(PO₄)₂
- [ ] AlPO₄ · [ ] FePO₄ · [ ] Ag₃PO₄ (yellow) · [ ] Zn₃(PO₄)₂ · [ ] Ca(H₂PO₄)₂
- [ ] Mg₃P₂ and Ca₃P₂ phosphides (release PH₃ in water)

### Other anions
In app: NaCH₃COO (acetate) · NaClO (hypochlorite)
- [ ] Acetates: KCH₃COO · Ca(CH₃COO)₂ · Cu(CH₃COO)₂ · Pb(CH₃COO)₂ · Zn(CH₃COO)₂ · NH₄CH₃COO
- [ ] Hypochlorite: Ca(ClO)₂ bleaching powder · LiClO
- [ ] Chlorate: NaClO₃ · KClO₃ · [ ] Perchlorate: KClO₄ · NH₄ClO₄ · Mg(ClO₄)₂ (desiccant)
- [ ] Bromate/iodate: KBrO₃ · KIO₃ · NaIO₄
- [ ] Borates: Na₂B₄O₇·10H₂O borax · Na₂B₄O₇ (borax bead tests)
- [ ] Silicates: Na₂SiO₃ water glass (silica garden) · CaSiO₃ · Mg₂SiO₄
- [ ] Cyanates and thiocyanates: KSCN · NH₄SCN · NH₄OCN (isomerises to urea)
- [ ] Nitrides and carbides: Mg₃N₂ · Li₃N · AlN · CaC₂ · Al₄C₃ · SiC · WC
- [ ] Peroxides and persulfates: Na₂O₂ · BaO₂ · (NH₄)₂S₂O₈ · Na₂S₂O₈ · sodium percarbonate
- [ ] Oxalates: Na₂C₂O₄ · CaC₂O₄ (kidney stones) · FeC₂O₄ · K₂C₂O₄
- [ ] Chromates and dichromates: K₂CrO₄ · Na₂CrO₄ · K₂Cr₂O₇ · PbCrO₄ chrome yellow · Ag₂CrO₄ · BaCrO₄
- [ ] Manganates and permanganates: KMnO₄ · K₂MnO₄ (the MnO₄⁻ ion exists, no salt yet)
- [ ] Hydroxide-carbonates and double salts: alums, Mohr's salt, Prussian blue (see 7)

## 7. Coloured chemistry and complexes

Good for the visual side of the lab, since each has a distinct colour or
precipitate. Route in brackets.

- [ ] [Cu(H₂O)₆]²⁺ pale blue (any Cu²⁺ salt in water; already the solution colour)
- [ ] [Cu(NH₃)₄]²⁺ deep blue (Cu²⁺ + excess NH₃)
- [ ] CuCl₄²⁻ yellow-green (Cu²⁺ in concentrated chloride)
- [ ] [Fe(SCN)]²⁺ blood red (Fe³⁺ + SCN⁻, test for Fe³⁺)
- [ ] Fe₄[Fe(CN)₆]₃ Prussian blue (Fe³⁺ + ferrocyanide) · K₃[Fe(CN)₆] · K₄[Fe(CN)₆]
- [ ] [Co(H₂O)₆]²⁺ pink and CoCl₄²⁻ blue (temperature equilibrium demo)
- [ ] [Ni(NH₃)₆]²⁺ blue-violet · Ni(DMG)₂ bright red (nickel test)
- [ ] [Ag(NH₃)₂]⁺ (dissolves AgCl in ammonia) · [ ] Tollens' reagent (silver mirror)
- [ ] Zn(OH)₄²⁻ and Al(OH)₄⁻ (amphoteric hydroxides in excess NaOH)
- [ ] [Cr(H₂O)₆]³⁺ violet/green · CrO₄²⁻ yellow ⇄ Cr₂O₇²⁻ orange (pH equilibrium)
- [ ] MnO₄⁻ purple → Mn²⁺ pale pink (permanganate titration) · MnO₄²⁻ green
- [ ] Iodine–starch blue-black · I₃⁻ triiodide (I₂ + KI, brown)
- [ ] Fehling's and Benedict's reagents (Cu²⁺ in tartrate or citrate; Cu₂O red on warming with a sugar)
- [ ] Biuret reagent (violet with protein) · Lugol's iodine
- [ ] Fluorescein, luminol (chemiluminescence), rhodamine (fluorescent organics, see 9)
- [ ] Flame-test colours per metal (Li red, Na yellow, K lilac, Ca orange-red,
      Sr crimson, Ba green, Cu blue-green): a display effect, not a substance

Precipitates worth showing (all from two solutions)
- [ ] PbI₂ golden yellow ("golden rain") · [x] AgCl white · [x] AgBr cream · [x] AgI yellow
- [ ] PbCrO₄ yellow · BaCrO₄ yellow · Ag₂CrO₄ brick red
- [ ] Fe(OH)₃ rust-brown `[x]` · Cu(OH)₂ blue `[x]` · Fe(OH)₂ green `[x]` · Ni(OH)₂ green `[x]`
- [ ] Cr(OH)₃ grey-green · Mn(OH)₂ off-white → brown · Co(OH)₂ blue-pink
- [ ] CdS yellow · ZnS white `[x]` · CuS black `[x]` · PbS black `[x]` · SnS brown
- [ ] BaSO₄ white `[x]` · CaCO₃ white `[x]` · Ca₃(PO₄)₂ white `[x]` · Ag₃PO₄ yellow

## 8. Oxidisers, reducers and reagents

Route: mostly bought. The interesting part is what they do, not how you make them.

Oxidising agents
- [x] H₂O₂ · [ ] KMnO₄ · [ ] K₂Cr₂O₇ · [ ] KClO₃ · [ ] KClO₄ · [ ] KIO₃ · [ ] KBrO₃
- [x] NaClO bleach · [ ] Ca(ClO)₂ · [ ] (NH₄)₂S₂O₈ · [ ] MnO₂ · [ ] PbO₂ · [ ] Br₂ water
- [ ] Conc. HNO₃ and conc. H₂SO₄ as oxidising acids (already `[x]`, hot conc. H₂SO₄ + Cu needs a rule)

Reducing agents
- [ ] Na₂S₂O₃ thiosulfate · [ ] Na₂SO₃ · [ ] NaHSO₃ · [ ] SnCl₂ · [ ] FeSO₄ (`[x]`)
- [ ] KI (`[x]`) · [ ] H₂C₂O₄ oxalic acid · [ ] Zn, Mg, Al as reducing metals (`[x]`)
- [ ] NaBH₄ · [ ] LiAlH₄ · [ ] Glucose (Tollens', Benedict's) · [ ] Ascorbic acid

Drying agents and desiccants
- [ ] CaCl₂ anhydrous · [ ] conc. H₂SO₄ · [ ] P₄O₁₀ · [ ] silica gel · [ ] CaO · [ ] MgSO₄ anhydrous

Indicators and buffers
- [ ] Litmus · [ ] phenolphthalein · [ ] methyl orange · [ ] bromothymol blue
- [ ] Universal indicator · [ ] red-cabbage indicator (anthocyanin) · [ ] turmeric
- [ ] Buffers: acetic acid/acetate · NH₃/NH₄Cl · carbonate/hydrogencarbonate · phosphate

## 9. Organic compounds

The builder already names a few dozen. The lab has almost none (CH₄, sucrose, acetic
acid). Route classes matter more than individual items, since one reaction rule
unlocks a whole family.

Hydrocarbons
- [~] C₂H₆ · [~] C₃H₈ · [~] C₄H₁₀ · [ ] C₅H₁₂ pentane · [ ] C₆H₁₄ hexane · [ ] C₈H₁₈ octane
- [ ] Cyclohexane · [~] C₂H₄ ethene · [ ] propene · [~] C₂H₂ ethyne
- [~] C₆H₆ benzene · [ ] toluene · [ ] naphthalene · [ ] styrene
- Route: cracking, dehydration of alcohols, decarboxylation (soda lime + acetate → CH₄)

Halogenoalkanes
- [ ] CH₃Cl · [ ] CH₂Cl₂ · [ ] CHCl₃ chloroform · [ ] CCl₄ · [ ] C₂H₅Br · [ ] CHI₃
- Route: alkane + halogen (light), alcohol + HX or PCl₅, haloform reaction

Alcohols and phenols
- [~] CH₃OH · [~] C₂H₅OH · [ ] 1-propanol · [ ] isopropanol · [ ] 1-butanol
- [ ] Ethylene glycol · [ ] Glycerol · [ ] Menthol · [ ] Phenol
- Route: fermentation of sugar, hydration of alkenes, hydrolysis of halogenoalkanes

Aldehydes and ketones
- [ ] HCHO formaldehyde · [ ] CH₃CHO acetaldehyde · [ ] Acetone · [ ] Benzaldehyde
- Route: oxidise a primary alcohol (aldehyde) or a secondary alcohol (ketone)

Carboxylic acids and esters
- [ ] Formic · [ ] propanoic · [ ] butanoic · [ ] benzoic (see 5)
- [ ] Ethyl acetate · [ ] methyl salicylate (wintergreen) · [ ] isoamyl acetate (banana)
- [ ] Ethyl butanoate (pineapple) · [ ] Aspirin (salicylic acid + acetic anhydride)
- Route: oxidise an alcohol or aldehyde; ester = acid + alcohol with an acid catalyst

Ethers, amines, amides
- [ ] Diethyl ether · [ ] Methylamine · [ ] Ethylamine · [ ] Aniline
- [ ] Urea CO(NH₂)₂ (Wöhler, from ammonium cyanate) · [ ] Acetamide · [ ] Paracetamol
- Route: amine + acid → amide; reduce a nitro compound to an amine

Carbohydrates, fats, proteins
- [x] Sucrose · [~] Glucose · [ ] Fructose · [ ] Lactose · [ ] Starch · [ ] Cellulose
- [ ] Glycerol · [ ] Triglycerides (vegetable oil) · [ ] Fatty acids
- [ ] Amino acids: glycine, alanine, cysteine · [ ] Peptide bond formation

Medicines and organic nitrates (route: esterify an alcohol or glycerol with a nitrating acid)
- [ ] Glyceryl trinitrate (nitroglycerin, the angina drug) from glycerol · [ ] Amyl nitrite
- [ ] Isosorbide dinitrate · [ ] Nitrocellulose (collodion, celluloid, lacquer)
- [ ] Aspirin (`[ ]` above) · [ ] Paracetamol · [ ] Caffeine (extraction) · [ ] Ethanol as an antiseptic
- Guides for these show the equation and what you observe, not quantities or conditions.

Dyes and pigments
- [ ] Methyl orange (azo coupling) · [ ] Indigo · [ ] Fluorescein · [ ] Phenolphthalein
- [ ] Malachite green · [ ] Luminol · [ ] Anthocyanins · [ ] Caramel

## 10. Materials and products

- [ ] Soap (saponification): sodium stearate from fat + NaOH; glycerol as by-product
- [ ] Biodiesel: methyl esters from oil + methanol + NaOH
- [ ] Polymers: polyethylene · polystyrene · PVC · PET · nylon-6,6 ("rope trick") ·
      Bakelite · polyvinyl alcohol "slime" with borax · polyurethane foam
- [ ] Glass (soda-lime, from Na₂CO₃ + CaCO₃ + SiO₂) · borosilicate
- [ ] Cement, lime mortar, plaster of Paris, concrete curing (Ca(OH)₂ + CO₂ → CaCO₃)
- [ ] Alloys: brass (Cu + Zn), bronze (Cu + Sn), solder (Sn + Pb), steel (Fe + C), amalgams
- [ ] Ceramics: MgO, Al₂O₃, SiC; superconductors and semiconductors (Si, GaAs)
- [ ] Fertilisers: NH₄NO₃ `[x]`, (NH₄)₂SO₄ `[x]`, KNO₃ `[x]`, urea, superphosphate
- [ ] Cleaning products: bleach, baking soda, washing soda, vinegar, ammonia cleaner
- [ ] Food chemistry: baking powder (NaHCO₃ + cream of tartar), caramelisation, fermentation
- [ ] Batteries and cells: Daniell cell (Zn|Cu), lemon battery, lead-acid, electrolysis of water
- [ ] Fire-and-light: burning Mg, thermite (Fe₂O₃ + Al), sparkler-style metal burns,
      luminol glow, glow-stick chemistry, hydrogen "pop" test

## 11. Classic multi-step demonstrations

Good candidates for hand-written guides (milestone 7), because each shows several
reaction types in a row.

- [ ] The copper cycle: Cu → Cu(NO₃)₂ → Cu(OH)₂ → CuO → CuSO₄ → Cu
- [ ] The lime cycle: CaCO₃ → CaO → Ca(OH)₂ → CaCO₃ (limewater going cloudy)
- [ ] Silver mirror (Tollens') · [ ] Blue-bottle reaction
- [ ] Iodine clock (thiosulfate, or vitamin C and peroxide) · [ ] Briggs–Rauscher oscillator
- [ ] Belousov–Zhabotinsky oscillating reaction
- [ ] "Elephant toothpaste" (H₂O₂ decomposition with KI or yeast)
- [ ] Baking-soda-and-vinegar volcano (`[x]` as a challenge) · [ ] Dry ice in water
- [ ] Sodium in water · potassium in water · calcium in water (`[x]`, part of the lab)
- [ ] Thermite · [ ] Magnesium burning · [ ] Iron wool burning
- [ ] Ammonia fountain (NH₃ + water) · [ ] Blue-to-red litmus with acid rain gases (SO₂, CO₂)
- [ ] Nylon rope trick · [ ] Silica garden (water glass + metal salts) · [ ] Crystal growing (alum, CuSO₄, NaCl, sugar)
- [ ] Chromatography of inks or spinach (a separation step, needed for milestone 8)
- [ ] Titration: NaOH against HCl with an indicator · KMnO₄ against oxalate
- [ ] Qualitative analysis: identify an unknown salt from flame test, precipitates and gas tests
- [ ] Testing gases: H₂ pops, O₂ relights a splint, CO₂ clouds limewater, NH₃ turns litmus blue, Cl₂ bleaches litmus

## 12. Industrial routes (conceptual only)

For a "how the world makes it" panel. These are the big processes, taught at
textbook level. They aren't things a learner would do at a bench.

- [ ] Haber–Bosch: N₂ + 3H₂ ⇌ 2NH₃ (iron catalyst, high pressure)
- [ ] Ostwald: NH₃ → NO → NO₂ → HNO₃
- [ ] Contact: S → SO₂ → SO₃ → H₂SO₄ (V₂O₅ catalyst)
- [ ] Solvay: NaCl + NH₃ + CO₂ + H₂O → NaHCO₃ → Na₂CO₃
- [ ] Chlor-alkali: electrolysis of brine → Cl₂ + H₂ + NaOH
- [ ] Hall–Héroult: Al₂O₃ in molten cryolite → Al
- [ ] Bayer: bauxite → Al₂O₃ (uses NaOH, gives Na[Al(OH)₄] `[x]`)
- [ ] Blast furnace: Fe₂O₃ + CO → Fe · [ ] Steelmaking
- [ ] Lime kiln, cement kiln · [ ] Smelting Cu, Zn, Pb from sulfide ores
- [ ] Steam reforming (CH₄ + H₂O → CO + 3H₂) · [ ] Fischer–Tropsch
- [ ] Cracking and reforming of petroleum

## 13. Where to find more

I have not opened these links in this session. They are the places I would look,
from memory, so check each one before relying on it.

**Big compound and property databases**
- PubChem (pubchem.ncbi.nlm.nih.gov): millions of compounds, with GHS hazard data,
  melting and boiling points, and a free REST API (PUG REST). The best single source
  for names, formulas and hazard pictograms.
- NIST Chemistry WebBook (webbook.nist.gov): enthalpies of formation, phase-change
  data, spectra. Feeds the heat numbers in the reaction table.
- CAMEO Chemicals (cameochemicals.noaa.gov): NOAA's reactivity database. It has a
  "what happens if I mix A and B" tool, which is close to what the lab does.
- ChemSpider (chemspider.com) · ChEBI (ebi.ac.uk/chebi) for biologically relevant
  compounds · Wikidata for cross-links.
- Crystallography Open Database (crystallography.net) and Materials Project
  (materialsproject.org) for solids and minerals.

**Reference books, for what really happens in a flask**
- Greenwood & Earnshaw, *Chemistry of the Elements*: element-by-element inorganic chemistry.
- CRC Handbook of Chemistry and Physics: constants, solubility, standard potentials.
- Vogel's *Textbook of Practical Organic Chemistry* and *Qualitative Inorganic
  Analysis*: classic lab preparations and tests for ions.
- Shakhashiri, *Chemical Demonstrations* (four volumes): the standard demo handbook.
- *Organic Syntheses* (orgsyn.org) and *Inorganic Syntheses*: checked preparations.
- The Merck Index: compounds by name, with uses.

**Free teaching material, good for lists of "the reactions students do"**
- LibreTexts Chemistry (chem.libretexts.org) and OpenStax Chemistry 2e (openstax.org):
  full textbooks, including solubility rules and the activity series.
- Royal Society of Chemistry education site (edu.rsc.org), "Classic chemistry
  demonstrations" and the Learn Chemistry practicals.
- *Journal of Chemical Education* (pubs.acs.org/journal/jceda8), "Tested
  Demonstrations" column, and the ACS educational resources.
- Flinn Scientific and Carolina Biological lab guides and safety data sheets.
- The practical lists in GCSE, A-level, AP and IB Chemistry syllabuses: a ready-made
  list of the substances and reactions learners meet.

**Lists on Wikipedia worth mining**
- "List of inorganic compounds", "Lists of compounds", "List of organic compounds",
  "List of named reactions", "List of chemical reactions (by type)",
  "Category: Inorganic compounds", and the per-element pages, whose "Compounds"
  sections list oxides, halides and common salts.
- "List of laboratory reagents" style pages, "Qualitative inorganic analysis",
  "Flame test", "Solubility chart", "Standard electrode potential (data page)".

**Reaction data sets, if the list should be generated instead of typed**
- Open Reaction Database (open-reaction-database.org) and the USPTO reaction data
  (from patents, mostly organic): real reactions with conditions.
- Rhea (rhea-db.org) for biochemical reactions.
- RDKit and Open Babel: parse and validate structures and balance checks.
- Materials Project and OQMD for inorganic formation energies.

**Suggested method for growing this list**
1. Pick a class (say, all chlorides of the metals the app knows). Add the ion first.
2. Add the species with melting point, colour, and its role, as `SpeciesCatalog+Compounds` does.
3. Add reaction rules only where the generic rules can't reach it (redox, complexes).
4. Add a recipe (milestone 7) and a challenge so it is usable.
5. Tick it here, and write the date and the source you used in the commit.

## 14. Engine features these need

Adding names is the easy part. Whole groups of the list above stay out of reach
until the engine can do these:

- Variable oxidation states and redox balancing: Fe²⁺/Fe³⁺, Cu⁺/Cu²⁺, MnO₄⁻ → Mn²⁺,
  Cr₂O₇²⁻ → Cr³⁺, Sn²⁺/Sn⁴⁺. Half-reactions and standard potentials would drive this.
- Complex ions with ligands (NH₃, Cl⁻, SCN⁻, CN⁻, OH⁻): colour change on adding ligand.
- Equilibria and Le Chatelier: CrO₄²⁻ ⇌ Cr₂O₇²⁻, Co²⁺ chloride/aqua, N₂O₄ ⇌ NO₂,
  Haber. Reactions that go both ways, and temperature and concentration shifts.
- Electrochemistry: electrolysis (water, brine, CuSO₄ with copper electrodes) and
  galvanic cells.
- Hydrates: water of crystallisation, efflorescence, dehydration on heating.
- Organic reaction rules by functional group: alcohol oxidation, esterification and
  hydrolysis, halogenation, addition to alkenes, saponification, polymerisation.
  A structure-based matcher (the builder has the graph) would beat listing every compound.
- Kinetics for the timed demos (iodine clock, oscillators): rate depends on
  concentration and temperature over time, not just "reacts or doesn't".
- Separation steps (filter, distil, evaporate, collect gas): shared with milestone 8.
- Mixtures and concentrations beyond "dilute or concentrated": molarity, dilution,
  and titration.
