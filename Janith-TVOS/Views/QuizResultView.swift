//
//  QuizResultView.swift
//  Janith-TVOS
//
//  Final score screen for the Space Quiz.
//

import SwiftUI

/// Shows the final score and a star rating (1 player), or both scores and the winner (2 players).
struct QuizResultView: View {
    let game: QuizGame

    @Environment(AppRouter.self) private var router
    /// Triggers the medal and star animations after the screen appears.
    @State private var celebrate = false

    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 14) {
                Text("QUIZ COMPLETE")
                    .eyebrowStyle()
                Image(systemName: game.isMultiplayer ? "trophy.fill" : "medal.fill")
                    .font(.system(size: 110))
                    .foregroundStyle(.yellow)
                    .shadow(color: .yellow.opacity(0.6), radius: 30)
                    .scaleEffect(celebrate ? 1 : 0.3)
                    .rotationEffect(.degrees(celebrate ? 0 : -30))
            }

            if game.isMultiplayer {
                multiplayerResult
            } else {
                singlePlayerResult
            }

            HStack(spacing: 36) {
                SpaceButton("Play Again", systemImage: "arrow.counterclockwise") {
                    game.reset()
                }
                SpaceButton("Solar System", systemImage: "globe.europe.africa.fill", kind: .secondary) {
                    router.popToSolarSystem()
                }
            }
            .padding(.top, 10)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.55).delay(0.2)) {
                celebrate = true
            }
        }
    }

    private var singlePlayerResult: some View {
        let score = game.scores[0]
        let total = game.questions.count
        return VStack(spacing: 10) {
            Text("SCORE")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .tracking(8)
                .foregroundStyle(Theme.secondaryText)
            Text("\(score) / \(total)")
                .font(Theme.display(160))
                .foregroundStyle(Theme.titleGradient)
                .monospacedDigit()
            Text(Self.message(score: score, total: total))
                .font(.system(size: 52, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            starRow(score: score, total: total)
        }
    }

    private var multiplayerResult: some View {
        VStack(spacing: 30) {
            Text(winnerText)
                .font(Theme.display(72))
                .foregroundStyle(Theme.titleGradient)
            HStack(spacing: 50) {
                ForEach(0..<game.playerCount, id: \.self) { player in
                    VStack(spacing: 10) {
                        Text("PLAYER \(player + 1)")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .tracking(6)
                            .foregroundStyle(player == 0 ? Theme.blue : Theme.purple)
                        Text("\(game.scores[player])")
                            .font(Theme.display(120))
                            .foregroundStyle(.white)
                        Text("out of \(game.questionsAsked(by: player))")
                            .font(.system(size: 26, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.secondaryText)
                    }
                    .frame(width: 380, height: 300)
                    .background {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(.white.opacity(0.06))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .strokeBorder(isWinner(player) ? Color.yellow : .white.opacity(0.15), lineWidth: isWinner(player) ? 4 : 2)
                    }
                }
            }
        }
    }

    /// Five stars, filled in proportion to the score; they pop in one after another.
    private func starRow(score: Int, total: Int) -> some View {
        let stars = Int((Double(score) / Double(max(total, 1)) * 5).rounded())
        return HStack(spacing: 16) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .font(.system(size: 44))
                    .foregroundStyle(index < stars ? .yellow : .white.opacity(0.3))
                    .scaleEffect(celebrate ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.4 + Double(index) * 0.1), value: celebrate)
            }
        }
        .padding(.top, 10)
    }

    /// `true` only for a single outright winner (no one is highlighted in a tie).
    private func isWinner(_ player: Int) -> Bool {
        let best = game.scores.max() ?? 0
        return game.scores[player] == best && game.scores.filter { $0 == best }.count == 1
    }

    private var winnerText: String {
        guard let best = game.scores.max(), game.scores.filter({ $0 == best }).count == 1,
              let winner = game.scores.firstIndex(of: best) else {
            return "It's a tie!"
        }
        return "Player \(winner + 1) wins!"
    }

    /// Encouraging message based on the percentage of correct answers.
    static func message(score: Int, total: Int) -> String {
        let ratio = Double(score) / Double(max(total, 1))
        switch ratio {
        case 0.9...: return "SUPERSTAR ASTRONAUT!"
        case 0.7..<0.9: return "GREAT JOB!"
        case 0.5..<0.7: return "GOOD EFFORT!"
        default: return "KEEP EXPLORING!"
        }
    }
}
