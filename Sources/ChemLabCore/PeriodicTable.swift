public enum PeriodicTable {
    /// All 118 elements, ordered by atomic number.
    public static let all: [Element] = period1to4 + period5to6 + period6to7

    private static let bySymbol: [String: Element] =
        Dictionary(uniqueKeysWithValues: all.map { ($0.symbol, $0) })

    public static func element(symbol: String) -> Element? {
        bySymbol[symbol]
    }

    public static func element(number: Int) -> Element? {
        all.indices.contains(number - 1) ? all[number - 1] : nil
    }

    static func make(
        _ number: Int, _ symbol: String, _ name: String, _ mass: Double,
        _ en: Double?, _ valences: [Int], _ ions: [Int] = [], _ category: Element.Category
    ) -> Element {
        Element(
            number: number, symbol: symbol, name: name, atomicMass: mass,
            electronegativity: en, valences: valences, ionCharges: ions, category: category)
    }
}

extension PeriodicTable {
    static let period1to4: [Element] = [
        make(1, "H", "Hydrogen", 1.008, 2.20, [1], [1, -1], .nonmetal),
        make(2, "He", "Helium", 4.0026, nil, [], [], .nobleGas),
        make(3, "Li", "Lithium", 6.94, 0.98, [1], [1], .alkaliMetal),
        make(4, "Be", "Beryllium", 9.0122, 1.57, [2], [2], .alkalineEarthMetal),
        make(5, "B", "Boron", 10.81, 2.04, [3], [], .metalloid),
        make(6, "C", "Carbon", 12.011, 2.55, [4], [], .nonmetal),
        make(7, "N", "Nitrogen", 14.007, 3.04, [3], [-3], .nonmetal),
        make(8, "O", "Oxygen", 15.999, 3.44, [2], [-2], .nonmetal),
        make(9, "F", "Fluorine", 18.998, 3.98, [1], [-1], .halogen),
        make(10, "Ne", "Neon", 20.180, nil, [], [], .nobleGas),
        make(11, "Na", "Sodium", 22.990, 0.93, [1], [1], .alkaliMetal),
        make(12, "Mg", "Magnesium", 24.305, 1.31, [2], [2], .alkalineEarthMetal),
        make(13, "Al", "Aluminum", 26.982, 1.61, [3], [3], .postTransitionMetal),
        make(14, "Si", "Silicon", 28.085, 1.90, [4], [], .metalloid),
        make(15, "P", "Phosphorus", 30.974, 2.19, [3, 5], [-3], .nonmetal),
        make(16, "S", "Sulfur", 32.06, 2.58, [2, 4, 6], [-2], .nonmetal),
        make(17, "Cl", "Chlorine", 35.45, 3.16, [1], [-1], .halogen),
        make(18, "Ar", "Argon", 39.948, nil, [], [], .nobleGas),
        make(19, "K", "Potassium", 39.098, 0.82, [1], [1], .alkaliMetal),
        make(20, "Ca", "Calcium", 40.078, 1.00, [2], [2], .alkalineEarthMetal),
        make(21, "Sc", "Scandium", 44.956, 1.36, [3], [3], .transitionMetal),
        make(22, "Ti", "Titanium", 47.867, 1.54, [4], [4, 3], .transitionMetal),
        make(23, "V", "Vanadium", 50.942, 1.63, [5], [2, 3], .transitionMetal),
        make(24, "Cr", "Chromium", 51.996, 1.66, [3, 6], [2, 3], .transitionMetal),
        make(25, "Mn", "Manganese", 54.938, 1.55, [2, 4, 7], [2, 3], .transitionMetal),
        make(26, "Fe", "Iron", 55.845, 1.83, [2, 3], [2, 3], .transitionMetal),
        make(27, "Co", "Cobalt", 58.933, 1.88, [2, 3], [2, 3], .transitionMetal),
        make(28, "Ni", "Nickel", 58.693, 1.91, [2], [2], .transitionMetal),
        make(29, "Cu", "Copper", 63.546, 1.90, [1, 2], [1, 2], .transitionMetal),
        make(30, "Zn", "Zinc", 65.38, 1.65, [2], [2], .transitionMetal),
        make(31, "Ga", "Gallium", 69.723, 1.81, [3], [3], .postTransitionMetal),
        make(32, "Ge", "Germanium", 72.630, 2.01, [4], [], .metalloid),
        make(33, "As", "Arsenic", 74.922, 2.18, [3, 5], [-3], .metalloid),
        make(34, "Se", "Selenium", 78.971, 2.55, [2, 4, 6], [-2], .nonmetal),
        make(35, "Br", "Bromine", 79.904, 2.96, [1], [-1], .halogen),
        make(36, "Kr", "Krypton", 83.798, 3.00, [], [], .nobleGas),
    ]
}
