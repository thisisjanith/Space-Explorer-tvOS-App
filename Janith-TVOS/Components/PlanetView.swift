//
//  PlanetView.swift
//  Janith-TVOS
//
//  Draws a rotating planet without any 3D engine: surface features are
//  projected onto a sphere so they move across the disc as it spins, rings
//  and moons are split into a back half (behind the planet) and a front half.
//

import SwiftUI

/// An animated, rotating planet. Used on every screen, from small cards to the
/// full-screen exploration view.
///
/// The view's frame is the size of the planet's disc. Rings and moons draw
/// outside that frame, so leave space around ringed planets.
struct PlanetView: View {
    let planet: Planet
    /// Diameter of the planet disc in points.
    var size: CGFloat
    /// Freezes the rotation (used by the Play/Pause button).
    var isPaused: Bool = false
    /// Shows up to four moons orbiting the planet.
    var showsMoons: Bool = false

    var body: some View {
        PausableTimeline(isPaused: isPaused) { time in
            PlanetFrame(planet: planet, size: size, time: time, showsMoons: showsMoons)
        }
        .frame(width: size, height: size)
        .accessibilityElement()
        .accessibilityLabel(planet.name)
    }
}

/// One frame of the planet at a given time.
private struct PlanetFrame: View {
    let planet: Planet
    let size: CGFloat
    let time: Double
    let showsMoons: Bool

    private var appearance: PlanetAppearance { planet.appearance }
    /// Current spin angle in radians.
    private var rotation: Double { planet.spinDirection * time * 2 * .pi / planet.spinSeconds }
    private var moonCount: Int { showsMoons ? min(planet.moons, 4) : 0 }

    var body: some View {
        // Layers are drawn back to front: glow, far moons, far rings, planet, near rings, near moons.
        ZStack {
            if let atmosphere = appearance.atmosphere {
                Circle()
                    .fill(atmosphere.opacity(0.35))
                    .frame(width: size * 1.1, height: size * 1.1)
                    .blur(radius: size * 0.06)
            }
            if moonCount > 0 {
                MoonLayer(count: moonCount, planetSize: size, time: time, half: .back)
            }
            if let rings = appearance.rings {
                RingLayer(style: rings, planetSize: size, rotation: rotation, half: .back)
            }
            PlanetSurface(appearance: appearance, rotation: rotation)
                .frame(width: size, height: size)
            if let rings = appearance.rings {
                RingLayer(style: rings, planetSize: size, rotation: rotation, half: .front)
            }
            if moonCount > 0 {
                MoonLayer(count: moonCount, planetSize: size, time: time, half: .front)
            }
        }
        .rotationEffect(.degrees(appearance.visualTilt))
    }
}

/// Which half of an orbit to draw. Rings and moons are drawn twice so they can pass behind the planet.
private enum Half {
    case back
    case front

    /// Keeps only the half of an orbit that is behind (upper) or in front of (lower) the planet.
    func clipRect(in size: CGSize) -> CGRect {
        switch self {
        case .back: CGRect(x: 0, y: 0, width: size.width, height: size.height / 2)
        case .front: CGRect(x: 0, y: size.height / 2, width: size.width, height: size.height / 2)
        }
    }
}

// MARK: - Surface

/// The planet disc: base colour, bands, rotating surface features and lighting.
private struct PlanetSurface: View {
    let appearance: PlanetAppearance
    let rotation: Double

    var body: some View {
        Canvas { context, size in
            let diameter = min(size.width, size.height)
            let rect = CGRect(x: (size.width - diameter) / 2, y: (size.height - diameter) / 2,
                              width: diameter, height: diameter)
            let radius = diameter / 2
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let disc = Path(ellipseIn: rect)

            context.clip(to: disc)
            context.fill(disc, with: .linearGradient(
                Gradient(colors: appearance.baseColors),
                startPoint: CGPoint(x: rect.midX, y: rect.minY),
                endPoint: CGPoint(x: rect.midX, y: rect.maxY)
            ))

            context.drawLayer { layer in
                layer.addFilter(.blur(radius: radius * appearance.softness))
                for band in appearance.bands {
                    let top = center.y - radius * band.upper
                    let bottom = center.y - radius * band.lower
                    layer.fill(Path(CGRect(x: rect.minX, y: top, width: rect.width, height: bottom - top)),
                               with: .color(band.color.opacity(band.opacity)))
                }
                Self.draw(appearance.features, in: &layer, center: center, radius: radius, rotation: rotation)
                Self.draw(appearance.clouds, in: &layer, center: center, radius: radius, rotation: rotation * 1.25 + 1)
            }

            // Sunlight from the upper left with a dark night side.
            let light = CGPoint(x: center.x - radius * 0.45, y: center.y - radius * 0.45)
            context.fill(disc, with: .radialGradient(
                Gradient(stops: [
                    .init(color: .white.opacity(0.22), location: 0),
                    .init(color: .clear, location: 0.32),
                    .init(color: .black.opacity(0.45), location: 0.72),
                    .init(color: .black.opacity(0.88), location: 1),
                ]),
                center: light, startRadius: 0, endRadius: radius * 1.9
            ))

            if let atmosphere = appearance.atmosphere {
                context.stroke(disc, with: .color(atmosphere.opacity(0.45)), lineWidth: radius * 0.05)
            }
        }
    }

    /// Orthographic projection of each feature onto the visible hemisphere.
    ///
    /// `depth` (cosine of the angle from the centre of the disc) is 1 when a feature
    /// faces the viewer and 0 at the edge. Features are narrowed and faded near the
    /// edge and skipped on the far side, which makes a flat drawing look like a
    /// spinning sphere.
    private static func draw(_ features: [SurfaceFeature], in context: inout GraphicsContext,
                             center: CGPoint, radius: Double, rotation: Double) {
        for feature in features {
            let angle = feature.longitude + rotation
            let depth = cos(angle)
            guard depth > -0.05 else { continue }

            let latitudeScale = max(cos(feature.latitude), 0.3)
            let x = center.x + radius * cos(feature.latitude) * sin(angle)
            let y = center.y - radius * sin(feature.latitude)
            let width = radius * feature.width * max(depth, 0.08) * latitudeScale
            let height = radius * feature.height * latitudeScale
            let fade = min(1, (depth + 0.05) / 0.3)

            context.fill(
                Path(ellipseIn: CGRect(x: x - width / 2, y: y - height / 2, width: width, height: height)),
                with: .color(feature.color.opacity(feature.opacity * fade))
            )
        }
    }
}

// MARK: - Rings

/// Draws one half of a ring system. Each band is filled as the area between two
/// ellipses (even-odd fill), so it keeps the correct thickness when flattened.
private struct RingLayer: View {
    let style: RingStyle
    let planetSize: CGFloat
    let rotation: Double
    let half: Half

    var body: some View {
        let extent = planetSize * style.outerRadius
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let planetRadius = planetSize / 2
            context.clip(to: Path(half.clipRect(in: size)))

            for band in style.bands {
                var ring = Path()
                ring.addEllipse(in: ellipseRect(center: center, radius: band.outer * planetRadius))
                ring.addEllipse(in: ellipseRect(center: center, radius: band.inner * planetRadius))
                context.fill(ring, with: .color(band.color.opacity(band.opacity)), style: FillStyle(eoFill: true))
            }

            // Particles orbit at different speeds (inner ones faster) to show the rings turning.
            for particle in style.particles {
                let speed = 0.35 / pow(particle.radius, 1.5)
                let angle = particle.angle + rotation * speed
                let r = particle.radius * planetRadius
                let x = center.x + r * cos(angle)
                let y = center.y + r * style.squash * sin(angle)
                let dot = particle.size * planetRadius
                context.fill(Path(ellipseIn: CGRect(x: x - dot / 2, y: y - dot / 2, width: dot, height: dot)),
                             with: .color(style.particleColor.opacity(particle.opacity)))
            }
        }
        .frame(width: extent, height: extent)
        .allowsHitTesting(false)
    }

    /// Bounding box of a ring ellipse, flattened by the style's `squash`.
    private func ellipseRect(center: CGPoint, radius: Double) -> CGRect {
        CGRect(x: center.x - radius, y: center.y - radius * style.squash,
               width: radius * 2, height: radius * 2 * style.squash)
    }
}

// MARK: - Moons

/// Draws one half of the moons' orbits. Moons look slightly larger when they are in front of the planet.
private struct MoonLayer: View {
    let count: Int
    let planetSize: CGFloat
    let time: Double
    let half: Half

    private let squash = 0.22

    var body: some View {
        let extent = planetSize * 2.8
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            context.clip(to: Path(half.clipRect(in: size)))

            for index in 0..<count {
                let orbit = planetSize * (0.78 + Double(index) * 0.2)
                let period = 9.0 + Double(index) * 5
                let angle = Double(index) * 1.7 + time * 2 * .pi / period
                let depth = sin(angle)
                let moonSize = planetSize * (0.075 + 0.015 * depth)
                let x = center.x + orbit * cos(angle)
                let y = center.y + orbit * squash * depth
                let rect = CGRect(x: x - moonSize / 2, y: y - moonSize / 2, width: moonSize, height: moonSize)
                context.fill(Path(ellipseIn: rect), with: .radialGradient(
                    Gradient(colors: [Color(white: 0.95), Color(white: 0.55), Color(white: 0.2)]),
                    center: CGPoint(x: rect.midX - moonSize * 0.2, y: rect.midY - moonSize * 0.2),
                    startRadius: 0, endRadius: moonSize * 0.75
                ))
            }
        }
        .frame(width: extent, height: extent)
        .allowsHitTesting(false)
    }
}

#Preview {
    HStack(spacing: 120) {
        PlanetView(planet: .earth, size: 300, showsMoons: true)
        PlanetView(planet: .saturn, size: 300)
        PlanetView(planet: .uranus, size: 220)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(StarfieldBackground())
}
