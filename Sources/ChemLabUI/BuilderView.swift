import ChemLabCore
import SwiftUI

/// The molecule builder screen. Wide windows get canvas + table + info side by
/// side; phones get canvas + info with the periodic table in a sheet.
public struct BuilderView: View {
    @State private var model: BuilderModel
    @State private var showingPicker = false
    @State private var showingAbout = false
    @AppStorage("safetyDisclaimerAccepted") private var disclaimerAccepted = false
    @Environment(\.horizontalSizeClass) private var sizeClass

    public init() {
        self.init(model: BuilderModel())
    }

    /// For previews and tests that start from a prepared model.
    init(model: BuilderModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        Group {
            if sizeClass == .compact { compactLayout } else { regularLayout }
        }
        .padding(12)
        .sheet(isPresented: firstLaunchBinding) {
            DisclaimerView { disclaimerAccepted = true }
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showingAbout) {
            DisclaimerView(buttonTitle: "Close") { showingAbout = false }
        }
    }

    private var firstLaunchBinding: Binding<Bool> {
        Binding(get: { !disclaimerAccepted }, set: { _ in })
    }

    // MARK: Layouts

    private var regularLayout: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 10) {
                controls
                MoleculeCanvas(model: model)
                    .frame(minHeight: 260)
                AddPanel(model: model)
            }
            InfoPanel(reports: model.reports)
                .frame(width: 320)
                .background(.background.secondary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var compactLayout: some View {
        VStack(spacing: 10) {
            controls
            MoleculeCanvas(model: model)
            InfoPanel(reports: model.reports)
                .frame(maxHeight: 240)
                .background(.background.secondary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
        }
        .sheet(isPresented: $showingPicker) {
            NavigationStack {
                AddPanel(model: model, keepsTableProportions: false)
                    .padding(8)
                    .navigationTitle("Add")
                    #if os(iOS)
                        .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showingPicker = false }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
    }

    // MARK: Controls

    private var controls: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Picker("Tool", selection: $model.tool) {
                    ForEach(BuilderTool.allCases) { tool in
                        Label(tool.title, systemImage: tool.symbolName).tag(tool)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .fixedSize()

                Toggle("Auto-bond", isOn: $model.autoBond)
                    .toggleStyle(.switch)
                    .help("New atoms bond to the selected atom")

                Spacer()

                if sizeClass == .compact {
                    Button("Add element", systemImage: "plus.circle.fill") { showingPicker = true }
                }
                Button("Undo", systemImage: "arrow.uturn.backward") { model.undo() }
                    .disabled(!model.canUndo)
                    .keyboardShortcut("z", modifiers: .command)
                Button("Redo", systemImage: "arrow.uturn.forward") { model.redo() }
                    .disabled(!model.canRedo)
                    .keyboardShortcut("z", modifiers: [.command, .shift])
                Button("Clear", systemImage: "trash") { model.clear() }
                    .disabled(model.molecule.atoms.isEmpty)
                Button("About & Safety", systemImage: "exclamationmark.triangle") { showingAbout = true }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)

            Text(model.tool.help).font(.caption).foregroundStyle(.secondary)
        }
    }
}
