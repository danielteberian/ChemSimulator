/// Common acids, bases, salts, gases, oxides and organics for the builder's picker.
///
/// Structures are drawn the way textbooks draw the bonding. Ionic compounds are
/// shown as bond graphs (Na-Cl), which is a simplification: real salts are
/// lattices of ions. Every structure must satisfy the valence rules; the tests
/// check that each one is complete and has a name.
public enum SubstanceLibrary {
    public static let all: [CommonSubstance] = acids + bases + salts + gases + oxides + organics

    public static func substances(in group: CommonSubstance.Group) -> [CommonSubstance] {
        all.filter { $0.group == group }
    }
}

extension SubstanceLibrary {
    static let acids: [CommonSubstance] = [
        CommonSubstance(.acid, "H-Cl"),
        CommonSubstance(.acid, "H-Br"),
        CommonSubstance(.acid, "H-I"),
        CommonSubstance(.acid, "H-F"),
        CommonSubstance(.acid, "H-O-S(=O)(=O)-O-H"),  // sulfuric
        CommonSubstance(.acid, "H-O-[N+](=O)-[O-]"),  // nitric
        CommonSubstance(.acid, "O=P(-O-H)(-O-H)-O-H"),  // phosphoric
        CommonSubstance(.acid, "H-C(-H)(-H)-C(=O)-O-H"),  // acetic
        CommonSubstance(.acid, "O=C(-O-H)-O-H"),  // carbonic
        CommonSubstance(.acid, "H-C(=O)-O-H"),  // formic
        CommonSubstance(.acid, "B(-O-H)(-O-H)-O-H"),  // boric
        CommonSubstance(.acid, "H-S-H"),  // hydrogen sulfide
    ]

    static let bases: [CommonSubstance] = [
        CommonSubstance(.base, "Na-O-H"),
        CommonSubstance(.base, "K-O-H"),
        CommonSubstance(.base, "Li-O-H"),
        CommonSubstance(.base, "H-O-Ca-O-H"),
        CommonSubstance(.base, "H-O-Mg-O-H"),
        CommonSubstance(.base, "H-O-Ba-O-H"),
        CommonSubstance(.base, "H-N(-H)-H"),  // ammonia
        CommonSubstance(.base, "Al(-O-H)(-O-H)-O-H"),
        CommonSubstance(.base, "H-O-Cu-O-H"),
        CommonSubstance(.base, "Na-O-C(=O)-O-H"),  // baking soda
        CommonSubstance(.base, "Na-O-C(=O)-O-Na"),  // washing soda
        CommonSubstance(.base, "Ca=O"),  // quicklime
    ]

    static let salts: [CommonSubstance] = [
        CommonSubstance(.salt, "Na-Cl"),
        CommonSubstance(.salt, "K-Cl"),
        CommonSubstance(.salt, "K-I"),
        CommonSubstance(.salt, "Cl-Ca-Cl"),
        CommonSubstance(.salt, "Cl-Mg-Cl"),
        CommonSubstance(.salt, "Ag-Cl"),
        CommonSubstance(.salt, "Cl-Fe(-Cl)-Cl"),
        CommonSubstance(.salt, "Cl-Cu-Cl"),
        CommonSubstance(.salt, "Na-O-S(=O)(=O)-O-Na"),  // sodium sulfate
        CommonSubstance(.salt, "Cu1-O-S(=O)(=O)-O1"),  // copper sulfate
        CommonSubstance(.salt, "Mg1-O-S(=O)(=O)-O1"),  // magnesium sulfate
        CommonSubstance(.salt, "Ba1-O-S(=O)(=O)-O1"),  // barium sulfate
        CommonSubstance(.salt, "Ca1-O-C(=O)-O1"),  // calcium carbonate
        CommonSubstance(.salt, "K-O-[N+](=O)-[O-]"),  // potassium nitrate
        CommonSubstance(.salt, "Na-O-[N+](=O)-[O-]"),  // sodium nitrate
        CommonSubstance(.salt, "Ag-O-[N+](=O)-[O-]"),  // silver nitrate
        CommonSubstance(.salt, "[O-]-[N+](=O)-O-Cu-O-[N+](=O)-[O-]"),  // copper nitrate
        CommonSubstance(.salt, "K-O-Mn(=O)(=O)=O"),  // potassium permanganate
        CommonSubstance(.salt, "I-Pb-I"),
        CommonSubstance(.salt, "Na-O-Cl"),  // sodium hypochlorite
    ]

    // Radicals such as NO₂ can't be drawn yet, so they are left out.
    static let gases: [CommonSubstance] = [
        CommonSubstance(.gas, "H-H"),
        CommonSubstance(.gas, "O=O"),
        CommonSubstance(.gas, "N#N"),
        CommonSubstance(.gas, "Cl-Cl"),
        CommonSubstance(.gas, "O=C=O"),  // carbon dioxide
        CommonSubstance(.gas, "[C-]#[O+]"),  // carbon monoxide
        CommonSubstance(.gas, "O=S=O"),  // sulfur dioxide
        CommonSubstance(.gas, "N#[N+]-[O-]"),  // nitrous oxide
        CommonSubstance(.gas, "O=[O+]-[O-]"),  // ozone
        CommonSubstance(.gas, "H-C(-H)(-H)-H"),  // methane
    ]

    static let oxides: [CommonSubstance] = [
        CommonSubstance(.oxide, "H-O-H"),  // water
        CommonSubstance(.oxide, "H-O-O-H"),  // hydrogen peroxide
        CommonSubstance(.oxide, "O=S(=O)=O"),  // sulfur trioxide
        CommonSubstance(.oxide, "O=Si=O"),  // silica
        CommonSubstance(.oxide, "Mg=O"),
        CommonSubstance(.oxide, "Zn=O"),
        CommonSubstance(.oxide, "Cu=O"),
        CommonSubstance(.oxide, "O=Fe-O-Fe=O"),  // rust
    ]

    static let organics: [CommonSubstance] = [
        CommonSubstance(.organic, "H-C(-H)(-H)-O-H"),  // methanol
        CommonSubstance(.organic, "H-C(-H)(-H)-C(-H)(-H)-O-H"),  // ethanol
        CommonSubstance(.organic, "H-C(-H)(-H)-C(-H)(-H)-C(-H)(-H)-H"),  // propane
        CommonSubstance(.organic, "H-C(-H)(-H)-C(-H)(-H)-C(-H)(-H)-C(-H)(-H)-H"),  // butane
        CommonSubstance(.organic, "H-C(-H)=C(-H)-H"),  // ethylene
        CommonSubstance(.organic, "H-C#C-H"),  // acetylene
        CommonSubstance(.organic, "H-C(-H)=O"),  // formaldehyde
        CommonSubstance(.organic, "Cl-C(-H)(-H)-H"),  // chloromethane
        CommonSubstance(.organic, "Cl-C(-Cl)(-Cl)-H"),  // chloroform
        CommonSubstance(.organic, "Cl-C(-Cl)(-Cl)-Cl"),  // carbon tetrachloride
    ]
}
