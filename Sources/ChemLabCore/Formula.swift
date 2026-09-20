/// Element counts for a compound, with Hill-system formatting.
public struct Formula: Sendable, Hashable {
    /// Symbol -> atom count. Always non-empty, counts always >= 1.
    public let counts: [String: Int]

    public init(counts: [String: Int]) {
        self.counts = counts.filter { $0.value > 0 }
    }

    public init(_ molecule: Molecule) {
        var counts: [String: Int] = [:]
        for atom in molecule.atoms { counts[atom.element.symbol, default: 0] += 1 }
        self.init(counts: counts)
    }

    /// Parses formulas like "H2O", "C6H12O6" or "Ca(OH)2". Returns nil when the
    /// text is empty, malformed, or names an unknown element.
    public init?(parsing text: String) {
        var parser = Parser(Array(text))
        guard let counts = parser.parse(), !counts.isEmpty else { return nil }
        self.init(counts: counts)
    }

    /// Hill order: with carbon, C then H then the rest alphabetically; without
    /// carbon, everything alphabetically. Example: "C2H6O", "H2O", "ClNa".
    public var hill: String {
        var symbols = counts.keys.sorted()
        if counts["C"] != nil {
            let front = ["C", "H"].filter { counts[$0] != nil }
            symbols = front + symbols.filter { $0 != "C" && $0 != "H" }
        }
        return symbols.map { $0 + (counts[$0]! > 1 ? String(counts[$0]!) : "") }.joined()
    }

    /// Hill formula with Unicode subscripts, e.g. "H₂O".
    public var display: String { Formula.subscripted(hill) }

    /// Turns the digits in a formula string into subscripts: "H2SO4" -> "H₂SO₄".
    public static func subscripted(_ text: String) -> String {
        let subscripts: [Character: Character] = [
            "0": "₀", "1": "₁", "2": "₂", "3": "₃", "4": "₄",
            "5": "₅", "6": "₆", "7": "₇", "8": "₈", "9": "₉",
        ]
        return String(text.map { subscripts[$0] ?? $0 })
    }

    public var totalAtoms: Int { counts.values.reduce(0, +) }

    /// Molar mass in g/mol.
    public var molarMass: Double {
        counts.reduce(0) { sum, entry in
            sum + Double(entry.value) * (PeriodicTable.element(symbol: entry.key)?.atomicMass ?? 0)
        }
    }
}

private struct Parser {
    let chars: [Character]
    var index = 0

    init(_ chars: [Character]) { self.chars = chars }

    mutating func parse() -> [String: Int]? {
        var stack: [[String: Int]] = [[:]]
        while index < chars.count {
            let c = chars[index]
            if c == "(" {
                index += 1
                stack.append([:])
            } else if c == ")" {
                index += 1
                guard stack.count > 1 else { return nil }
                let group = stack.removeLast()
                let multiplier = number() ?? 1
                for (symbol, n) in group { stack[stack.count - 1][symbol, default: 0] += n * multiplier }
            } else if c.isUppercase {
                var symbol = String(c)
                index += 1
                if index < chars.count, chars[index].isLowercase {
                    symbol.append(chars[index])
                    index += 1
                }
                guard PeriodicTable.element(symbol: symbol) != nil else { return nil }
                stack[stack.count - 1][symbol, default: 0] += number() ?? 1
            } else {
                return nil
            }
        }
        return stack.count == 1 ? stack[0] : nil
    }

    private mutating func number() -> Int? {
        var digits = ""
        while index < chars.count, chars[index].isNumber {
            digits.append(chars[index])
            index += 1
        }
        return Int(digits)
    }
}
