/// Entries for the acids, bases and salts in `SubstanceLibrary` that the main
/// catalog doesn't already cover. Hazard notes are written for learners and
/// have not been reviewed by a chemist.
extension CompoundCatalog {
    static let acidsBasesSalts: [KnownCompound] = [
        // Acids
        KnownCompound("HBr", "Hydrogen bromide", systematic: "hydrogen bromide",
            aliases: ["Hydrobromic acid (in water)"],
            hazards: [HazardNote(.corrosive, "Burns skin and eyes."),
                      HazardNote(.toxic, "The gas damages the airways.")]),
        KnownCompound("HI", "Hydrogen iodide", systematic: "hydrogen iodide",
            aliases: ["Hydroiodic acid (in water)"],
            hazards: [HazardNote(.corrosive, "Burns skin and eyes.")]),
        KnownCompound("H2CO3", "Carbonic acid", systematic: "dihydrogen carbonate",
            aliases: ["The acid in soda water"]),
        KnownCompound("HCOOH", "Formic acid", systematic: "methanoic acid",
            aliases: ["The acid in ant stings"],
            hazards: [HazardNote(.corrosive, "Burns skin and eyes."),
                      HazardNote(.flammable, "Vapor ignites when warm.")]),
        KnownCompound("B(OH)3", "Boric acid", systematic: "trihydrogen borate",
            hazards: [HazardNote(.healthHazard, "Can harm fertility and development with heavy exposure.")]),

        // Bases
        KnownCompound("LiOH", "Lithium hydroxide", systematic: "lithium hydroxide",
            hazards: [HazardNote(.corrosive, "Burns skin and eyes.")]),
        KnownCompound("Ba(OH)2", "Barium hydroxide", systematic: "barium hydroxide",
            hazards: [HazardNote(.corrosive, "Burns skin and eyes."),
                      HazardNote(.toxic, "Soluble barium compounds are poisonous.")]),
        KnownCompound("Al(OH)3", "Aluminum hydroxide", systematic: "aluminum hydroxide",
            aliases: ["Alumina trihydrate"]),
        KnownCompound("Cu(OH)2", "Copper(II) hydroxide", systematic: "copper(II) hydroxide",
            hazards: [HazardNote(.irritant, "Harmful if swallowed and irritates the eyes."),
                      HazardNote(.environmental, "Very toxic to aquatic life.")]),

        // Salts
        KnownCompound("FeCl3", "Iron(III) chloride", systematic: "iron(III) chloride",
            aliases: ["Ferric chloride"],
            hazards: [HazardNote(.corrosive, "Burns skin and eyes; its solutions are acidic.")]),
        KnownCompound("CuCl2", "Copper(II) chloride", systematic: "copper(II) chloride",
            hazards: [HazardNote(.irritant, "Harmful if swallowed and irritates skin and eyes."),
                      HazardNote(.environmental, "Very toxic to aquatic life.")]),
        KnownCompound("Na2SO4", "Sodium sulfate", systematic: "sodium sulfate",
            aliases: ["Glauber's salt (as the hydrate)"]),
        KnownCompound("MgSO4", "Magnesium sulfate", systematic: "magnesium sulfate",
            aliases: ["Epsom salt (as the hydrate)"]),
        KnownCompound("BaSO4", "Barium sulfate", systematic: "barium sulfate",
            aliases: ["Barite"]),
        KnownCompound("KNO3", "Potassium nitrate", systematic: "potassium nitrate",
            aliases: ["Saltpeter"],
            hazards: [HazardNote(.oxidizer, "Makes combustible materials burn fiercely.")]),
        KnownCompound("NaNO3", "Sodium nitrate", systematic: "sodium nitrate",
            aliases: ["Chile saltpeter"],
            hazards: [HazardNote(.oxidizer, "Makes combustible materials burn fiercely.")]),
        KnownCompound("NaOCl", "Sodium hypochlorite", systematic: "sodium hypochlorite",
            aliases: ["Bleach (in water)"],
            hazards: [HazardNote(.corrosive, "Burns skin and eyes."),
                      HazardNote(.toxic, "Releases poisonous chlorine gas if mixed with acids."),
                      HazardNote(.environmental, "Very toxic to aquatic life.")]),
    ]
}
