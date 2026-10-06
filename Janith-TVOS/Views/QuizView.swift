//
//  QuizView.swift
//  Janith-TVOS
//
//  Screen 6: Space Quiz. Choose 1 or 2 players, answer 10 questions,
//  then see the final score.
//

import SwiftUI

/// Container for the quiz. Shows the setup, question or result screen
/// depending on `QuizGame.phase`.
struct QuizView: View {
    /// Owned here so a fresh game starts each time the quiz is opened.
    @State private var game = QuizGame()

    var body: some View {
        ZStack {
            StarfieldBackground()

            switch game.phase {
            case .setup:
                QuizSetupView(game: game)
                    .transition(.opacity)
            case .playing:
                QuizQuestionView(game: game)
                    .transition(.opacity)
            case .finished:
                QuizResultView(game: game)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: game.phase)
    }
}

// MARK: - Setup

/// Lets players choose solo mode or two-player pass-the-remote mode.
private struct QuizSetupView: View {
    let game: QuizGame

    var body: some View {
        VStack(spacing: 50) {
            VStack(spacing: 16) {
                Text("SPACE QUIZ")
                    .font(Theme.display(110))
                    .foregroundStyle(Theme.titleGradient)
                Text("\(QuizGame.questionsPerGame) questions about the planets. How much did you discover?")
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.secondaryText)
            }

            HStack(spacing: 60) {
                modeButton(players: 1, title: "1 Player", subtitle: "Solo mission",
                           systemImage: "person.fill")
                modeButton(players: 2, title: "2 Players", subtitle: "Take turns with the remote",
                           systemImage: "person.2.fill")
            }
        }
    }

    /// A large tile that starts a game with the given number of players.
    private func modeButton(players: Int, title: String, subtitle: String, systemImage: String) -> some View {
        Button {
            game.start(players: players)
        } label: {
            VStack(spacing: 20) {
                Image(systemName: systemImage)
                    .font(.system(size: 80))
                Text(title)
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .opacity(0.7)
            }
            .frame(width: 420, height: 320)
        }
        .buttonStyle(QuizTileStyle())
    }
}

/// Focus styling for the player-mode tiles.
private struct QuizTileStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        QuizTileBody(configuration: configuration)
    }
}

private struct QuizTileBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        configuration.label
            .foregroundStyle(isFocused ? Theme.deepSpace : .white)
            .background {
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(isFocused ? AnyShapeStyle(Color.white) : AnyShapeStyle(Color.white.opacity(0.08)))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .strokeBorder(.white.opacity(isFocused ? 0 : 0.2), lineWidth: 2)
            }
            .shadow(color: Theme.purple.opacity(isFocused ? 0.7 : 0), radius: 36)
            .scaleEffect(configuration.isPressed ? 1.02 : (isFocused ? 1.08 : 1))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
    }
}

// MARK: - Question

/// One question with four answers in a 2×2 grid.
///
/// Flow: click an answer to select it (focus jumps to Submit) → Submit reveals
/// right/wrong → the same button becomes Next Question or See Results.
private struct QuizQuestionView: View {
    let game: QuizGame

    /// Focusable controls on this screen, so focus can be moved in code.
    private enum Field: Hashable {
        case option(Int)
        case submit
    }

    @FocusState private var focus: Field?

    private static let letters = ["A", "B", "C", "D"]
    private let columns = Array(repeating: GridItem(.fixed(760), spacing: 36), count: 2)

    private var question: QuizQuestion { game.currentQuestion }
    private var playerColor: Color { game.currentPlayer == 0 ? Theme.blue : Theme.purple }

    var body: some View {
        VStack(spacing: 30) {
            header

            HStack(spacing: 40) {
                if let planet = question.planet {
                    PlanetView(planet: planet, size: 110)
                        .frame(width: 200, height: 140)
                }
                Text(question.prompt)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 1560, minHeight: 150)
            .id(question.id)
            .transition(.push(from: .trailing))

            LazyVGrid(columns: columns, spacing: 28) {
                ForEach(Array(question.options.enumerated()), id: \.element) { index, option in
                    Button {
                        game.select(option)
                        focus = .submit
                    } label: {
                        AnswerLabel(letter: Self.letters[index], text: option)
                    }
                    .buttonStyle(AnswerButtonStyle(state: answerState(for: option)))
                    .disabled(game.isAnswerRevealed)
                    .focused($focus, equals: .option(index))
                }
            }

            feedback
                .frame(height: 90)

            SpaceButton(primaryTitle, systemImage: primaryIcon) {
                if game.isAnswerRevealed {
                    let finishing = game.isLastQuestion
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        game.next()
                    }
                    // Submit is disabled until a new answer is chosen, so move focus to the answers.
                    if !finishing { focus = .option(0) }
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        game.submit()
                    }
                }
            }
            .disabled(game.selectedOption == nil)
            .focused($focus, equals: .submit)
        }
        .padding(.horizontal, 20)
        .defaultFocus($focus, .option(0))
    }

    /// Title, whose turn it is (2-player mode), scores and the progress bar.
    private var header: some View {
        VStack(spacing: 18) {
            HStack {
                Text("SPACE QUIZ")
                    .font(Theme.display(44))
                    .foregroundStyle(Theme.titleGradient)
                Spacer()
                if game.isMultiplayer {
                    Label("Player \(game.currentPlayer + 1)'s turn", systemImage: "person.fill")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.deepSpace)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(playerColor))
                    Spacer()
                }
                scoreboard
            }

            HStack(spacing: 24) {
                Text("Question \(game.index + 1) of \(game.questions.count)")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.secondaryText)
                    .monospacedDigit()
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.12))
                        Capsule()
                            .fill(LinearGradient(colors: [Theme.blue, Theme.purple], startPoint: .leading, endPoint: .trailing))
                            .frame(width: proxy.size.width * game.progress)
                    }
                }
                .frame(height: 12)
            }
        }
    }

    private var scoreboard: some View {
        HStack(spacing: 30) {
            ForEach(0..<game.playerCount, id: \.self) { player in
                HStack(spacing: 10) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(game.isMultiplayer ? "P\(player + 1): \(game.scores[player])" : "Score: \(game.scores[player])")
                        .monospacedDigit()
                }
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
            }
        }
    }

    /// After submitting: correct/incorrect plus an explanation. Before: a hint for the next step.
    @ViewBuilder
    private var feedback: some View {
        if game.isAnswerRevealed {
            let correct = game.isSelectionCorrect
            VStack(spacing: 8) {
                Label(correct ? "Correct!" : "Not quite — the answer is \(question.answer)",
                      systemImage: correct ? "checkmark.seal.fill" : "xmark.octagon.fill")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(correct ? Theme.success : Theme.danger)
                Text(question.explanation)
                    .font(.system(size: 26, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.secondaryText)
            }
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        } else {
            Text(game.selectedOption == nil ? "Choose an answer" : "Press Submit to lock in your answer")
                .font(.system(size: 26, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.45))
        }
    }

    private var primaryTitle: String {
        guard game.isAnswerRevealed else { return "Submit" }
        return game.isLastQuestion ? "See Results" : "Next Question"
    }

    private var primaryIcon: String {
        guard game.isAnswerRevealed else { return "checkmark" }
        return game.isLastQuestion ? "flag.checkered" : "arrow.right"
    }

    /// How an answer button should look given the selection and whether the answer is revealed.
    private func answerState(for option: String) -> AnswerButtonStyle.State {
        let isSelected = option == game.selectedOption
        guard game.isAnswerRevealed else { return isSelected ? .selected : .idle }
        if option == question.answer { return .correct }
        return isSelected ? .incorrect : .dimmed
    }
}

// MARK: - Answer button

/// Letter badge (A–D) followed by the answer text.
private struct AnswerLabel: View {
    let letter: String
    let text: String

    var body: some View {
        HStack(spacing: 26) {
            Text(letter)
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .frame(width: 64, height: 64)
                .background(Circle().fill(.white.opacity(0.18)))
            Text(text)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 28)
        .frame(width: 760, height: 104, alignment: .leading)
    }
}

/// Colours an answer button by its state, on top of the usual focus effect.
private struct AnswerButtonStyle: ButtonStyle {
    enum State {
        /// Not selected, answer not yet revealed.
        case idle
        /// Chosen by the player, waiting for Submit.
        case selected
        /// The right answer (shown green after Submit).
        case correct
        /// The player's wrong choice (shown red after Submit).
        case incorrect
        /// Any other option after Submit.
        case dimmed
    }

    let state: State

    func makeBody(configuration: Configuration) -> some View {
        AnswerButtonBody(configuration: configuration, state: state)
    }
}

private struct AnswerButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let state: AnswerButtonStyle.State

    @Environment(\.isFocused) private var isFocused

    private var fill: Color {
        switch state {
        case .idle: isFocused ? .white : .white.opacity(0.08)
        case .selected: isFocused ? .white : Theme.blue.opacity(0.55)
        case .correct: Theme.success.opacity(0.85)
        case .incorrect: Theme.danger.opacity(0.85)
        case .dimmed: .white.opacity(0.04)
        }
    }

    private var border: Color {
        switch state {
        case .selected: Theme.blue
        case .correct: Theme.success
        case .incorrect: Theme.danger
        case .idle, .dimmed: .white.opacity(0.18)
        }
    }

    private var textColor: Color {
        if isFocused && (state == .idle || state == .selected) { return Theme.deepSpace }
        return state == .dimmed ? .white.opacity(0.4) : .white
    }

    var body: some View {
        configuration.label
            .foregroundStyle(textColor)
            .background {
                RoundedRectangle(cornerRadius: 26, style: .continuous).fill(fill)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(border, lineWidth: state == .idle || state == .dimmed ? 2 : 5)
            }
            .overlay(alignment: .trailing) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.trailing, 28)
                }
            }
            .shadow(color: Theme.blue.opacity(isFocused ? 0.6 : 0), radius: 24)
            .scaleEffect(configuration.isPressed ? 0.97 : (isFocused ? 1.05 : 1))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
            .animation(.easeInOut(duration: 0.25), value: state)
    }

    private var icon: String? {
        switch state {
        case .selected: "circle.inset.filled"
        case .correct: "checkmark.circle.fill"
        case .incorrect: "xmark.circle.fill"
        case .idle, .dimmed: nil
        }
    }
}

#Preview {
    QuizView()
        .environment(AppRouter())
}
