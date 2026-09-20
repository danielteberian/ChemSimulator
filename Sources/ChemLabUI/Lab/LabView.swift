import ChemLabCore
import SwiftUI

/// The virtual lab: three beakers on a bench, a shelf of reagents, and a panel
/// that explains what is happening. Anything can be mixed; hazards are labelled.
public struct LabView: View {
    @Bindable private var model: LabModel
    @State private var showingShelf = false
    @State private var showingAbout = false
    @AppStorage("safetyDisclaimerAccepted") private var disclaimerAccepted = false
    @Environment(\.horizontalSizeClass) private var sizeClass

    public init(model: LabModel) {
        self.model = model
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
                toolbar
                messages
                bench
                    .frame(maxHeight: 330)
                BenchPanel(beaker: model.beaker)
                    .background(.background.secondary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
            }
            ShelfView(model: model)
                .frame(width: 340)
        }
    }

    private var compactLayout: some View {
        VStack(spacing: 10) {
            toolbar
            messages
            ScrollView(.horizontal) {
                bench.frame(minWidth: 520, maxHeight: 260)
            }
            BenchPanel(beaker: model.beaker)
                .background(.background.secondary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
        }
        .sheet(isPresented: $showingShelf) {
            NavigationStack {
                ShelfView(model: model)
                    .padding(8)
                    .navigationTitle("Shelf")
                    #if os(iOS)
                        .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showingShelf = false }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
    }

    // MARK: Bench

    private var bench: some View {
        HStack(alignment: .top, spacing: 10) {
            ForEach(model.beakers.indices, id: \.self) { index in
                BeakerView(
                    beaker: model.beakers[index],
                    isSelected: index == model.selected,
                    bubbleUntil: model.bubbleUntil[index],
                    burnerOn: model.burnerOn && index == model.selected
                )
                .onTapGesture { model.selected = index }
            }
        }
    }

    // MARK: Controls

    private var toolbar: some View {
        ViewThatFits(in: .horizontal) {
            toolbarButtons
            ScrollView(.horizontal, showsIndicators: false) { toolbarButtons }
        }
    }

    private var toolbarButtons: some View {
        HStack(spacing: 8) {
            if sizeClass == .compact {
                Button("Shelf", systemImage: "flask") { showingShelf = true }
            }
            Button("Heat", systemImage: "flame") { model.heatOnce() }
                .help("Adds a little heat. Water stops at 100 °C while it boils.")
            Toggle(isOn: burnerBinding) {
                Label("Burner", systemImage: "flame.fill")
            }
            .toggleStyle(.button)
            .help("Keeps heating the selected beaker")
            Button("Spark", systemImage: "bolt.fill") { model.applyFlame() }
                .help("A flame or spark, to start things that burn")
            Button("Stir", systemImage: "arrow.triangle.2.circlepath") { model.stir() }
            Button("Cool", systemImage: "snowflake") { model.cool() }
                .help("Cools the selected beaker to room temperature")
            Button("Vent", systemImage: "wind") { model.ventilate() }
                .help("Clears the gas above the liquid, like a fume hood")
            Toggle(isOn: coveredBinding) {
                Label("Cover", systemImage: "square.dashed.inset.filled")
            }
            .toggleStyle(.button)
            .help("A covered beaker gets no oxygen from the air")

            pourMenu

            Button("Empty", systemImage: "trash") { model.emptySelected() }
                .disabled(model.beaker.isEmpty)
            Spacer(minLength: 0)
            Button("About & Safety", systemImage: "exclamationmark.triangle") { showingAbout = true }
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }

    private var pourMenu: some View {
        Menu {
            ForEach(model.beakers.indices, id: \.self) { target in
                if target != model.selected {
                    Section(model.beakers[target].name) {
                        Button("Pour the liquid (keep solids behind)") {
                            model.pour(from: model.selected, to: target, fraction: 1)
                        }
                        Button("Pour half the liquid") {
                            model.pour(from: model.selected, to: target, fraction: 0.5)
                        }
                        Button("Tip everything out, solids too") {
                            model.pour(from: model.selected, to: target, fraction: 1, includingSolids: true)
                        }
                    }
                }
            }
        } label: {
            Label("Pour", systemImage: "arrow.down.to.line")
        }
        .fixedSize()
    }

    private var burnerBinding: Binding<Bool> {
        Binding(get: { model.burnerOn }, set: { _ in model.toggleBurner() })
    }

    private var coveredBinding: Binding<Bool> {
        Binding(get: { !model.beaker.openToAir }, set: { _ in model.toggleAir() })
    }

    // MARK: Messages

    @ViewBuilder
    private var messages: some View {
        if !model.messages.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(model.messages.enumerated()), id: \.offset) { _, text in
                    Label(text, systemImage: text.hasPrefix("Challenge") ? "checkmark.seal.fill" : "sparkles")
                        .font(.callout)
                }
                if let learned = model.lastCompleted?.learned {
                    Text(learned).font(.callout).foregroundStyle(.secondary)
                }
                HStack {
                    Spacer()
                    Button("Dismiss") { model.dismissMessages() }
                        .buttonStyle(.borderless)
                        .font(.caption)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
        }
    }
}
