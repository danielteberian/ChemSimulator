import ChemLabCore
import SwiftUI

/// The periodic table as a grid of tappable cells. Scrolls when the space is
/// too small for legible cells (e.g. on a phone).
struct PeriodicTablePicker: View {
    var onSelect: (Element) -> Void

    private let minCell: CGFloat = 34
    private let maxCell: CGFloat = 58
    /// Row 8 is a spacer between the main table and the f-block; shrink it.
    private let spacerRowScale: CGFloat = 0.5

    var body: some View {
        GeometryReader { proxy in
            let cell = min(maxCell, max(minCell, proxy.size.width / CGFloat(PeriodicTable.gridColumns)))
            ScrollView([.horizontal, .vertical]) {
                ZStack(alignment: .topLeading) {
                    ForEach(PeriodicTable.all) { element in
                        let pos = PeriodicTable.gridPosition(of: element)
                        ElementCell(element: element, size: cell - 2) { onSelect(element) }
                            .offset(
                                x: CGFloat(pos.column - 1) * cell + 1,
                                y: yOffset(row: pos.row, cell: cell) + 1)
                    }
                }
                .frame(
                    width: cell * CGFloat(PeriodicTable.gridColumns),
                    height: yOffset(row: PeriodicTable.gridRows + 1, cell: cell),
                    alignment: .topLeading)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private func yOffset(row: Int, cell: CGFloat) -> CGFloat {
        let spacerRow = 8
        let fullRows = row - 1
        return row > spacerRow
            ? (CGFloat(fullRows) - 1 + spacerRowScale) * cell
            : CGFloat(fullRows) * cell
    }
}

private struct ElementCell: View {
    let element: Element
    let size: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text("\(element.number)")
                    .font(.system(size: size * 0.2))
                    .foregroundStyle(.secondary)
                Text(element.symbol)
                    .font(.system(size: size * 0.4, weight: .semibold, design: .rounded))
            }
            .frame(width: size, height: size)
            .background(element.categoryColor.opacity(0.28), in: RoundedRectangle(cornerRadius: 5))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(element.categoryColor.opacity(0.6), lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add \(element.name)")
        #if os(macOS)
            .help(element.name)
        #endif
    }
}
