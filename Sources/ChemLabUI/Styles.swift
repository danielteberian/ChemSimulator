import ChemLabCore
import SwiftUI

extension Element {
    /// Fill for the atom on the canvas, following the usual CPK colouring.
    var atomColor: Color {
        let rgb: (Double, Double, Double)
        switch symbol {
        case "H": rgb = (1.00, 1.00, 1.00)
        case "He": rgb = (0.85, 1.00, 1.00)
        case "Li": rgb = (0.80, 0.50, 1.00)
        case "B": rgb = (1.00, 0.71, 0.71)
        case "C": rgb = (0.25, 0.25, 0.25)
        case "N": rgb = (0.19, 0.31, 0.97)
        case "O": rgb = (1.00, 0.05, 0.05)
        case "F": rgb = (0.56, 0.88, 0.31)
        case "Ne": rgb = (0.70, 0.89, 0.96)
        case "Na": rgb = (0.67, 0.36, 0.95)
        case "Mg": rgb = (0.54, 1.00, 0.00)
        case "Al": rgb = (0.75, 0.65, 0.65)
        case "Si": rgb = (0.94, 0.78, 0.63)
        case "P": rgb = (1.00, 0.50, 0.00)
        case "S": rgb = (1.00, 1.00, 0.19)
        case "Cl": rgb = (0.12, 0.94, 0.12)
        case "Ar": rgb = (0.50, 0.82, 0.89)
        case "K": rgb = (0.56, 0.25, 0.83)
        case "Ca": rgb = (0.24, 1.00, 0.00)
        case "Fe": rgb = (0.88, 0.40, 0.20)
        case "Cu": rgb = (0.78, 0.50, 0.20)
        case "Zn": rgb = (0.49, 0.50, 0.69)
        case "Br": rgb = (0.65, 0.16, 0.16)
        case "Ag": rgb = (0.75, 0.75, 0.75)
        case "I": rgb = (0.58, 0.00, 0.58)
        case "Au": rgb = (1.00, 0.82, 0.14)
        case "Hg": rgb = (0.72, 0.72, 0.82)
        case "Pb": rgb = (0.34, 0.35, 0.38)
        default:
            return categoryColor
        }
        return Color(red: rgb.0, green: rgb.1, blue: rgb.2)
    }

    /// Black or white, whichever reads better on `atomColor`.
    var atomLabelColor: Color {
        let lightBackgrounds: Set<String> = [
            "H", "He", "B", "F", "Ne", "Mg", "Al", "Si", "P", "S", "Cl", "Ar",
            "Ca", "Ag", "Au", "Hg", "At", "Ts",
        ]
        return lightBackgrounds.contains(symbol) ? .black : .white
    }

    var categoryColor: Color {
        switch category {
        case .nonmetal: .green
        case .nobleGas: .purple
        case .alkaliMetal: .red
        case .alkalineEarthMetal: .orange
        case .transitionMetal: .blue
        case .postTransitionMetal: .teal
        case .metalloid: .brown
        case .halogen: .yellow
        case .lanthanide: .pink
        case .actinide: .indigo
        }
    }
}

extension Hazard {
    var color: Color {
        switch self {
        case .corrosive: .orange
        case .toxic: .purple
        case .explosive: .red
        case .flammable: .red
        case .oxidizer: .yellow
        case .waterReactive: .blue
        case .irritant: .orange
        case .healthHazard: .pink
        case .environmental: .green
        case .exothermic: .red
        }
    }
}

extension ValenceState {
    var ringColor: Color {
        switch self {
        case .satisfied: .green
        case .open: .orange
        case .overValent: .red
        }
    }
}
