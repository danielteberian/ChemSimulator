# What I've left out, and why

A running list of what Claude has declined to add to ChemLab's substance list or
in-app guides, kept so the owner can see every call and overturn any of them.
Add to it whenever something new is left out, with the date. Started 2026-09-20.

**Scope.** This is about the substance list ([SUBSTANCES.md](SUBSTANCES.md)) and
the "how do I make this?" guides (ROADMAP milestones 7 and 8). It is not about
mixing. The lab never blocks an experiment, and dangerous things that are on the
list mix freely with hazards shown as icons.

**Who decided.** These are my (Claude's) calls, not the owner's. The owner asked
for a list that is "as close to comprehensive as possible", and disagreed with
the one that matters most below (item 1 under "Limited detail"). Where the owner
overrules one of these, change the entry and record what they said.

## 1. Not listed, and no guides

**Chemical-warfare agents**
- Nerve agents (the G-series such as sarin, the V-series such as VX, Novichok).
- Blister agents (sulfur mustard, nitrogen mustards, lewisite).
- Choking and blood agents made or used as weapons (phosgene, diphosgene, cyanogen
  chloride, hydrogen cyanide as a weapon).
- Their direct precursors and the chemistry that leads to them.
- Not excluded: chlorine, hydrogen sulfide, nitrogen dioxide, ammonia and other
  common lab gases. They are on the list as ordinary lab chemistry.

**Primary and military or improvised explosives**
- Peroxide explosives: TATP, HMTD, and similar organic peroxides.
- Fulminates and azides: mercury fulminate, silver fulminate, lead azide, silver azide.
- Nitrogen triiodide and other contact explosives.
- Military and commercial high explosives: RDX, HMX, PETN, TNT, tetryl, picric acid
  and its salts, dynamite formulations, plastic explosives.
- Improvised mixtures: ANFO, chlorate/sugar and perchlorate mixtures, flash powder,
  black powder, and similar pyrotechnic compositions.
- Detonators, initiators and anything about making a substance explode on purpose.
- Not excluded: ammonium nitrate, potassium nitrate, chlorates and perchlorates as
  ordinary salts, thermite, hydrogen and oxygen, alkali metals in water, magnesium
  burning. They are on the list.

**Controlled drugs**
- Opioids and their synthesis, amphetamines and methamphetamine, MDMA, cocaine,
  LSD, GHB, PCP, synthetic cannabinoids and cathinones, and similar.
- Precursor-to-drug routes. Red phosphorus, iodine, ephedrine-type compounds and
  the like are on the list only as elements or ordinary substances, with no guide
  that leads toward a drug.
- Not excluded: aspirin, paracetamol, caffeine, ethanol, glucose, vitamins.

**Skipped as too hazardous for what they add (my judgement, open to change)**
- Thallium and arsenic as elements and their compounds.
- Basic lead carbonate ("white lead").
- Hydrazine and other rocket propellants.
- Piranha solution (hot H₂SO₄ + H₂O₂).
- Tollens' reagent is listed, but its guide would have to say the mixture must be
  used at once (it can form an explosive silver compound on standing).
- HCN and cyanide salts as things to make (the ferro- and ferricyanide complexes
  in Prussian blue are listed, since they are not free cyanide).
- Chlorine oxides (Cl₂O, ClO₂): unstable, low priority. That is a priority call as
  much as a safety one.

## 2. Listed, but guides limited in detail

1. **Nitroglycerin (glyceryl trinitrate)**, amyl nitrite, isosorbide dinitrate,
   nitrocellulose. They have real uses (angina medication, lacquer, collodion,
   celluloid), and the owner said they are fine to produce. They are on the list
   and the engine can model the reaction. Their guides show the equation, what to
   add, what you would observe and why. They do **not** give acid ratios,
   quantities, temperatures or cooling and handling details, because those are what
   would make the entry a working recipe for a high explosive.
   - **Owner's view (2026-09-20):** wanted full guides, since it is a legitimate
     substance and the owner asked for it ("they are things you can make and have
     legitimate uses, plus I told you to"). Claude declined the quantities and
     temperature control and offered the qualitative version. Unresolved. Revisit
     if the owner wants to push on it.
2. Any other substance that is a legitimate product and also dual-use gets the
   same rule: the equation and observations, without conditions or amounts that
   would make it a working recipe for something on the list above.

## 3. Not decided yet

Things I haven't put on either side because they weren't on the list I wrote.
Decide each as it comes up.
- Household-chemical mixtures that release toxic gas (bleach + ammonia,
  bleach + acid). They are reactions to simulate, not substances to make, so the
  lab handles them like any mixing.
- Solid rocket propellant, fireworks and sparklers as recipes.
- Pesticides and herbicides.
- Radioactive elements and isotopes, and anything about enrichment.

## Change log
- 2026-09-20: created. Decisions 1 and 2 above made in conversation. The owner
  loosened the first version (explosive-capable substances with ordinary uses,
  such as nitroglycerin, are now listed) and pushed for full nitroglycerin guides.
  Claude kept the quantities and conditions out.
