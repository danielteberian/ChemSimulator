import ChemLabCore
import SwiftUI

/// The learning layer: challenges to try, guided experiments, and an
/// encyclopedia of every substance and reaction the learner has seen.
public struct LearnView: View {
    @Bindable private var model: LabModel
    private let openLab: () -> Void

    private enum Tab: String, CaseIterable, Identifiable {
        case challenges = "Challenges"
        case experiments = "Experiments"
        case encyclopedia = "Encyclopedia"

        var id: String { rawValue }
    }

    @State private var tab: Tab = .challenges
    @State private var confirmingReset = false

    /// `openLab` switches to the bench after something is set up on it.
    public init(model: LabModel, openLab: @escaping () -> Void) {
        self.model = model
        self.openLab = openLab
    }

    public var body: some View {
        VStack(spacing: 12) {
            Picker("Section", selection: $tab) {
                ForEach(Tab.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(maxWidth: 520)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    switch tab {
                    case .challenges: ChallengeList(model: model, openLab: openLab)
                    case .experiments: ExperimentList(model: model, openLab: openLab)
                    case .encyclopedia: EncyclopediaView(book: model.encyclopedia)
                    }
                }
                .frame(maxWidth: 720, alignment: .leading)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
            }

            HStack {
                Spacer()
                Button("Reset progress", role: .destructive) { confirmingReset = true }
                    .buttonStyle(.borderless)
                    .font(.caption)
            }
        }
        .padding(12)
        .confirmationDialog(
            "Erase your progress?", isPresented: $confirmingReset, titleVisibility: .visible
        ) {
            Button("Erase challenges and encyclopedia", role: .destructive) { model.resetProgress() }
        } message: {
            Text("This forgets every challenge you finished and every substance and reaction you found.")
        }
    }
}

// MARK: Challenges

private struct ChallengeList: View {
    @Bindable var model: LabModel
    let openLab: () -> Void
    @State private var openHints: Set<String> = []

    var body: some View {
        let done = model.encyclopedia.completedChallenges.count
        Text("\(done) of \(ChallengeLibrary.all.count) complete")
            .font(.headline)
        Text("Set up the beaker yourself and the challenge completes on its own. Stuck? Ask for a hint, or have it shown to you.")
            .font(.callout)
            .foregroundStyle(.secondary)

        ForEach(ChallengeLibrary.all) { challenge in
            let finished = model.encyclopedia.completedChallenges.contains(challenge.id)
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: finished ? "checkmark.seal.fill" : "circle.dashed")
                        .foregroundStyle(finished ? Color.green : Color.secondary)
                    Text(challenge.title).font(.title3.bold())
                }
                Text(challenge.prompt)

                if openHints.contains(challenge.id) {
                    Label(challenge.hint, systemImage: "lightbulb")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                if finished {
                    Text(challenge.learned)
                        .font(.callout)
                        .padding(8)
                        .background(Color.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                }

                HStack {
                    if !openHints.contains(challenge.id) {
                        Button("Hint") { openHints.insert(challenge.id) }
                    }
                    Button("Show me") {
                        model.showSolution(of: challenge)
                        openLab()
                    }
                    .help("Sets up one way to do it in the selected beaker")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: Experiments

private struct ExperimentList: View {
    @Bindable var model: LabModel
    let openLab: () -> Void

    var body: some View {
        Text("Guided experiments")
            .font(.headline)
        Text("Each one sets up a beaker for you, so you can see what happens and why.")
            .font(.callout)
            .foregroundStyle(.secondary)

        ForEach(ExperimentLibrary.all) { experiment in
            VStack(alignment: .leading, spacing: 8) {
                Text(experiment.title).font(.title3.bold())
                Text(experiment.summary)
                Label(experiment.watchFor, systemImage: "eye")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                DisclosureGroup("Steps") {
                    VStack(alignment: .leading, spacing: 3) {
                        ForEach(Array(experiment.steps.enumerated()), id: \.offset) { index, step in
                            Text("\(index + 1). \(step.text)").font(.callout)
                        }
                    }
                    .padding(.top, 4)
                }

                Button("Set up in \(model.beaker.name)", systemImage: "flask") {
                    model.load(experiment)
                    openLab()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: Encyclopedia

private struct EncyclopediaView: View {
    let book: Encyclopedia

    private enum Page: String, CaseIterable, Identifiable {
        case substances = "Substances"
        case reactions = "Reactions"

        var id: String { rawValue }
    }

    @State private var page: Page = .substances

    var body: some View {
        let progress = book.libraryProgress
        Text("You have met \(progress.found) of \(progress.total) substances and seen \(book.reactionList.count) reactions.")
            .font(.headline)

        Picker("Page", selection: $page) {
            ForEach(Page.allCases) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .frame(maxWidth: 320)

        switch page {
        case .substances: substances
        case .reactions: reactions
        }
    }

    @ViewBuilder
    private var substances: some View {
        if book.speciesList.isEmpty {
            Text("Nothing yet. Add something to a beaker in the lab and it will appear here.")
                .foregroundStyle(.secondary)
        }
        ForEach(book.speciesList) { species in
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(species.name).font(.headline)
                    Text(species.formula).font(.callout.monospaced()).foregroundStyle(.secondary)
                }
                if !species.hazardNotes.isEmpty { HazardIcons(notes: species.hazardNotes) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
        }
    }

    @ViewBuilder
    private var reactions: some View {
        if book.reactionList.isEmpty {
            Text("No reactions yet. Mix things in the lab and every reaction you cause is kept here, with the reason it happened.")
                .foregroundStyle(.secondary)
        }
        ForEach(book.reactionList) { reaction in
            VStack(alignment: .leading, spacing: 6) {
                Text(reaction.kindTitle.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(reaction.equation).font(.title3.monospaced())
                Text(reaction.why).font(.callout)
                if !reaction.hazardNotes.isEmpty { HazardIcons(notes: reaction.hazardNotes) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
        }
    }
}
