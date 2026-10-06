//
//  PlanetData.swift
//  Janith-TVOS
//
//  Facts and figures for the eight planets (source: NASA planetary fact sheets).
//

import SwiftUI

nonisolated extension Planet {
    /// All eight planets in order from the Sun.
    static let all: [Planet] = [mercury, venus, earth, mars, jupiter, saturn, uranus, neptune]

    /// Looks up a planet by its `id` (e.g. `"mars"`). Returns `nil` if the id is unknown.
    static func with(id: String) -> Planet? { all.first { $0.id == id } }

    // Each planet below defines its facts, then its appearance. Surface details are
    // generated from fixed seeds so they look identical on every launch.

    // MARK: Mercury

    static let mercury = Planet(
        id: "mercury",
        name: "Mercury",
        order: 1,
        nickname: "The Swift Planet",
        summary: "The smallest planet and the closest to the Sun. It races around its orbit faster than any other planet.",
        distanceFromSun: "57.9 million km",
        diameter: "4,879 km",
        temperature: "167°C",
        moons: 0,
        dayLength: "59 Earth days",
        yearLength: "88 Earth days",
        axialTilt: "0.03°",
        facts: [
            "A year on Mercury lasts just 88 Earth days — the shortest year of any planet.",
            "Mercury has almost no atmosphere, so it swings from 430°C in the day to −180°C at night.",
            "Even though it is closest to the Sun, Mercury is not the hottest planet. Venus is!",
        ],
        rotationHours: 1407.6,
        orbitalPeriodDays: 88,
        displayScale: 0.42,
        appearance: PlanetAppearance(
            baseColors: [Color(white: 0.68), Color(white: 0.46)],
            features: SurfaceFeature.scatter(
                seed: 11, count: 46,
                colors: [Color(white: 0.32), Color(white: 0.48), Color(white: 0.8)],
                width: 0.05...0.2, aspect: 0.85...1, opacity: 0.35...0.75
            ),
            softness: 0.008,
            accent: Color(white: 0.75)
        )
    )

    // MARK: Venus

    static let venus = Planet(
        id: "venus",
        name: "Venus",
        order: 2,
        nickname: "Earth's Twin",
        summary: "A rocky world wrapped in thick, toxic clouds. It is the brightest planet in our night sky.",
        distanceFromSun: "108.2 million km",
        diameter: "12,104 km",
        temperature: "464°C",
        moons: 0,
        dayLength: "243 Earth days",
        yearLength: "225 Earth days",
        axialTilt: "177.4°",
        facts: [
            "Venus spins backwards compared to most planets, so the Sun rises in the west.",
            "A day on Venus (243 Earth days) is longer than its whole year (225 Earth days).",
            "Venus is the hottest planet. Its thick clouds trap heat at about 464°C — hot enough to melt lead.",
        ],
        rotationHours: -5832.5,
        orbitalPeriodDays: 224.7,
        displayScale: 0.62,
        appearance: PlanetAppearance(
            baseColors: [Color(red: 1.0, green: 0.88, blue: 0.6), Color(red: 0.86, green: 0.62, blue: 0.3)],
            bands: [
                PlanetBand(upper: 0.7, lower: 0.45, color: Color(red: 0.95, green: 0.78, blue: 0.48), opacity: 0.6),
                PlanetBand(upper: 0.1, lower: -0.15, color: Color(red: 1.0, green: 0.9, blue: 0.68), opacity: 0.5),
                PlanetBand(upper: -0.5, lower: -0.75, color: Color(red: 0.9, green: 0.7, blue: 0.4), opacity: 0.6),
            ],
            clouds: SurfaceFeature.scatter(
                seed: 22, count: 26,
                colors: [Color(red: 1.0, green: 0.95, blue: 0.8), Color(red: 0.8, green: 0.56, blue: 0.28)],
                width: 0.3...0.8, aspect: 0.1...0.25, opacity: 0.3...0.6
            ),
            atmosphere: Color(red: 1.0, green: 0.85, blue: 0.5),
            visualTilt: 2.6,
            softness: 0.05,
            accent: Color(red: 1.0, green: 0.8, blue: 0.45)
        )
    )

    // MARK: Earth

    static let earth: Planet = {
        let land = [
            Color(red: 0.2, green: 0.5, blue: 0.22),
            Color(red: 0.36, green: 0.55, blue: 0.24),
            Color(red: 0.68, green: 0.6, blue: 0.38),
        ]
        let continents =
            SurfaceFeature.landmass(seed: 31, longitude: 0.0, latitude: 0.75, spread: (0.5, 0.3), count: 16, colors: land)
            + SurfaceFeature.landmass(seed: 32, longitude: 0.55, latitude: -0.3, spread: (0.22, 0.42), count: 11, colors: land)
            + SurfaceFeature.landmass(seed: 33, longitude: 1.95, latitude: 0.1, spread: (0.3, 0.5), count: 17, colors: land)
            + SurfaceFeature.landmass(seed: 34, longitude: 1.9, latitude: 0.85, spread: (0.3, 0.14), count: 7, colors: land)
            + SurfaceFeature.landmass(seed: 35, longitude: 2.9, latitude: 0.75, spread: (0.6, 0.3), count: 20, colors: land)
            + SurfaceFeature.landmass(seed: 36, longitude: 3.95, latitude: -0.45, spread: (0.2, 0.15), count: 7, colors: land)

        return Planet(
            id: "earth",
            name: "Earth",
            order: 3,
            nickname: "Our Home Planet",
            summary: "Our home — a world of oceans and continents, and the only place known to support life.",
            distanceFromSun: "149.6 million km",
            diameter: "12,756 km",
            temperature: "15°C",
            moons: 1,
            dayLength: "24 hours",
            yearLength: "365.25 days",
            axialTilt: "23.4°",
            facts: [
                "Earth is the only known place in the universe where life exists.",
                "About 71% of Earth's surface is covered by water — that's why it is called the Blue Planet.",
                "Earth is the densest planet in the solar system.",
            ],
            rotationHours: 23.93,
            orbitalPeriodDays: 365.25,
            displayScale: 0.66,
            appearance: PlanetAppearance(
                baseColors: [Color(red: 0.14, green: 0.42, blue: 0.88), Color(red: 0.04, green: 0.18, blue: 0.55)],
                bands: [
                    PlanetBand(upper: 1.0, lower: 0.93, color: .white, opacity: 0.95),
                    PlanetBand(upper: -0.92, lower: -1.0, color: .white, opacity: 0.95),
                ],
                features: continents,
                clouds: SurfaceFeature.scatter(
                    seed: 37, count: 28, colors: [.white],
                    width: 0.25...0.6, aspect: 0.12...0.3, opacity: 0.35...0.7
                ),
                atmosphere: Color(red: 0.45, green: 0.75, blue: 1.0),
                visualTilt: 23.4,
                accent: Color(red: 0.35, green: 0.7, blue: 1.0)
            )
        )
    }()

    // MARK: Mars

    static let mars = Planet(
        id: "mars",
        name: "Mars",
        order: 4,
        nickname: "The Red Planet",
        summary: "A cold, dusty desert world with giant volcanoes, deep canyons and icy poles.",
        distanceFromSun: "227.9 million km",
        diameter: "6,792 km",
        temperature: "−65°C",
        moons: 2,
        dayLength: "24.6 hours",
        yearLength: "687 Earth days",
        axialTilt: "25.2°",
        facts: [
            "Mars looks red because its soil is full of iron oxide — the same thing as rust!",
            "Olympus Mons on Mars is the tallest volcano in the solar system, about 2.5 times the height of Mount Everest.",
            "Mars has two small moons called Phobos and Deimos.",
        ],
        rotationHours: 24.62,
        orbitalPeriodDays: 687,
        displayScale: 0.5,
        appearance: PlanetAppearance(
            baseColors: [Color(red: 0.88, green: 0.45, blue: 0.24), Color(red: 0.62, green: 0.26, blue: 0.12)],
            bands: [
                PlanetBand(upper: 1.0, lower: 0.94, color: .white, opacity: 0.9),
                PlanetBand(upper: -0.96, lower: -1.0, color: .white, opacity: 0.8),
            ],
            features: SurfaceFeature.scatter(
                seed: 41, count: 22,
                colors: [Color(red: 0.48, green: 0.2, blue: 0.1), Color(red: 0.64, green: 0.3, blue: 0.15), Color(red: 0.95, green: 0.62, blue: 0.4)],
                width: 0.15...0.45, aspect: 0.5...0.9, latitude: -1...1, opacity: 0.5...0.8
            ),
            atmosphere: Color(red: 1.0, green: 0.6, blue: 0.4),
            visualTilt: 25.2,
            softness: 0.025,
            accent: Color(red: 1.0, green: 0.45, blue: 0.25)
        )
    )

    // MARK: Jupiter

    static let jupiter: Planet = {
        let cream = Color(red: 0.95, green: 0.89, blue: 0.77)
        let tan = Color(red: 0.77, green: 0.57, blue: 0.39)
        let brown = Color(red: 0.66, green: 0.44, blue: 0.3)
        let polar = Color(red: 0.6, green: 0.52, blue: 0.45)
        let greatRedSpot = [
            SurfaceFeature(longitude: 1.0, latitude: -0.38, width: 0.46, height: 0.27, color: cream, opacity: 0.9),
            SurfaceFeature(longitude: 1.0, latitude: -0.38, width: 0.36, height: 0.19, color: Color(red: 0.8, green: 0.36, blue: 0.22)),
            SurfaceFeature(longitude: 1.0, latitude: -0.38, width: 0.2, height: 0.1, color: Color(red: 0.86, green: 0.45, blue: 0.3)),
        ]
        let storms = SurfaceFeature.scatter(
            seed: 51, count: 44,
            colors: [cream, brown, .white, tan],
            width: 0.1...0.35, aspect: 0.15...0.35, latitude: -1.1...1.1, opacity: 0.3...0.65
        )

        return Planet(
            id: "jupiter",
            name: "Jupiter",
            order: 5,
            nickname: "King of the Planets",
            summary: "The largest planet: a giant ball of gas with colourful cloud bands and enormous storms.",
            distanceFromSun: "778.5 million km",
            diameter: "142,984 km",
            temperature: "−110°C",
            moons: 95,
            dayLength: "9.9 hours",
            yearLength: "11.9 Earth years",
            axialTilt: "3.1°",
            facts: [
                "Jupiter is so big that more than 1,300 Earths could fit inside it.",
                "The Great Red Spot is a storm bigger than Earth that has been raging for hundreds of years.",
                "Jupiter has the shortest day of any planet — less than 10 hours.",
            ],
            rotationHours: 9.93,
            orbitalPeriodDays: 4333,
            displayScale: 1.0,
            appearance: PlanetAppearance(
                baseColors: [polar, cream, polar],
                bands: [
                    PlanetBand(upper: 1.0, lower: 0.8, color: polar),
                    PlanetBand(upper: 0.8, lower: 0.55, color: cream, opacity: 0.9),
                    PlanetBand(upper: 0.55, lower: 0.4, color: tan),
                    PlanetBand(upper: 0.4, lower: 0.25, color: cream),
                    PlanetBand(upper: 0.25, lower: 0.1, color: brown),
                    PlanetBand(upper: 0.1, lower: -0.1, color: Color(red: 0.97, green: 0.92, blue: 0.8)),
                    PlanetBand(upper: -0.1, lower: -0.27, color: brown),
                    PlanetBand(upper: -0.27, lower: -0.45, color: cream),
                    PlanetBand(upper: -0.45, lower: -0.6, color: tan),
                    PlanetBand(upper: -0.6, lower: -0.8, color: cream, opacity: 0.85),
                    PlanetBand(upper: -0.8, lower: -1.0, color: polar),
                ],
                features: storms + greatRedSpot,
                visualTilt: 3.1,
                softness: 0.018,
                accent: Color(red: 0.95, green: 0.7, blue: 0.45)
            )
        )
    }()

    // MARK: Saturn

    static let saturn: Planet = {
        let gold = Color(red: 0.95, green: 0.87, blue: 0.65)
        return Planet(
            id: "saturn",
            name: "Saturn",
            order: 6,
            nickname: "The Ringed Jewel",
            summary: "A gas giant famous for its spectacular rings made of ice and rock.",
            distanceFromSun: "1.43 billion km",
            diameter: "120,536 km",
            temperature: "−140°C",
            moons: 274,
            dayLength: "10.7 hours",
            yearLength: "29.4 Earth years",
            axialTilt: "26.7°",
            facts: [
                "Saturn's rings are made of billions of pieces of ice and rock — some as small as dust, some as big as a house.",
                "Saturn is so light for its size that it would float in a giant bathtub of water.",
                "Saturn has more known moons than any other planet in the solar system.",
            ],
            rotationHours: 10.66,
            orbitalPeriodDays: 10759,
            displayScale: 0.8,
            appearance: PlanetAppearance(
                baseColors: [Color(red: 0.78, green: 0.72, blue: 0.56), gold, Color(red: 0.78, green: 0.7, blue: 0.52)],
                bands: [
                    PlanetBand(upper: 1.0, lower: 0.85, color: Color(red: 0.72, green: 0.68, blue: 0.55), opacity: 0.8),
                    PlanetBand(upper: 0.85, lower: 0.6, color: Color(red: 0.88, green: 0.78, blue: 0.55), opacity: 0.8),
                    PlanetBand(upper: 0.6, lower: 0.35, color: gold, opacity: 0.8),
                    PlanetBand(upper: 0.35, lower: 0.15, color: Color(red: 0.85, green: 0.72, blue: 0.48), opacity: 0.8),
                    PlanetBand(upper: 0.15, lower: -0.15, color: Color(red: 0.97, green: 0.91, blue: 0.72), opacity: 0.8),
                    PlanetBand(upper: -0.15, lower: -0.4, color: Color(red: 0.88, green: 0.76, blue: 0.5), opacity: 0.8),
                    PlanetBand(upper: -0.4, lower: -0.7, color: Color(red: 0.93, green: 0.85, blue: 0.62), opacity: 0.8),
                    PlanetBand(upper: -0.7, lower: -1.0, color: Color(red: 0.78, green: 0.7, blue: 0.55), opacity: 0.8),
                ],
                features: SurfaceFeature.scatter(
                    seed: 61, count: 24,
                    colors: [gold, Color(red: 0.82, green: 0.7, blue: 0.48), .white],
                    width: 0.15...0.4, aspect: 0.12...0.25, latitude: -1.1...1.1, opacity: 0.25...0.5
                ),
                rings: RingStyle(
                    bands: [
                        RingBand(inner: 1.24, outer: 1.52, color: Color(red: 0.6, green: 0.55, blue: 0.45), opacity: 0.4),
                        RingBand(inner: 1.53, outer: 1.95, color: Color(red: 0.93, green: 0.85, blue: 0.67), opacity: 0.9),
                        RingBand(inner: 2.03, outer: 2.27, color: Color(red: 0.82, green: 0.74, blue: 0.58), opacity: 0.75),
                    ],
                    squash: 0.28,
                    particleColor: .white,
                    particleCount: 160,
                    seed: 62
                ),
                visualTilt: 26.7,
                softness: 0.025,
                accent: Color(red: 0.95, green: 0.82, blue: 0.55)
            )
        )
    }()

    // MARK: Uranus

    static let uranus = Planet(
        id: "uranus",
        name: "Uranus",
        order: 7,
        nickname: "The Sideways Planet",
        summary: "An icy giant that spins on its side, rolling around the Sun like a ball.",
        distanceFromSun: "2.87 billion km",
        diameter: "51,118 km",
        temperature: "−195°C",
        moons: 29,
        dayLength: "17.2 hours",
        yearLength: "84 Earth years",
        axialTilt: "97.8°",
        facts: [
            "Uranus spins on its side — its axis is tilted about 98 degrees.",
            "Uranus was the first planet discovered with a telescope, by William Herschel in 1781.",
            "Each pole of Uranus gets about 42 years of sunlight, followed by 42 years of darkness.",
        ],
        rotationHours: -17.24,
        orbitalPeriodDays: 30687,
        displayScale: 0.7,
        appearance: PlanetAppearance(
            baseColors: [Color(red: 0.72, green: 0.94, blue: 0.96), Color(red: 0.48, green: 0.8, blue: 0.86)],
            bands: [
                PlanetBand(upper: 0.6, lower: 0.35, color: Color(red: 0.62, green: 0.88, blue: 0.92), opacity: 0.5),
                PlanetBand(upper: -0.35, lower: -0.6, color: Color(red: 0.55, green: 0.84, blue: 0.9), opacity: 0.5),
            ],
            features: SurfaceFeature.scatter(
                seed: 71, count: 8, colors: [.white],
                width: 0.12...0.3, aspect: 0.2...0.4, latitude: -0.9...0.9, opacity: 0.2...0.45
            ),
            atmosphere: Color(red: 0.6, green: 0.95, blue: 1.0),
            rings: RingStyle(
                bands: [
                    RingBand(inner: 1.64, outer: 1.68, color: Color(red: 0.7, green: 0.8, blue: 0.85), opacity: 0.6),
                    RingBand(inner: 1.98, outer: 2.04, color: Color(red: 0.75, green: 0.85, blue: 0.9), opacity: 0.7),
                ],
                squash: 0.3,
                particleColor: Color(red: 0.8, green: 0.9, blue: 1.0),
                particleCount: 40,
                seed: 72
            ),
            visualTilt: 97.8,
            softness: 0.04,
            accent: Color(red: 0.5, green: 0.92, blue: 0.95)
        )
    )

    // MARK: Neptune

    static let neptune = Planet(
        id: "neptune",
        name: "Neptune",
        order: 8,
        nickname: "The Windy Giant",
        summary: "The most distant planet: a dark, freezing ice giant whipped by supersonic winds.",
        distanceFromSun: "4.5 billion km",
        diameter: "49,528 km",
        temperature: "−200°C",
        moons: 16,
        dayLength: "16.1 hours",
        yearLength: "165 Earth years",
        axialTilt: "28.3°",
        facts: [
            "Neptune has the fastest winds in the solar system — over 2,000 km/h.",
            "Neptune was the first planet found using maths before anyone saw it through a telescope.",
            "One year on Neptune lasts 165 Earth years. It finished its first orbit since discovery in 2011.",
        ],
        rotationHours: 16.11,
        orbitalPeriodDays: 60190,
        displayScale: 0.68,
        appearance: PlanetAppearance(
            baseColors: [Color(red: 0.32, green: 0.52, blue: 0.98), Color(red: 0.12, green: 0.24, blue: 0.72)],
            bands: [
                PlanetBand(upper: 0.75, lower: 0.55, color: Color(red: 0.2, green: 0.36, blue: 0.85), opacity: 0.7),
                PlanetBand(upper: -0.2, lower: -0.45, color: Color(red: 0.22, green: 0.4, blue: 0.9), opacity: 0.6),
            ],
            features: [
                SurfaceFeature(longitude: 2.0, latitude: -0.35, width: 0.3, height: 0.17, color: Color(red: 0.07, green: 0.11, blue: 0.4)),
                SurfaceFeature(longitude: 2.05, latitude: -0.5, width: 0.22, height: 0.05, color: .white, opacity: 0.8),
            ],
            clouds: SurfaceFeature.scatter(
                seed: 81, count: 12, colors: [.white],
                width: 0.15...0.4, aspect: 0.06...0.14, latitude: -1...1, opacity: 0.4...0.8
            ),
            atmosphere: Color(red: 0.4, green: 0.6, blue: 1.0),
            visualTilt: 28.3,
            softness: 0.03,
            accent: Color(red: 0.4, green: 0.58, blue: 1.0)
        )
    )
}
