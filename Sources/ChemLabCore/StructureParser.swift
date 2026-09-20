public enum StructureParseError: Error, Equatable {
    case unexpectedCharacter(Character, position: Int)
    case unknownElement(String)
    case unclosedBranch
    case unclosedBracket
    case unclosedRing(Int)
}

/// Builds a molecule from a compact structure string. Every atom is written out,
/// hydrogens included.
///
///     H-O-H                 water
///     O=C=O                 carbon dioxide (- single, = double, # triple)
///     H-C(-H)(-H)-C(=O)-O-H acetic acid (parentheses start a branch)
///     H-O-[N+](=O)-[O-]     nitric acid ([N+] is an atom with formal charge)
///     [Ca+2]                a charge can carry a magnitude: +2, -3
///     Cu1-O-S(=O)(=O)-O1    copper sulfate (a digit closes a ring)
///
/// A bond symbol may be left out between atoms, which means a single bond.
public enum StructureParser {
    public static func parse(_ text: String) throws -> Molecule {
        var reader = Reader(chars: Array(text.filter { !$0.isWhitespace }))
        try reader.readChain(from: nil)
        if reader.index < reader.chars.count {
            throw StructureParseError.unexpectedCharacter(
                reader.chars[reader.index], position: reader.index)
        }
        if let open = reader.openRings.keys.sorted().first {
            throw StructureParseError.unclosedRing(open)
        }
        return reader.molecule
    }
}

private struct Reader {
    let chars: [Character]
    var index = 0
    var molecule = Molecule()
    /// Ring digit -> the atom that opened it.
    var openRings: [Int: Int] = [:]

    /// Reads atoms and branches until the end or a closing parenthesis.
    /// `anchor` is the atom the first new atom bonds to.
    mutating func readChain(from anchor: Int?) throws {
        var previous = anchor
        var order = 1
        while index < chars.count {
            let c = chars[index]
            switch c {
            case ")":
                return
            case "(":
                guard let branchRoot = previous else {
                    throw StructureParseError.unexpectedCharacter(c, position: index)
                }
                index += 1
                try readChain(from: branchRoot)
                guard index < chars.count, chars[index] == ")" else {
                    throw StructureParseError.unclosedBranch
                }
                index += 1
            case "-":
                order = 1
                index += 1
            case "=":
                order = 2
                index += 1
            case "#":
                order = 3
                index += 1
            default:
                let id = try readAtom()
                if let previous { try molecule.addBond(previous, id, order: order) }
                order = 1
                try readRingDigits(for: id)
                previous = id
            }
        }
    }

    private mutating func readAtom() throws -> Int {
        let bracketed = chars[index] == "["
        if bracketed { index += 1 }
        guard index < chars.count, chars[index].isUppercase else {
            throw StructureParseError.unexpectedCharacter(
                chars[min(index, chars.count - 1)], position: index)
        }
        var symbol = String(chars[index])
        index += 1
        if index < chars.count, chars[index].isLowercase {
            symbol.append(chars[index])
            index += 1
        }
        guard let element = PeriodicTable.element(symbol: symbol) else {
            throw StructureParseError.unknownElement(symbol)
        }

        var charge = 0
        if bracketed {
            // "+", "-", "+2", "-3", or repeated signs like "++".
            while index < chars.count, chars[index] == "+" || chars[index] == "-" {
                let sign = chars[index] == "+" ? 1 : -1
                index += 1
                if index < chars.count, let magnitude = chars[index].wholeNumberValue {
                    charge += sign * magnitude
                    index += 1
                } else {
                    charge += sign
                }
            }
            guard index < chars.count, chars[index] == "]" else {
                throw StructureParseError.unclosedBracket
            }
            index += 1
        }
        return molecule.addAtom(element, formalCharge: charge)
    }

    /// A digit right after an atom opens a ring; the same digit again closes it.
    private mutating func readRingDigits(for id: Int) throws {
        while index < chars.count, let digit = chars[index].wholeNumberValue {
            index += 1
            if let opener = openRings.removeValue(forKey: digit) {
                try molecule.addBond(opener, id)
            } else {
                openRings[digit] = id
            }
        }
    }
}
