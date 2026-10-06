//
//  QuizGame.swift
//  Janith-TVOS
//
//  Game state for the Space Quiz. Supports one player, or two players
//  taking turns with a shared Siri Remote.
//

import Foundation
import Observation

/// Holds all state for one Space Quiz session and enforces the game rules.
///
/// The flow for each question is: `select(_:)` an answer → `submit()` to
/// reveal whether it was correct → `next()` to move on. Keeping the rules
/// here (instead of in the view) keeps `QuizView` simple and lets the logic
/// be unit tested.
@Observable
final class QuizGame {
    /// The screen the quiz is currently showing.
    enum Phase: Equatable {
        /// Choosing 1 or 2 players.
        case setup
        /// Answering questions.
        case playing
        /// Showing the final score.
        case finished
    }

    /// Number of questions asked in one game.
    static let questionsPerGame = 10

    private(set) var phase: Phase = .setup
    /// The questions for this game, already shuffled.
    private(set) var questions: [QuizQuestion] = []
    /// Zero-based index of the current question.
    private(set) var index = 0
    /// The answer the player has highlighted, or `nil` if none yet.
    private(set) var selectedOption: String?
    /// `true` once the answer has been submitted and the result is shown.
    private(set) var isAnswerRevealed = false
    private(set) var playerCount = 1
    /// Score for each player, indexed by player number (0-based).
    private(set) var scores: [Int] = [0]

    var currentQuestion: QuizQuestion { questions[index] }
    var isLastQuestion: Bool { index == questions.count - 1 }
    var isMultiplayer: Bool { playerCount > 1 }
    /// Zero-based index of the player whose turn it is. Players alternate each question.
    var currentPlayer: Int { index % playerCount }
    var isSelectionCorrect: Bool { selectedOption == currentQuestion.answer }
    /// Fraction of the quiz completed (0…1), used by the progress bar.
    var progress: Double { Double(index + (isAnswerRevealed ? 1 : 0)) / Double(max(questions.count, 1)) }

    /// How many questions each player is asked during a game.
    func questionsAsked(by player: Int) -> Int {
        (0..<questions.count).filter { $0 % playerCount == player }.count
    }

    /// Starts a new game with randomly chosen and shuffled questions.
    /// - Parameters:
    ///   - players: Number of players (1 or 2).
    ///   - bank: The questions to choose from.
    func start(players: Int, bank: [QuizQuestion] = QuizQuestion.bank) {
        var rng = SystemRandomNumberGenerator()
        start(players: players, bank: bank, using: &rng)
    }

    /// Starts a new game using the given random number generator.
    /// Passing a seeded generator makes the question order predictable, which is useful for testing.
    func start<G: RandomNumberGenerator>(players: Int, bank: [QuizQuestion], using rng: inout G) {
        playerCount = max(1, players)
        scores = Array(repeating: 0, count: playerCount)
        questions = bank.shuffled(using: &rng)
            .prefix(Self.questionsPerGame)
            .map { $0.withShuffledOptions(using: &rng) }
        index = 0
        selectedOption = nil
        isAnswerRevealed = false
        phase = .playing
    }

    /// Highlights an answer. Ignored once the answer has been revealed.
    func select(_ option: String) {
        guard phase == .playing, !isAnswerRevealed else { return }
        selectedOption = option
    }

    /// Locks in the selected answer and awards a point to the current player if it is correct.
    /// Does nothing if no answer is selected or the answer was already submitted.
    func submit() {
        guard phase == .playing, !isAnswerRevealed, selectedOption != nil else { return }
        isAnswerRevealed = true
        if isSelectionCorrect {
            scores[currentPlayer] += 1
        }
    }

    /// Moves to the next question, or to the results after the last question.
    /// Only allowed after the current answer has been submitted.
    func next() {
        guard phase == .playing, isAnswerRevealed else { return }
        if isLastQuestion {
            phase = .finished
        } else {
            index += 1
            selectedOption = nil
            isAnswerRevealed = false
        }
    }

    /// Returns to the player selection screen so a new game can begin.
    func reset() {
        phase = .setup
    }
}
