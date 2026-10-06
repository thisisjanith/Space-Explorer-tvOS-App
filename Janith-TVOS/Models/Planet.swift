//
//  Planet.swift
//  Janith-TVOS
//
//  A single reusable model that describes every planet in the app.
//

import SwiftUI

/// Everything the app knows about one planet: display text, statistics,
/// "Did You Know?" facts and how it should be drawn and animated.
///
/// All eight planets are defined in `PlanetData.swift`, and every screen
/// (details, exploration, facts) is a single view that takes a `Planet`,
/// so adding or changing a planet never requires new UI code.
nonisolated struct Planet: Identifiable, Hashable, Sendable {
    /// Stable lowercase identifier, e.g. `"earth"`. Also used for focus tracking.
    let id: String
    /// Display name, e.g. `"Earth"`.
    let name: String
    /// Position from the Sun (1 = Mercury … 8 = Neptune).
    let order: Int
    /// Short friendly title, e.g. `"The Red Planet"`.
    let nickname: String
    /// One or two sentences shown on the solar system and details screens.
    let summary: String

    // Statistics are stored as pre-formatted strings because they are only displayed.
    let distanceFromSun: String
    let diameter: String
    /// Average surface (or cloud-top) temperature.
    let temperature: String
    /// Number of known moons.
    let moons: Int
    /// Time for one full spin on its axis.
    let dayLength: String
    /// Time for one full orbit around the Sun.
    let yearLength: String
    let axialTilt: String

    /// Interesting facts shown on the "Did You Know?" screen.
    let facts: [String]

    /// Real rotation period in hours. Negative values mean the planet spins backwards (retrograde).
    let rotationHours: Double
    /// Real orbital period in Earth days.
    let orbitalPeriodDays: Double
    /// Relative on-screen size (0…1) used for thumbnails and the orbit diagram.
    let displayScale: Double

    /// Colours, surface features and rings used by `PlanetView` to draw the planet.
    let appearance: PlanetAppearance

    // Equality and hashing use only the id, so a `Planet` can be used in navigation routes.
    static func == (lhs: Planet, rhs: Planet) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    /// The main accent colour of the planet, used for glows and highlights.
    var accentColor: Color { appearance.accent }

    /// Seconds for one on-screen spin. Real periods range from 10 hours to 243 days,
    /// so they are compressed logarithmically to keep every planet visibly moving.
    var spinSeconds: Double { 3.5 * log2(abs(rotationHours)) }

    /// +1 for normal (prograde) spin, -1 for retrograde spin.
    var spinDirection: Double { rotationHours < 0 ? -1 : 1 }

    /// Seconds for one on-screen orbit around the Sun in the solar system diagram.
    var orbitSeconds: Double { 14 * pow(orbitalPeriodDays / 88, 0.4) }
}

// MARK: - Appearance

/// Describes how a planet looks. Planets are drawn procedurally in code
/// (see `PlanetView`), so no image assets are needed.
nonisolated struct PlanetAppearance: Sendable {
    /// Base gradient from the north pole (first) to the south pole (last).
    var baseColors: [Color]
    /// Horizontal cloud or ice bands that do not move with rotation.
    var bands: [PlanetBand] = []
    /// Surface features (continents, storms, craters) that rotate with the planet.
    var features: [SurfaceFeature] = []
    /// A cloud layer that drifts slightly faster than the surface.
    var clouds: [SurfaceFeature] = []
    /// Colour of the soft glow around the planet, or `nil` for no atmosphere.
    var atmosphere: Color? = nil
    /// Ring system, or `nil` if the planet has no visible rings.
    var rings: RingStyle? = nil
    /// Visual tilt of the spin axis in degrees.
    var visualTilt: Double = 0
    /// Blur applied to surface details, as a fraction of the radius.
    var softness: Double = 0.02
    /// UI accent colour for this planet (focus glow, headings, stat icons).
    var accent: Color
}

/// A latitude band expressed as the sine of latitude (+1 = north pole, -1 = south pole).
nonisolated struct PlanetBand: Sendable {
    var upper: Double
    var lower: Double
    var color: Color
    var opacity: Double = 1
}

/// A blob drawn on the sphere. Sizes are fractions of the planet radius.
nonisolated struct SurfaceFeature: Sendable {
    /// Longitude in radians. Rotation is applied by adding to this value.
    var longitude: Double
    /// Latitude in radians (positive = north).
    var latitude: Double
    var width: Double
    var height: Double
    var color: Color
    var opacity: Double = 1
}

/// A planet's ring system: solid bands plus small particles that orbit
/// so the rings visibly turn.
nonisolated struct RingStyle: Sendable {
    var bands: [RingBand]
    /// How flattened the rings look from our viewpoint (1 = circle, 0 = line).
    var squash: Double = 0.3
    var particleColor: Color
    var particles: [RingParticle]

    /// Outer edge of the rings in planet radii; used to size views so rings fit on screen.
    var outerRadius: Double { bands.map(\.outer).max() ?? 1 }

    /// Creates a ring style and scatters `particleCount` particles across the bands.
    /// - Parameter seed: Random seed so the particles are identical on every launch.
    init(bands: [RingBand], squash: Double = 0.3, particleColor: Color, particleCount: Int, seed: UInt64) {
        self.bands = bands
        self.squash = squash
        self.particleColor = particleColor
        var rng = SeededGenerator(seed: seed)
        let inner = bands.map(\.inner).min() ?? 1.2
        let outer = bands.map(\.outer).max() ?? 2
        particles = (0..<particleCount).map { _ in
            RingParticle(
                radius: Double.random(in: inner...outer, using: &rng),
                angle: Double.random(in: 0...(2 * .pi), using: &rng),
                size: Double.random(in: 0.006...0.016, using: &rng),
                opacity: Double.random(in: 0.3...0.9, using: &rng)
            )
        }
    }
}

/// A ring band measured in planet radii from the centre.
nonisolated struct RingBand: Sendable {
    var inner: Double
    var outer: Double
    var color: Color
    var opacity: Double
}

/// One speck of ice or rock in a ring. Radius is in planet radii, angle in radians.
nonisolated struct RingParticle: Sendable {
    var radius: Double
    var angle: Double
    var size: Double
    var opacity: Double
}

// MARK: - Procedural helpers

nonisolated extension SurfaceFeature {
    /// Scatters blobs randomly but repeatably across a region of the planet.
    /// Used for craters, storms, clouds and dust patches.
    ///
    /// - Parameters:
    ///   - seed: Random seed; the same seed always produces the same features.
    ///   - count: Number of blobs to create.
    ///   - colors: Each blob picks one of these colours at random.
    ///   - width: Range of blob widths, as a fraction of the planet radius.
    ///   - aspect: Height-to-width ratio range (small values give long streaks).
    ///   - latitude: Latitude range in radians.
    ///   - longitude: Longitude range in radians.
    ///   - opacity: Opacity range.
    static func scatter(
        seed: UInt64,
        count: Int,
        colors: [Color],
        width: ClosedRange<Double>,
        aspect: ClosedRange<Double> = 0.6...1.0,
        latitude: ClosedRange<Double> = -1.3...1.3,
        longitude: ClosedRange<Double> = 0...(2 * .pi),
        opacity: ClosedRange<Double> = 0.6...1
    ) -> [SurfaceFeature] {
        var rng = SeededGenerator(seed: seed)
        return (0..<count).map { _ in
            let w = Double.random(in: width, using: &rng)
            return SurfaceFeature(
                longitude: Double.random(in: longitude, using: &rng),
                latitude: Double.random(in: latitude, using: &rng),
                width: w,
                height: w * Double.random(in: aspect, using: &rng),
                color: colors.randomElement(using: &rng) ?? .white,
                opacity: Double.random(in: opacity, using: &rng)
            )
        }
    }

    /// Builds a land mass from overlapping blobs around a centre point (used for Earth's continents).
    /// - Parameter spread: How far blobs may be placed from the centre, in radians.
    static func landmass(
        seed: UInt64,
        longitude: Double,
        latitude: Double,
        spread: (lon: Double, lat: Double),
        count: Int,
        colors: [Color]
    ) -> [SurfaceFeature] {
        scatter(
            seed: seed,
            count: count,
            colors: colors,
            width: 0.18...0.42,
            aspect: 0.7...1.2,
            latitude: (latitude - spread.lat)...(latitude + spread.lat),
            longitude: (longitude - spread.lon)...(longitude + spread.lon),
            opacity: 0.85...1
        )
    }
}

/// A small, deterministic random number generator (SplitMix64) so the
/// procedurally generated planets look identical on every launch.
nonisolated struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
