//
//  StarfieldBackground.swift
//  Janith-TVOS
//
//  Deep-space backdrop: nebula glow, slowly drifting twinkling stars and
//  the occasional shooting star.
//

import SwiftUI

/// Full-screen animated background used behind every screen.
struct StarfieldBackground: View {
    /// One star. Positions are 0…1 fractions of the screen so they fit any screen size.
    private struct Star {
        var x: Double
        var y: Double
        var radius: Double
        var brightness: Double
        /// How fast the star twinkles.
        var twinkleSpeed: Double
        /// Starting point of the twinkle, so stars don't all pulse together.
        var phase: Double
        /// Horizontal drift speed in points per second. Nearer (brighter) stars drift faster for a parallax effect.
        var drift: Double
    }

    /// Generated once with a fixed seed so the star pattern is the same on every screen.
    private static let stars: [Star] = {
        var rng = SeededGenerator(seed: 2026)
        return (0..<260).map { _ in
            let depth = Double.random(in: 0...1, using: &rng)
            return Star(
                x: .random(in: 0...1, using: &rng),
                y: .random(in: 0...1, using: &rng),
                radius: 0.6 + depth * 1.8,
                brightness: 0.35 + depth * 0.65,
                twinkleSpeed: .random(in: 0.4...2.2, using: &rng),
                phase: .random(in: 0...(2 * .pi), using: &rng),
                drift: 1.5 + depth * 6
            )
        }
    }()

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.deepSpace, Theme.navy.opacity(0.9), Theme.deepSpace],
                           startPoint: .top, endPoint: .bottom)

            RadialGradient(colors: [Theme.purple.opacity(0.28), .clear],
                           center: UnitPoint(x: 0.85, y: 0.15), startRadius: 0, endRadius: 900)
            RadialGradient(colors: [Theme.blue.opacity(0.18), .clear],
                           center: UnitPoint(x: 0.1, y: 0.9), startRadius: 0, endRadius: 800)

            TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                Canvas { context, size in
                    Self.drawStars(in: &context, size: size, time: time)
                    Self.drawShootingStar(in: &context, size: size, time: time)
                }
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    /// Draws every star, drifting right and wrapping around the screen edge.
    private static func drawStars(in context: inout GraphicsContext, size: CGSize, time: Double) {
        let width = size.width + 20
        for star in stars {
            var x = (star.x * width + time * star.drift).truncatingRemainder(dividingBy: width) - 10
            if x < -10 { x += width }
            let y = star.y * size.height
            let twinkle = 0.55 + 0.45 * sin(time * star.twinkleSpeed + star.phase)
            let r = star.radius
            context.fill(
                Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                with: .color(.white.opacity(star.brightness * twinkle))
            )
        }
    }

    /// Draws a shooting star for about one second every nine seconds.
    /// Each cycle uses its own seed, so every shooting star takes a different path.
    private static func drawShootingStar(in context: inout GraphicsContext, size: CGSize, time: Double) {
        let cycleLength = 9.0
        let duration = 1.1
        let cycle = floor(time / cycleLength)
        let local = time - cycle * cycleLength
        guard local < duration else { return }

        var rng = SeededGenerator(seed: UInt64(bitPattern: Int64(cycle)))
        let start = CGPoint(x: Double.random(in: 0.1...0.7, using: &rng) * size.width,
                            y: Double.random(in: 0.0...0.35, using: &rng) * size.height)
        let angle = Double.random(in: 0.25...0.6, using: &rng)
        let travel = size.width * 0.35
        let progress = local / duration
        let head = CGPoint(x: start.x + cos(angle) * travel * progress,
                           y: start.y + sin(angle) * travel * progress)
        let tailLength = 160.0
        let tail = CGPoint(x: head.x - cos(angle) * tailLength, y: head.y - sin(angle) * tailLength)
        let fade = sin(progress * .pi)

        var path = Path()
        path.move(to: tail)
        path.addLine(to: head)
        context.stroke(
            path,
            with: .linearGradient(Gradient(colors: [.clear, .white.opacity(0.9 * fade)]), startPoint: tail, endPoint: head),
            style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
        )
    }
}

#Preview {
    StarfieldBackground()
}
