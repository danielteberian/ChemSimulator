extension PeriodicTable {
    public struct GridPosition: Sendable, Hashable {
        /// 1...7 for the main table, 9 and 10 for the lanthanide/actinide rows.
        public let row: Int
        /// 1...18.
        public let column: Int
    }

    public static let gridRows = 10
    public static let gridColumns = 18

    /// Cell in the standard 18-column layout. Lanthanides and actinides sit in
    /// separate rows below the main table (row 8 is a spacer).
    public static func gridPosition(of element: Element) -> GridPosition {
        let z = element.number
        switch z {
        case 1: return GridPosition(row: 1, column: 1)
        case 2: return GridPosition(row: 1, column: 18)
        case 3...4: return GridPosition(row: 2, column: z - 2)
        case 5...10: return GridPosition(row: 2, column: z + 8)
        case 11...12: return GridPosition(row: 3, column: z - 10)
        case 13...18: return GridPosition(row: 3, column: z)
        case 19...36: return GridPosition(row: 4, column: z - 18)
        case 37...54: return GridPosition(row: 5, column: z - 36)
        case 55...56: return GridPosition(row: 6, column: z - 54)
        case 57...71: return GridPosition(row: 9, column: z - 54)
        case 72...86: return GridPosition(row: 6, column: z - 68)
        case 87...88: return GridPosition(row: 7, column: z - 86)
        case 89...103: return GridPosition(row: 10, column: z - 86)
        default: return GridPosition(row: 7, column: z - 100)
        }
    }
}
