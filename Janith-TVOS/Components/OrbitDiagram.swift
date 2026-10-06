//
//  OrbitDiagram.swift
//  Janith-TVOS
//
//  An animated, perspective view of the planets orbiting the Sun.
//  The highlighted planet's orbit and label are emphasised.
//

import SwiftUI

struct OrbitDiagram: View {
    /// The `id` of the planet to emphasise (the one focused on the solar system screen).
    var highlightedID: String?
    /// Freezes the orbits.
    var isPaused: Bool = false

    var body: some View {
        PausableTimeline(isPaused: isPaused) { time in
            Canvas { context, size in
                draw(in: &context, size: size, time: time)
            }
        }
        .accessibilityHidden(true)
    }

    /// A planet's on-screen position for the current frame.
    private struct PlacedPlanet {
        let planet: Planet
        let point: CGPoint
        let radius: Double
        let depth: Double
    }

    /// Draws one frame of the diagram.
    ///
    /// Orbits are evenly spaced ellipses (not to scale), so all eight fit on screen.
    /// A planet's vertical position on its ellipse gives its depth: planets
    /// near the top are behind the Sun and drawn smaller.
    private func draw(in context: inout GraphicsContext, size: CGSize, time: Double) {
        let planets = Planet.all
        let sun = CGPoint(x: size.width / 2, y: size.height / 2)
        let innerOrbit = size.width * 0.085
        let orbitStep = (size.width / 2 - innerOrbit - 30) / Double(planets.count - 1)
        let tilt = min(0.22, (size.height / 2 - 24) / (size.width / 2))

        var placed: [PlacedPlanet] = []

        for (index, planet) in planets.enumerated() {
            let rx = innerOrbit + Double(index) * orbitStep
            let ry = rx * tilt
            let isHighlighted = planet.id == highlightedID
            let orbitRect = CGRect(x: sun.x - rx, y: sun.y - ry, width: rx * 2, height: ry * 2)
            context.stroke(
                Path(ellipseIn: orbitRect),
                with: .color(isHighlighted ? planet.accentColor.opacity(0.85) : .white.opacity(0.12)),
                lineWidth: isHighlighted ? 3 : 1.5
            )

            let angle = Double(index) * 2.4 + time * 2 * .pi / planet.orbitSeconds
            let depth = sin(angle)
            let point = CGPoint(x: sun.x + rx * cos(angle), y: sun.y + ry * depth)
            let baseRadius = 7 + planet.displayScale * 15
            let radius = baseRadius * (0.85 + 0.15 * depth) * (isHighlighted ? 1.35 : 1)
            placed.append(PlacedPlanet(planet: planet, point: point, radius: radius, depth: depth))
        }

        // Far side first, then the Sun, then the near side.
        for item in placed where item.depth < 0 { drawPlanet(item, in: &context) }
        drawSun(at: sun, radius: size.width * 0.032, in: &context)
        for item in placed where item.depth >= 0 { drawPlanet(item, in: &context) }

        if let highlighted = placed.first(where: { $0.planet.id == highlightedID }) {
            context.draw(
                Text(highlighted.planet.name)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white),
                at: CGPoint(x: highlighted.point.x, y: highlighted.point.y - highlighted.radius - 10),
                anchor: .bottom
            )
        }
    }

    /// Draws the Sun with an orange glow.
    private func drawSun(at center: CGPoint, radius: Double, in context: inout GraphicsContext) {
        let glow = radius * 3.2
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - glow, y: center.y - glow, width: glow * 2, height: glow * 2)),
            with: .radialGradient(
                Gradient(colors: [Color.orange.opacity(0.55), Color.orange.opacity(0.12), .clear]),
                center: center, startRadius: radius * 0.6, endRadius: glow
            )
        )
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
            with: .radialGradient(
                Gradient(colors: [.white, Color(red: 1, green: 0.9, blue: 0.5), Color(red: 1, green: 0.55, blue: 0.1)]),
                center: center, startRadius: 0, endRadius: radius
            )
        )
    }

    /// Draws a simple shaded planet dot (plus a ring for ringed planets, and a glow if highlighted).
    private func drawPlanet(_ item: PlacedPlanet, in context: inout GraphicsContext) {
        let r = item.radius
        let rect = CGRect(x: item.point.x - r, y: item.point.y - r, width: r * 2, height: r * 2)
        let isHighlighted = item.planet.id == highlightedID

        if isHighlighted {
            let glow = rect.insetBy(dx: -r * 0.9, dy: -r * 0.9)
            context.fill(Path(ellipseIn: glow), with: .radialGradient(
                Gradient(colors: [item.planet.accentColor.opacity(0.6), .clear]),
                center: item.point, startRadius: r * 0.8, endRadius: r * 1.9
            ))
        }

        if item.planet.appearance.rings != nil {
            let ring = CGRect(x: item.point.x - r * 2.1, y: item.point.y - r * 0.55, width: r * 4.2, height: r * 1.1)
            context.stroke(Path(ellipseIn: ring), with: .color(item.planet.accentColor.opacity(0.8)), lineWidth: r * 0.25)
        }

        let colors = item.planet.appearance.baseColors
        context.fill(Path(ellipseIn: rect), with: .radialGradient(
            Gradient(colors: [.white.opacity(0.9)] + colors + [.black.opacity(0.8)]),
            center: CGPoint(x: rect.midX - r * 0.4, y: rect.midY - r * 0.4),
            startRadius: 0, endRadius: r * 2.1
        ))
    }
}

#Preview {
    OrbitDiagram(highlightedID: "earth")
        .frame(height: 380)
        .background(StarfieldBackground())
}
