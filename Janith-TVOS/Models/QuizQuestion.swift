//
//  QuizQuestion.swift
//  Janith-TVOS
//

import Foundation

/// A multiple-choice question in the Space Quiz.
nonisolated struct QuizQuestion: Identifiable, Sendable {
    let id: Int
    /// The question text.
    let prompt: String
    /// The four possible answers.
    let options: [String]
    /// The correct answer. Must exactly match one of `options`.
    let answer: String
    /// A short explanation shown after the player answers.
    let explanation: String
    /// The planet the question is about, used to show its picture.
    let planetID: String?

    var planet: Planet? { planetID.flatMap(Planet.with(id:)) }

    /// Returns a copy with the answer options in random order, so the
    /// correct answer is not always in the same position.
    func withShuffledOptions<G: RandomNumberGenerator>(using generator: inout G) -> QuizQuestion {
        QuizQuestion(id: id, prompt: prompt, options: options.shuffled(using: &generator),
                     answer: answer, explanation: explanation, planetID: planetID)
    }
}

nonisolated extension QuizQuestion {
    /// The full question bank. Each game picks `QuizGame.questionsPerGame` of these at random.
    /// Every answer can be found in the app's planet details or facts.
    static let bank: [QuizQuestion] = [
        QuizQuestion(id: 1, prompt: "Which planet is known as the Red Planet?",
                     options: ["Venus", "Mars", "Jupiter", "Saturn"], answer: "Mars",
                     explanation: "Mars is covered in rusty, iron-rich dust.", planetID: "mars"),
        QuizQuestion(id: 2, prompt: "Which planet has the largest rings?",
                     options: ["Earth", "Saturn", "Mars", "Venus"], answer: "Saturn",
                     explanation: "Saturn's rings are made of billions of pieces of ice and rock.", planetID: "saturn"),
        QuizQuestion(id: 3, prompt: "Which planet is closest to the Sun?",
                     options: ["Venus", "Earth", "Mercury", "Mars"], answer: "Mercury",
                     explanation: "Mercury orbits just 57.9 million km from the Sun.", planetID: "mercury"),
        QuizQuestion(id: 4, prompt: "Which is the hottest planet?",
                     options: ["Mercury", "Venus", "Mars", "Jupiter"], answer: "Venus",
                     explanation: "Venus's thick clouds trap heat at about 464°C.", planetID: "venus"),
        QuizQuestion(id: 5, prompt: "Which is the largest planet in the solar system?",
                     options: ["Saturn", "Neptune", "Earth", "Jupiter"], answer: "Jupiter",
                     explanation: "More than 1,300 Earths could fit inside Jupiter.", planetID: "jupiter"),
        QuizQuestion(id: 6, prompt: "Which planet spins on its side?",
                     options: ["Uranus", "Neptune", "Mars", "Mercury"], answer: "Uranus",
                     explanation: "Uranus is tilted about 98 degrees.", planetID: "uranus"),
        QuizQuestion(id: 7, prompt: "Which planet has the fastest winds?",
                     options: ["Earth", "Jupiter", "Neptune", "Venus"], answer: "Neptune",
                     explanation: "Neptune's winds blow at over 2,000 km/h.", planetID: "neptune"),
        QuizQuestion(id: 8, prompt: "How many moons does Earth have?",
                     options: ["0", "1", "2", "3"], answer: "1",
                     explanation: "Earth has one Moon. Mars has two!", planetID: "earth"),
        QuizQuestion(id: 9, prompt: "Which is the only planet known to have life?",
                     options: ["Mars", "Earth", "Venus", "Jupiter"], answer: "Earth",
                     explanation: "So far, Earth is the only place where life has been found.", planetID: "earth"),
        QuizQuestion(id: 10, prompt: "What makes Mars look red?",
                     options: ["Lava", "Rust in its soil", "Red clouds", "Sunlight"], answer: "Rust in its soil",
                     explanation: "Iron oxide — rust — gives Mars its red colour.", planetID: "mars"),
        QuizQuestion(id: 11, prompt: "On which planet is a day longer than a year?",
                     options: ["Venus", "Mars", "Saturn", "Earth"], answer: "Venus",
                     explanation: "A Venus day is 243 Earth days, but its year is only 225.", planetID: "venus"),
        QuizQuestion(id: 12, prompt: "What is Jupiter's Great Red Spot?",
                     options: ["A volcano", "A giant storm", "A crater", "A moon"], answer: "A giant storm",
                     explanation: "It is a storm bigger than Earth that has lasted for centuries.", planetID: "jupiter"),
        QuizQuestion(id: 13, prompt: "Which planet is farthest from the Sun?",
                     options: ["Uranus", "Saturn", "Neptune", "Jupiter"], answer: "Neptune",
                     explanation: "Neptune is about 4.5 billion km from the Sun.", planetID: "neptune"),
        QuizQuestion(id: 14, prompt: "Which planet would float in a giant bathtub of water?",
                     options: ["Earth", "Mercury", "Mars", "Saturn"], answer: "Saturn",
                     explanation: "Saturn is less dense than water.", planetID: "saturn"),
    ]
}
