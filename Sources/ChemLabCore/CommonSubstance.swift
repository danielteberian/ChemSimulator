/// A ready-made molecule the user can drop onto the canvas. Names, formulas and
/// hazards come from the compound catalog, so there is one source of truth.
public struct CommonSubstance: Identifiable, Sendable, Hashable {
    public enum Group: String, CaseIterable, Identifiable, Sendable {
        case acid, base, salt, gas, oxide, organic

        public var id: String { rawValue }

        public var title: String {
            switch self {
            case .acid: "Acids"
            case .base: "Bases"
            case .salt: "Salts"
            case .gas: "Gases"
            case .oxide: "Oxides"
            case .organic: "Organics"
            }
        }
    }

    public let group: Group
    /// Structure string for `StructureParser`.
    public let structure: String
    public let formula: Formula

    public var id: String { formula.hill }

    init(_ group: Group, _ structure: String) {
        guard let molecule = try? StructureParser.parse(structure) else {
            preconditionFailure("Substance structure does not parse: \(structure)")
        }
        self.group = group
        self.structure = structure
        self.formula = Formula(molecule)
    }

    /// A fresh copy of the molecule, with atom IDs starting at zero.
    public func makeMolecule() -> Molecule {
        guard let molecule = try? StructureParser.parse(structure) else {
            preconditionFailure("Substance structure does not parse: \(structure)")
        }
        return molecule
    }

    public var identification: Identification? { Naming.identify(formula) }

    /// "Sulfuric acid", or the formula when the catalog has no name.
    public var name: String { identification?.displayName ?? formula.display }

    /// "H₂SO₄" as people write it.
    public var displayFormula: String { identification?.displayFormula ?? formula.display }

    /// Distinct hazards, in catalog order.
    public var hazards: [Hazard] {
        var seen = Set<Hazard>()
        return (identification?.hazards ?? []).map(\.hazard).filter { seen.insert($0).inserted }
    }
}
