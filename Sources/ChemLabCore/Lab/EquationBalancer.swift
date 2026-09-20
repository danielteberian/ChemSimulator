/// Balances chemical equations: finds the smallest whole-number coefficients
/// that leave every element with the same count on both sides.
public enum EquationBalancer {
    /// Coefficients for `reactants` followed by `products`, or nil when the
    /// equation can't be balanced or has more than one solution.
    public static func balance(reactants: [Formula], products: [Formula]) -> [Int]? {
        guard !reactants.isEmpty, !products.isEmpty else { return nil }
        let species = reactants + products
        let elements = Set(species.flatMap { $0.counts.keys }).sorted()

        // One row per element, one column per species; products count negative.
        var matrix: [[Fraction]] = elements.map { element in
            species.enumerated().map { index, formula in
                let count = formula.counts[element] ?? 0
                return Fraction(index < reactants.count ? count : -count)
            }
        }

        // Reduce to row-echelon form.
        var pivotColumns: [Int] = []
        var row = 0
        for column in 0..<species.count where row < matrix.count {
            guard let pivot = (row..<matrix.count).first(where: { !matrix[$0][column].isZero })
            else { continue }
            matrix.swapAt(row, pivot)
            let divisor = matrix[row][column]
            matrix[row] = matrix[row].map { $0 / divisor }
            for other in 0..<matrix.count where other != row && !matrix[other][column].isZero {
                let factor = matrix[other][column]
                matrix[other] = zip(matrix[other], matrix[row]).map { $0 - factor * $1 }
            }
            pivotColumns.append(column)
            row += 1
        }

        // Exactly one free column means exactly one balanced ratio.
        let free = (0..<species.count).filter { !pivotColumns.contains($0) }
        guard free.count == 1, let freeColumn = free.first else { return nil }

        var solution = Array(repeating: Fraction(0), count: species.count)
        solution[freeColumn] = Fraction(1)
        for (rowIndex, column) in pivotColumns.enumerated() {
            solution[column] = Fraction(0) - matrix[rowIndex][freeColumn]
        }

        let common = solution.reduce(1) { lcm($0, $1.den) }
        var whole = solution.map { $0.num * (common / $0.den) }
        if whole.allSatisfy({ $0 <= 0 }) { whole = whole.map { -$0 } }
        guard whole.allSatisfy({ $0 > 0 }) else { return nil }

        let divisor = whole.reduce(0) { gcd($0, $1) }
        return whole.map { $0 / divisor }
    }

    /// True when the given coefficients leave every element balanced.
    public static func isBalanced(
        reactants: [(formula: Formula, coefficient: Int)],
        products: [(formula: Formula, coefficient: Int)]
    ) -> Bool {
        func totals(_ side: [(formula: Formula, coefficient: Int)]) -> [String: Int] {
            var result: [String: Int] = [:]
            for (formula, coefficient) in side {
                for (symbol, count) in formula.counts { result[symbol, default: 0] += count * coefficient }
            }
            return result
        }
        return totals(reactants) == totals(products)
    }
}

private func gcd(_ a: Int, _ b: Int) -> Int {
    b == 0 ? abs(a) : gcd(b, a % b)
}

private func lcm(_ a: Int, _ b: Int) -> Int {
    a / gcd(a, b) * b
}

/// Exact fractions, so balancing never suffers from rounding.
private struct Fraction {
    let num: Int
    let den: Int

    init(_ num: Int, _ den: Int = 1) {
        let sign = den < 0 ? -1 : 1
        let divisor = gcd(num, den)
        self.num = sign * num / divisor
        self.den = sign * den / divisor
    }

    var isZero: Bool { num == 0 }

    static func + (a: Fraction, b: Fraction) -> Fraction {
        Fraction(a.num * b.den + b.num * a.den, a.den * b.den)
    }

    static func - (a: Fraction, b: Fraction) -> Fraction {
        Fraction(a.num * b.den - b.num * a.den, a.den * b.den)
    }

    static func * (a: Fraction, b: Fraction) -> Fraction {
        Fraction(a.num * b.num, a.den * b.den)
    }

    static func / (a: Fraction, b: Fraction) -> Fraction {
        Fraction(a.num * b.den, a.den * b.num)
    }
}
