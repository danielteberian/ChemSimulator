#if os(macOS)
import AppKit
import ChemLabCore
import Foundation
import SwiftUI
import Testing

@testable import ChemLabUI

/// Renders the builder to PNGs so the layout can be checked by eye.
/// Only runs when CHEMLAB_SNAPSHOT_DIR is set:
///   CHEMLAB_SNAPSHOT_DIR=/some/dir swift test --filter Snapshot
@MainActor
@Suite("Snapshot")
struct SnapshotTests {
    private static var outputDirectory: URL? {
        ProcessInfo.processInfo.environment["CHEMLAB_SNAPSHOT_DIR"].map { URL(fileURLWithPath: $0) }
    }

    private func el(_ symbol: String) -> Element { PeriodicTable.element(symbol: symbol)! }

    private func render(_ name: String, model: BuilderModel, size: CGSize) throws {
        try renderView(name, view: BuilderView(model: model), size: size)
    }

    private func renderView<V: View>(_ name: String, view: V, size: CGSize) throws {
        guard let directory = Self.outputDirectory else { return }
        // A real hosting view (unlike ImageRenderer) draws native controls and scroll views.
        _ = NSApplication.shared
        let root = view.background(Color(nsColor: .windowBackgroundColor))
        let hosting = NSHostingView(rootView: root)
        let window = NSWindow(
            contentRect: CGRect(origin: .zero, size: size), styleMask: [.titled],
            backing: .buffered, defer: false)
        window.contentView = hosting
        window.appearance = NSAppearance(named: .aqua)
        hosting.frame = CGRect(origin: .zero, size: size)
        hosting.layoutSubtreeIfNeeded()
        RunLoop.current.run(until: Date().addingTimeInterval(0.5))
        hosting.layoutSubtreeIfNeeded()
        let rep = try #require(hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds))
        hosting.cacheDisplay(in: hosting.bounds, to: rep)
        let png = try #require(rep.representation(using: .png, properties: [:]))
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try png.write(to: directory.appendingPathComponent("\(name).png"))
    }

    @Test func water() throws {
        let model = BuilderModel()
        model.canvasCenter = CGPoint(x: 300, y: 150)
        model.addAtom(el("O"))
        model.addAtom(el("H"))
        model.addAtom(el("H"))
        try render("water", model: model, size: CGSize(width: 1100, height: 780))
    }

    @Test func halfBuiltAndDangerous() throws {
        let model = BuilderModel()
        model.canvasCenter = CGPoint(x: 300, y: 150)
        let s = model.addAtom(el("S"))
        model.addAtom(el("O"))
        model.addAtom(el("O"))
        model.select(s)
        try render("partial", model: model, size: CGSize(width: 1100, height: 780))
    }

    @Test func hazardous() throws {
        let model = BuilderModel()
        model.canvasCenter = CGPoint(x: 300, y: 150)
        model.addAtom(el("H"))
        model.addAtom(el("H"))
        try render("hydrogen", model: model, size: CGSize(width: 1100, height: 780))
    }

    @Test func empty() throws {
        try render("empty", model: BuilderModel(), size: CGSize(width: 1100, height: 780))
    }

    // MARK: Lab and learning screens

    private func labModel(loading id: String) -> LabModel {
        let lab = LabModel(defaults: nil)
        if let experiment = ExperimentLibrary.all.first(where: { $0.id == id }) { lab.load(experiment) }
        return lab
    }

    @Test func labBenchEmpty() throws {
        try renderView("lab-empty", view: LabView(model: LabModel(defaults: nil)), size: CGSize(width: 1100, height: 780))
    }

    @Test func labCopperInNitricAcid() throws {
        try renderView("lab-nitric", view: LabView(model: labModel(loading: "copper-nitric")), size: CGSize(width: 1100, height: 780))
    }

    @Test func labPrecipitateAndColor() throws {
        let lab = labModel(loading: "golden-rain")
        lab.selected = 1
        lab.load(ExperimentLibrary.all.first { $0.id == "copper-tree" }!)
        try renderView("lab-two-beakers", view: LabView(model: lab), size: CGSize(width: 1100, height: 780))
    }

    @Test func labSodiumInWater() throws {
        try renderView("lab-sodium", view: LabView(model: labModel(loading: "sodium-water")), size: CGSize(width: 1100, height: 780))
    }

    @Test func learnChallenges() throws {
        let lab = labModel(loading: "volcano")
        try renderView("learn", view: LearnView(model: lab, openLab: {}), size: CGSize(width: 1100, height: 780))
    }

    @Test func rootView() throws {
        try renderView("root", view: ChemLabRootView(), size: CGSize(width: 1100, height: 780))
    }
}
#endif
